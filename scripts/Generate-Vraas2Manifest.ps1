[CmdletBinding()]
param(
    [string]$ProfilesPath,
    [string]$OutputPath,
    # The released app version published in the manifest, which the in-sim app compares against its
    # own build version to decide whether to show "update available". Normally left empty: it comes
    # from aircraft2\app_release.json so that -Check (what CI runs) regenerates deterministically.
    # Hand-editing the version into current_version.json would make CI fail as "stale".
    [string]$AppVersion,
    # The generated supported-aircraft pages, published by GitHub Pages straight out of the repo root.
    # Both are derived from the same profiles as the manifest, so -Check treats a stale page exactly
    # like a stale manifest.
    [string]$MarkdownPath,
    [string]$HtmlPath,
    [switch]$Check
)

$ErrorActionPreference = "Stop"
$schemaVersion = 2
$minimumAppVersion = "2.0.0"

$repositoryRoot = Split-Path -Parent $PSScriptRoot
if (-not $ProfilesPath) {
    $ProfilesPath = Join-Path $repositoryRoot "aircraft2"
}
if (-not $OutputPath) {
    $OutputPath = Join-Path $ProfilesPath "current_version.json"
}
if (-not $MarkdownPath) {
    $MarkdownPath = Join-Path $repositoryRoot "supported-aircraft.md"
}
if (-not $HtmlPath) {
    $HtmlPath = Join-Path $repositoryRoot "supported-aircraft\index.html"
}

$ProfilesPath = [IO.Path]::GetFullPath($ProfilesPath)
$OutputPath = [IO.Path]::GetFullPath($OutputPath)
$MarkdownPath = [IO.Path]::GetFullPath($MarkdownPath)
$HtmlPath = [IO.Path]::GetFullPath($HtmlPath)

if (-not (Test-Path -LiteralPath $ProfilesPath -PathType Container)) {
    throw "Profiles directory not found: $ProfilesPath"
}

# Released app version + optional one-line note, from the committed release file. Releasing is
# therefore: edit app_release.json, rerun this script, commit both. A missing file keeps the old
# behaviour (2.0.0, no note) so an older checkout still generates.
$appNote = ""
$releasePath = Join-Path $ProfilesPath "app_release.json"
if (Test-Path -LiteralPath $releasePath -PathType Leaf) {
    $release = Get-Content -LiteralPath $releasePath -Raw | ConvertFrom-Json
    if (-not $AppVersion -and $release.appVersion) { $AppVersion = [string]$release.appVersion }
    if ($release.appNote) { $appNote = [string]$release.appNote }
}
if (-not $AppVersion) { $AppVersion = "2.0.0" }
if ($AppVersion -notmatch '^\d+\.\d+\.\d+$') {
    throw "appVersion must be M.m.p (got '$AppVersion'). The in-sim comparison parses nothing else."
}
if ($appNote.Length -gt 80) {
    throw "appNote must be 80 characters or fewer (got $($appNote.Length)); it is one line in the EFB."
}

$profilePaths = [string[]](Get-ChildItem -LiteralPath $ProfilesPath -Filter "*.raas2" -File |
    ForEach-Object FullName)
[Array]::Sort($profilePaths, [StringComparer]::OrdinalIgnoreCase)
if ($profilePaths.Count -eq 0) {
    throw "No .raas2 profiles found in $ProfilesPath"
}

# Restricted-grammar validator for titleMatch patterns. Mirrors TitlePatternValidator.cs in the
# RAAS repo and, transitively, the WASM matcher (core/src/title_matcher.cpp): a pattern that
# passes here is guaranteed to compile in the sim. Catches bad patterns at publish time instead of
# silently failing to match. Supported: optional leading (?i), ^, $, ., .*, [...] classes with
# ranges and leading ^ negation, top-level |, backslash escapes, literals. Rejected: + ? {n,m}
# ( ) groups, backreferences, lookaround, \d style classes, bare *, trailing backslash.
function Find-TitleClassEnd {
    param([string]$Pattern, [int]$Open)
    $i = $Open + 1
    if ($i -lt $Pattern.Length -and $Pattern[$i] -eq '^') { $i++ }
    if ($i -lt $Pattern.Length -and $Pattern[$i] -eq ']') { $i++ }   # literal ] as first member
    while ($i -lt $Pattern.Length) {
        if ($Pattern[$i] -eq '\') { $i += 2; continue }
        if ($Pattern[$i] -eq ']') { return $i }
        $i++
    }
    return -1
}

# Returns $null when the pattern is valid, otherwise a human-readable error string.
function Test-TitlePattern {
    param([string]$Pattern)
    if ([string]::IsNullOrWhiteSpace($Pattern)) { return "pattern is empty" }
    if ($Pattern -eq "TODO") { return "placeholder pattern; author a real titleMatch regex" }
    $i = 0
    if ($Pattern.StartsWith("(?i)", [System.StringComparison]::Ordinal)) { $i = 4 }
    while ($i -lt $Pattern.Length) {
        $c = $Pattern[$i]
        if ($c -eq '\') {
            if ($i + 1 -ge $Pattern.Length) { return "trailing backslash" }
            $i += 2; continue
        }
        if ($c -eq '[') {
            $close = Find-TitleClassEnd $Pattern $i
            if ($close -lt 0) { return "unterminated character class at index $i" }
            $i = $close + 1; continue
        }
        if ($c -eq '+' -or $c -eq '?' -or $c -eq '{' -or $c -eq '}' -or $c -eq '(' -or $c -eq ')') {
            return "unsupported construct '$c' at index $i (the runtime matcher supports only ^ `$ . .* [...] | and literals)"
        }
        if ($c -eq '*') {
            if ($i -eq 0 -or $Pattern[$i - 1] -ne '.') {
                return "'*' at index $i must directly follow '.' (only .* is supported)"
            }
            $i++; continue
        }
        $i++
    }
    return $null
}

# --- supported-aircraft page rendering -------------------------------------------------------
# Both pages are generated from the same $catalog rows the profile loop builds, so they can never
# disagree with what ships. Every cell that carries author-supplied text (vendor, aircraft, notes)
# goes through an escaper: a stray '|' would silently break the Markdown table and a stray '<' would
# break the HTML one.

$generatedBanner = "Generated from the profiles in aircraft2/ by scripts/Generate-Vraas2Manifest.ps1. Do not edit by hand."

function ConvertTo-MarkdownCell {
    param([string]$Text)
    if (-not $Text) { return "" }
    $escaped = $Text -replace '\\', '\\' -replace '\|', '\|'
    # A newline inside a cell would terminate the table row.
    return ($escaped -replace '\r?\n', ' ').Trim()
}

function ConvertTo-HtmlText {
    param([string]$Text)
    if (-not $Text) { return "" }
    return ($Text -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;' -replace '"', '&quot;')
}

# Sorted vendor-then-aircraft, which is the order both pages present. Returned as an array so the
# two renderers cannot drift.
function Get-SortedCatalog {
    param([object[]]$Catalog)
    return @($Catalog | Sort-Object `
        @{ Expression = { $_.vendor }; Ascending = $true }, `
        @{ Expression = { $_.aircraft }; Ascending = $true })
}

function Format-AircraftMarkdown {
    param([object[]]$Catalog)
    $rows = Get-SortedCatalog $Catalog
    $lines = [Collections.Generic.List[string]]::new()
    # Front matter: without it Jekyll copies the file verbatim instead of rendering it with the
    # site theme, and the page would be served as raw Markdown.
    $lines.Add("---")
    $lines.Add("layout: default")
    $lines.Add("title: vRAAS 2 Supported Aircraft")
    $lines.Add("---")
    $lines.Add("")
    $lines.Add("<!-- $generatedBanner -->")
    $lines.Add("")
    $lines.Add("# vRAAS 2 Supported Aircraft")
    $lines.Add("")
    $lines.Add("vRAAS 2 requires **MSFS 2024**. Audio callouts work with *every* aircraft, no configuration needed.")
    $lines.Add("The $($rows.Count) aircraft below additionally ship a tuned vRAAS 2 profile that is downloaded automatically.")
    $lines.Add("")
    $lines.Add("**Display**: RAAS text on the PFD or ND.  ")
    $lines.Add("**ROP**: Runway Overrun Prevention, predictive stopping-distance alerts during landing.")
    $lines.Add("")
    $lines.Add("| Developer | Aircraft | Display | ROP | Note |")
    $lines.Add("|-----------|----------|:-------:|:---:|------|")
    foreach ($row in $rows) {
        $display = if ($row.display) { "&#10003;" } else { "" }
        $rop = if ($row.rop) { "&#10003;" } else { "" }
        $lines.Add("| $(ConvertTo-MarkdownCell $row.vendor) | $(ConvertTo-MarkdownCell $row.aircraft) | $display | $rop | $(ConvertTo-MarkdownCell $row.notes) |")
    }
    $lines.Add("")
    $lines.Add("Don't see your favourite aircraft? Send a request on our [Discord](http://discord.land3simulations.com/).")
    $lines.Add("")
    return ($lines -join "`n")
}

function Format-AircraftHtml {
    param([object[]]$Catalog)
    $rows = Get-SortedCatalog $Catalog
    $lines = [Collections.Generic.List[string]]::new()
    $lines.Add("<!DOCTYPE html>")
    $lines.Add("<html lang=`"en`">")
    $lines.Add("<head>")
    $lines.Add("<meta charset=`"utf-8`">")
    $lines.Add("<meta name=`"viewport`" content=`"width=device-width, initial-scale=1`">")
    $lines.Add("<title>vRAAS 2 Supported Aircraft</title>")
    # Self-contained on purpose: no theme, no font, no script, so the page can also be embedded or
    # shipped outside GitHub Pages.
    $lines.Add("<style>")
    $lines.Add(":root { color-scheme: light dark; --fg: #1b1f23; --muted: #57606a; --bg: #ffffff; --line: #d8dee4; --head: #f6f8fa; --tick: #1a7f37; }")
    $lines.Add("@media (prefers-color-scheme: dark) { :root { --fg: #e6edf3; --muted: #9198a1; --bg: #0d1117; --line: #30363d; --head: #161b22; --tick: #3fb950; } }")
    $lines.Add("body { margin: 0 auto; padding: 2rem 1rem 4rem; max-width: 60rem; background: var(--bg); color: var(--fg); font: 16px/1.55 -apple-system, BlinkMacSystemFont, `"Segoe UI`", Helvetica, Arial, sans-serif; }")
    $lines.Add("h1 { font-size: 1.75rem; margin: 0 0 .5rem; }")
    $lines.Add("p { margin: .5rem 0; }")
    $lines.Add(".legend { color: var(--muted); font-size: .9rem; }")
    $lines.Add(".wrap { overflow-x: auto; margin-top: 1.5rem; }")
    $lines.Add("table { border-collapse: collapse; width: 100%; font-size: .95rem; }")
    $lines.Add("th, td { border: 1px solid var(--line); padding: .4rem .7rem; text-align: left; vertical-align: top; }")
    $lines.Add("th { background: var(--head); }")
    $lines.Add("td.mark, th.mark { text-align: center; }")
    $lines.Add(".yes { color: var(--tick); font-weight: 600; }")
    $lines.Add("footer { margin-top: 2rem; color: var(--muted); font-size: .85rem; }")
    $lines.Add("</style>")
    $lines.Add("</head>")
    $lines.Add("<body>")
    $lines.Add("<!-- $generatedBanner -->")
    $lines.Add("<h1>vRAAS 2 Supported Aircraft</h1>")
    $lines.Add("<p>vRAAS 2 requires <strong>MSFS 2024</strong>. Audio callouts work with <em>every</em> aircraft, no configuration needed. The $($rows.Count) aircraft below additionally ship a tuned vRAAS 2 profile that is downloaded automatically.</p>")
    $lines.Add("<p class=`"legend`"><strong>Display</strong>: RAAS text on the PFD or ND. <strong>ROP</strong>: Runway Overrun Prevention, predictive stopping-distance alerts during landing.</p>")
    $lines.Add("<div class=`"wrap`">")
    $lines.Add("<table>")
    $lines.Add("<thead><tr><th>Developer</th><th>Aircraft</th><th class=`"mark`">Display</th><th class=`"mark`">ROP</th><th>Note</th></tr></thead>")
    $lines.Add("<tbody>")
    foreach ($row in $rows) {
        $display = if ($row.display) { "<span class=`"yes`">&#10003;</span>" } else { "" }
        $rop = if ($row.rop) { "<span class=`"yes`">&#10003;</span>" } else { "" }
        $lines.Add("<tr><td>$(ConvertTo-HtmlText $row.vendor)</td><td>$(ConvertTo-HtmlText $row.aircraft)</td><td class=`"mark`">$display</td><td class=`"mark`">$rop</td><td>$(ConvertTo-HtmlText $row.notes)</td></tr>")
    }
    $lines.Add("</tbody>")
    $lines.Add("</table>")
    $lines.Add("</div>")
    $lines.Add("<p>Don't see your favourite aircraft? Send a request on our <a href=`"http://discord.land3simulations.com/`">Discord</a>.</p>")
    $lines.Add("<footer>$generatedBanner</footer>")
    $lines.Add("</body>")
    $lines.Add("</html>")
    $lines.Add("")
    return ($lines -join "`n")
}

# The match table is now derived from each profile's meta.titleMatch (built in the profile loop
# below, in filename-enumeration order: first match wins, so name files specific-before-generic).
$matchTable = @()

# A modelId is a strict token, not a label: the WASM manifest parser sanitizes every id it reads
# and rejects the WHOLE manifest when the sanitized form is not byte-identical to the published one
# (safeIdChar / parseManifest in RAAS/vRAAS2/wasm/adapters/profile_fetch.cpp). A space, a '+', or an
# accented character in a filename therefore takes down every profile at once, in the sim, with only
# a "SHIPPED MANIFEST REJECTED" line to go on. Catch it here instead. Keep this rule in sync with
# safeIdChar and with ProfileConverter's Schema/ModelId.cs; kIdMax is 64, so 63 chars is the cap.
# (path is "$modelId.raas2", so the 63-char cap also keeps it well under the runtime's kPathMax 160.)
$canonicalIdPattern = '^[A-Za-z0-9._-]{1,63}$'

$manifestProfiles = @()
$catalog = @()
foreach ($profilePath in $profilePaths) {
    $modelId = [IO.Path]::GetFileNameWithoutExtension($profilePath)
    if ($modelId -cnotmatch $canonicalIdPattern) {
        $bad = [string]::Join(' ', ([char[]]$modelId |
            Where-Object { [string]$_ -cnotmatch '^[A-Za-z0-9._-]$' } |
            Select-Object -Unique |
            ForEach-Object { "'$_'" }))
        if (-not $bad) { $bad = "(length $($modelId.Length), must be 1..63)" }
        throw "$modelId is not a canonical modelId: $bad. A profile filename may use only A-Z a-z 0-9 . _ - (1..63 chars); the module rejects the entire manifest otherwise."
    }
    try {
        $profileJson = [IO.File]::ReadAllText($profilePath)
        # Strict parse FIRST. ConvertFrom-Json is Newtonsoft-backed and quietly accepts trailing
        # commas and comments; the module parses with rapidjson at default flags, which accepts
        # neither. Without this gate a JSON5-ish profile gets a manifest entry here and is then
        # dropped in the sim as "SHIPPED PROFILE <id> FAILED VALIDATION" with no UI explanation.
        [System.Text.Json.JsonDocument]::Parse($profileJson) | Out-Null
        $profile = $profileJson | ConvertFrom-Json
    }
    catch {
        $reason = if ($_.Exception.InnerException) { $_.Exception.InnerException.Message } else { $_.Exception.Message }
        throw "Invalid JSON in $profilePath`: $reason"
    }

    if ($null -eq $profile.meta) {
        throw "$modelId is missing the meta object."
    }
    if ($profile.meta.schemaVersion -ne $schemaVersion) {
        throw "$modelId meta.schemaVersion must be $schemaVersion."
    }
    if ($profile.meta.minAppVersion -ne $minimumAppVersion) {
        throw "$modelId meta.minAppVersion must be $minimumAppVersion."
    }
    if ($profile.meta.modelId -cne $modelId) {
        throw "$modelId meta.modelId must exactly match its filename."
    }
    # Redundant while the check above holds, but the module validates meta.modelId independently
    # (validateProfile), so assert it on its own terms rather than by transitivity.
    if ([string]$profile.meta.modelId -cnotmatch $canonicalIdPattern) {
        throw "$modelId meta.modelId '$($profile.meta.modelId)' is not a canonical modelId (A-Z a-z 0-9 . _ - only, 1..63 chars)."
    }
    # Catalog fields: the human-readable identity that the published supported-aircraft pages show.
    # They live in meta because that keeps one aircraft in one file; the runtime ignores them (the
    # WASM validator reads only schemaVersion/minAppVersion/modelId and the work-profile parser skips
    # meta wholesale), and ProfileConverter is strict on root keys only. Required, so a new profile
    # cannot ship undocumented.
    foreach ($field in @('vendor', 'aircraft')) {
        if (-not $profile.meta.PSObject.Properties.Name.Contains($field)) {
            throw "$modelId meta.$field is required; it is what the published supported-aircraft page shows."
        }
        $value = [string]$profile.meta.$field
        if ([string]::IsNullOrWhiteSpace($value)) {
            throw "$modelId meta.$field must not be empty."
        }
        if ($value.Length -gt 60) {
            throw "$modelId meta.$field must be 60 characters or fewer (got $($value.Length)); it is one table cell."
        }
    }
    # sims is not rendered today (vRAAS 2 is MSFS 2024 only) but is recorded per profile so the pages
    # can grow a column the day a profile is anything else.
    if (-not $profile.meta.PSObject.Properties.Name.Contains('sims')) {
        throw "$modelId meta.sims is required; list the simulators this profile is for, e.g. [`"2024`"]."
    }
    $sims = @($profile.meta.sims)
    if ($sims.Count -eq 0) {
        throw "$modelId meta.sims must not be empty."
    }
    foreach ($sim in $sims) {
        if (@('2020', '2024') -cnotcontains [string]$sim) {
            throw "$modelId meta.sims entry '$sim' is not recognised; use `"2020`" and/or `"2024`"."
        }
    }
    if (@($sims | Select-Object -Unique).Count -ne $sims.Count) {
        throw "$modelId meta.sims contains duplicates."
    }
    $notes = ""
    if ($profile.meta.PSObject.Properties.Name.Contains('notes')) {
        $notes = [string]$profile.meta.notes
        if ($notes.Length -gt 200) {
            throw "$modelId meta.notes must be 200 characters or fewer (got $($notes.Length)); it is one table cell."
        }
    }

    # Capability columns are derived from the profile body, never hand-flagged, so the page cannot
    # claim a feature the shipped profile does not configure. "displays" is the one non-flat member
    # of a .raas2; "rop.enabled" is the ROP group master in the settings schema.
    $hasDisplay = @(@($profile.displays) | Where-Object { $_ -and $_.enabled -eq $true }).Count -gt 0
    $hasRop = ($profile.'rop.enabled' -eq $true)

    $catalog += [pscustomobject]@{
        modelId = $modelId
        vendor = [string]$profile.meta.vendor
        aircraft = [string]$profile.meta.aircraft
        sims = [string[]]$sims
        notes = $notes
        display = $hasDisplay
        rop = $hasRop
    }

    # Identity rules live with the profile that owns them. Build the ordered match table straight
    # from them; the converter seeds titleMatch with "TODO", which the validator rejects, so an
    # un-post-processed profile fails the build instead of shipping a dead rule.
    #
    # A rule may constrain any of the four identity fields, in the runtime's MatchField order
    # (wasm/adapters/match_fields.h). Patterns are OR-ed within a field and AND-ed across fields,
    # which is what lets a generic TITLE like "737-800" (several add-ons report it) be pinned to
    # one vendor by also naming its container folder. titleMatch is the only required one.
    $row = [ordered]@{ modelId = $modelId }
    $anyPatterns = $false
    foreach ($field in @('titleMatch', 'folderMatch', 'liveryMatch', 'liveryFolderMatch')) {
        if (-not $profile.meta.PSObject.Properties.Name.Contains($field)) { continue }
        $patterns = @($profile.meta.$field)
        if ($patterns.Count -eq 0) {
            throw "$modelId meta.$field is present but empty; omit it instead (an empty field would match nothing)."
        }
        foreach ($pattern in $patterns) {
            $patternError = Test-TitlePattern ([string]$pattern)
            if ($patternError) {
                throw "$modelId meta.$field pattern '$pattern' is invalid: $patternError"
            }
        }
        $row[$field] = [string[]]$patterns
        $anyPatterns = $true
    }
    if (-not $anyPatterns -or -not $row.Contains('titleMatch')) {
        throw "$modelId has no meta.titleMatch patterns."
    }
    $matchTable += $row

    # Hash the RAW BYTES, which is what the module hashes in the sim. Re-encoding ReadAllText would
    # silently drop a BOM (or normalize an encoding) and produce a hash that validates here and
    # fails there.
    $hash = [Convert]::ToHexString(
        [Security.Cryptography.SHA256]::HashData([IO.File]::ReadAllBytes($profilePath))).ToLowerInvariant()
    $manifestProfiles += [ordered]@{
        modelId = $modelId
        profileVersion = $hash.Substring(0, 12)
        hash = $hash
        path = "$modelId.raas2"
    }
}

$manifest = [ordered]@{
    appVersion = $AppVersion
    appNote = $appNote
    schemaVersion = $schemaVersion
    minAppVersion = $minimumAppVersion
    profiles = $manifestProfiles
    matchTable = $matchTable
}
$generatedJson = $manifest | ConvertTo-Json -Depth 20

# The pages are checked in and served by GitHub Pages, so their bytes must be reproducible on any
# machine. They are written LF-only and carry `text eol=lf` in .gitattributes, so a CRLF checkout on
# a Windows runner cannot make -Check fail on line endings alone.
$generatedMarkdown = Format-AircraftMarkdown $catalog
$generatedHtml = Format-AircraftHtml $catalog

if ($Check) {
    if (-not (Test-Path -LiteralPath $OutputPath -PathType Leaf)) {
        throw "Manifest is missing: $OutputPath. Run this script without -Check and commit the result."
    }

    $committedJson = [IO.File]::ReadAllText($OutputPath)
    if ($committedJson -cne $generatedJson) {
        throw "Manifest is stale: $OutputPath. Run this script without -Check and commit the result."
    }

    foreach ($page in @(
        @{ Path = $MarkdownPath; Content = $generatedMarkdown },
        @{ Path = $HtmlPath; Content = $generatedHtml })) {
        if (-not (Test-Path -LiteralPath $page.Path -PathType Leaf)) {
            throw "Supported-aircraft page is missing: $($page.Path). Run this script without -Check and commit the result."
        }
        if ([IO.File]::ReadAllText($page.Path) -cne $page.Content) {
            throw "Supported-aircraft page is stale: $($page.Path). Run this script without -Check and commit the result."
        }
    }

    Write-Host "Manifest and supported-aircraft pages are valid and current."
    return
}

function Write-GeneratedFile {
    param([string]$Path, [string]$Content)
    [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($Path)) | Out-Null
    [IO.File]::WriteAllText($Path, $Content, [Text.UTF8Encoding]::new($false))
}

Write-GeneratedFile $OutputPath $generatedJson
Write-Host "Wrote manifest for $($manifestProfiles.Count) profiles to $OutputPath"
Write-GeneratedFile $MarkdownPath $generatedMarkdown
Write-Host "Wrote supported-aircraft page for $($catalog.Count) profiles to $MarkdownPath"
Write-GeneratedFile $HtmlPath $generatedHtml
Write-Host "Wrote supported-aircraft page for $($catalog.Count) profiles to $HtmlPath"

