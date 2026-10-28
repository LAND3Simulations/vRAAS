[CmdletBinding()]
param(
    [string]$ProfilesPath,
    [string]$OutputPath,
    # The released app version published in the manifest, which the in-sim app compares against its
    # own build version to decide whether to show "update available". Normally left empty: it comes
    # from aircraft2\app_release.json so that -Check (what CI runs) regenerates deterministically.
    # Hand-editing the version into current_version.json would make CI fail as "stale".
    [string]$AppVersion,
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

$ProfilesPath = [IO.Path]::GetFullPath($ProfilesPath)
$OutputPath = [IO.Path]::GetFullPath($OutputPath)

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
    # Catalog fields: the human-readable identity that the supported-aircraft table on
    # land3simulations.com/vraas shows (LAND3Website/scripts/fetch-vraas2-aircraft.mjs reads them
    # from the CDN at build time). They live in meta because that keeps one aircraft in one file; the runtime ignores them (the
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
    # sims is not rendered today (vRAAS 2 is MSFS 2024 only) but is recorded per profile so the table
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
    if ($profile.meta.PSObject.Properties.Name.Contains('notes')) {
        $notes = [string]$profile.meta.notes
        if ($notes.Length -gt 200) {
            throw "$modelId meta.notes must be 200 characters or fewer (got $($notes.Length)); it is one table cell."
        }
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

if ($Check) {
    if (-not (Test-Path -LiteralPath $OutputPath -PathType Leaf)) {
        throw "Manifest is missing: $OutputPath. Run this script without -Check and commit the result."
    }

    $committedJson = [IO.File]::ReadAllText($OutputPath)
    if ($committedJson -cne $generatedJson) {
        throw "Manifest is stale: $OutputPath. Run this script without -Check and commit the result."
    }

    Write-Host "Manifest is valid and current."
    return
}

function Write-GeneratedFile {
    param([string]$Path, [string]$Content)
    [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($Path)) | Out-Null
    [IO.File]::WriteAllText($Path, $Content, [Text.UTF8Encoding]::new($false))
}

Write-GeneratedFile $OutputPath $generatedJson
Write-Host "Wrote manifest for $($manifestProfiles.Count) profiles to $OutputPath"

