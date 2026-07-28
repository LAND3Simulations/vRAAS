[CmdletBinding()]
param(
    [string]$ProfilesPath,
    [string]$OutputPath,
    # Optional. When set, ALSO emits the compiled-in base table the WASM module ships with
    # (bundled_profiles.gen.cpp), generated from the same aircraft2 profiles + their meta.titleMatch
    # as the CDN manifest so the shipped base and the CDN set never drift. Left empty for CI, which only
    # validates the manifest and cannot see the RAAS repo. Sibling-repo default path, from here:
    #   ../RAAS/vRAAS2/wasm/adapters/bundled_profiles.gen.cpp
    [string]$EmitCppPath,
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
if ($EmitCppPath) {
    $EmitCppPath = [IO.Path]::GetFullPath($EmitCppPath)
}

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

function New-BundledProfilesCpp {
    param(
        [object[]]$Bundled,
        [object[]]$MatchTable
    )

    # Emits the compiled-in base table the WASM module reads (bundled_profiles.gen.h contract):
    # each aircraft2 profile as a JSON string literal, plus the ordered title->model rules. LF
    # line endings, so the output is byte-stable across platforms for the -Check comparison.
    $lf = "`n"
    $sb = [System.Text.StringBuilder]::new()
    $add = {
        param([string]$Text)
        [void]$sb.Append($Text)
        [void]$sb.Append($lf)
    }

    & $add "// GENERATED FILE - do not edit by hand."
    & $add "// Produced by vRAAS/scripts/Generate-Vraas2Manifest.ps1 -EmitCppPath."
    & $add "//"
    & $add "// Vendor profiles are compiled into the module rather than shipped as package files:"
    & $add "// WASM cannot read .cfg/.xml/.bgl/.dds out of an encrypted Marketplace package, and this"
    & $add "// sidesteps the question entirely. The work/profiles CDN cache overlays this at runtime."
    & $add "#include ""bundled_profiles.gen.h"""
    & $add ""
    & $add "namespace vraas2 {"
    & $add "namespace wasm {"
    & $add ""

    & $add "const BundledProfile kBundledProfiles[] = {"
    if ($Bundled.Count -eq 0) {
        & $add "    {0, 0},   // sentinel, never read (kBundledProfileCount == 0)"
    }
    foreach ($b in $Bundled) {
        $mid = $b.modelId.Replace('\', '\\').Replace('"', '\"')
        & $add ("    { ""$mid"",")
        foreach ($line in ($b.json -split "`n")) {
            $esc = $line.TrimEnd("`r").Replace('\', '\\').Replace('"', '\"')
            & $add ("        ""$esc""")
        }
        & $add "    },"
    }
    & $add "};"
    & $add "const int kBundledProfileCount = $($Bundled.Count);"
    & $add ""

    & $add "// Ordered specific to generic; first match wins. Matching is an unanchored"
    & $add "// substring search unless the pattern uses ^ or `$, so a generic rule placed too"
    & $add "// early will shadow the specific rules below it."
    & $add "const TitleMatchRule kTitleMatchRules[] = {"
    $ruleCount = 0
    foreach ($m in $MatchTable) {
        $mid = ([string]$m.modelId).Replace('\', '\\').Replace('"', '\"')
        foreach ($p in $m.titleMatch) {
            $pat = ([string]$p).Replace('\', '\\').Replace('"', '\"')
            & $add ("    { ""$mid"", ""$pat"" },")
            $ruleCount++
        }
    }
    if ($ruleCount -eq 0) {
        & $add "    {0, 0},   // sentinel, never read (kTitleMatchRuleCount == 0)"
    }
    & $add "};"
    & $add "const int kTitleMatchRuleCount = $ruleCount;"
    & $add ""
    & $add "}  // namespace wasm"
    & $add "}  // namespace vraas2"

    return $sb.ToString()
}

$manifestProfiles = @()
$bundled = @()
foreach ($profilePath in $profilePaths) {
    $modelId = [IO.Path]::GetFileNameWithoutExtension($profilePath)
    try {
        $profileJson = [IO.File]::ReadAllText($profilePath)
        $profile = $profileJson | ConvertFrom-Json
    }
    catch {
        throw "Invalid JSON in $profilePath`: $($_.Exception.Message)"
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
    # Identity rules live with the profile that owns them (meta.titleMatch). Build the ordered
    # match table straight from them; the converter seeds this with "TODO", which the validator
    # rejects, so an un-post-processed profile fails the build instead of shipping a dead rule.
    $patterns = @($profile.meta.titleMatch)
    if ($patterns.Count -eq 0) {
        throw "$modelId has no meta.titleMatch patterns."
    }
    foreach ($pattern in $patterns) {
        $patternError = Test-TitlePattern ([string]$pattern)
        if ($patternError) {
            throw "$modelId meta.titleMatch pattern '$pattern' is invalid: $patternError"
        }
    }
    $matchTable += [ordered]@{
        modelId = $modelId
        titleMatch = [string[]]$patterns
    }

    $contentBytes = [Text.Encoding]::UTF8.GetBytes($profileJson)
    $hash = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($contentBytes)).ToLowerInvariant()
    $manifestProfiles += [ordered]@{
        modelId = $modelId
        profileVersion = $hash.Substring(0, 12)
        hash = $hash
        path = "$modelId.raas2"
    }
    $bundled += [pscustomobject]@{ modelId = $modelId; json = $profileJson }
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

$generatedCpp = $null
if ($EmitCppPath) {
    $generatedCpp = New-BundledProfilesCpp -Bundled $bundled -MatchTable $matchTable
}

if ($Check) {
    if (-not (Test-Path -LiteralPath $OutputPath -PathType Leaf)) {
        throw "Manifest is missing: $OutputPath. Run this script without -Check and commit the result."
    }

    $committedJson = [IO.File]::ReadAllText($OutputPath)
    if ($committedJson -cne $generatedJson) {
        throw "Manifest is stale: $OutputPath. Run this script without -Check and commit the result."
    }

    if ($EmitCppPath) {
        if (-not (Test-Path -LiteralPath $EmitCppPath -PathType Leaf)) {
            throw "Bundled table is missing: $EmitCppPath. Run this script without -Check and commit the result."
        }
        $committedCpp = [IO.File]::ReadAllText($EmitCppPath)
        if ($committedCpp -cne $generatedCpp) {
            throw "Bundled table is stale: $EmitCppPath. Run this script without -Check and commit the result."
        }
        Write-Host "Bundled table is valid and current: $EmitCppPath"
    }

    Write-Host "Manifest is valid and current: $OutputPath"
    return
}

$outputDirectory = [IO.Path]::GetDirectoryName($OutputPath)
[IO.Directory]::CreateDirectory($outputDirectory) | Out-Null
[IO.File]::WriteAllText($OutputPath, $generatedJson, [Text.UTF8Encoding]::new($false))
Write-Host "Wrote manifest for $($manifestProfiles.Count) profiles to $OutputPath"

if ($EmitCppPath) {
    $cppDirectory = [IO.Path]::GetDirectoryName($EmitCppPath)
    [IO.Directory]::CreateDirectory($cppDirectory) | Out-Null
    [IO.File]::WriteAllText($EmitCppPath, $generatedCpp, [Text.UTF8Encoding]::new($false))
    Write-Host "Wrote bundled table for $($bundled.Count) profiles to $EmitCppPath"
}
