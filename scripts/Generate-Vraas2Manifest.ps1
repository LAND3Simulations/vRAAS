[CmdletBinding()]
param(
    [string]$ProfilesPath,
    [string]$MatchPath,
    [string]$OutputPath,
    # Optional. When set, ALSO emits the compiled-in base table the WASM module ships with
    # (bundled_profiles.gen.cpp), generated from the same aircraft2 profiles + title rules as the
    # CDN manifest so the shipped base and the CDN set never drift. Left empty for CI, which only
    # validates the manifest and cannot see the RAAS repo. Sibling-repo default path, from here:
    #   ../RAAS/vRAAS2/wasm/adapters/bundled_profiles.gen.cpp
    [string]$EmitCppPath,
    [string]$AppVersion = "2.0.0",
    [switch]$Check
)

$ErrorActionPreference = "Stop"
$schemaVersion = 2
$minimumAppVersion = "2.0.0"

$repositoryRoot = Split-Path -Parent $PSScriptRoot
if (-not $ProfilesPath) {
    $ProfilesPath = Join-Path $repositoryRoot "aircraft2"
}
if (-not $MatchPath) {
    $MatchPath = Join-Path $repositoryRoot ".github/vraas2-titlematch.authored.json"
}
if (-not $OutputPath) {
    $OutputPath = Join-Path $ProfilesPath "current_version.json"
}

$ProfilesPath = [IO.Path]::GetFullPath($ProfilesPath)
$MatchPath = [IO.Path]::GetFullPath($MatchPath)
$OutputPath = [IO.Path]::GetFullPath($OutputPath)
if ($EmitCppPath) {
    $EmitCppPath = [IO.Path]::GetFullPath($EmitCppPath)
}

if (-not (Test-Path -LiteralPath $ProfilesPath -PathType Container)) {
    throw "Profiles directory not found: $ProfilesPath"
}
if (-not (Test-Path -LiteralPath $MatchPath -PathType Leaf)) {
    throw "Authored title-match file not found: $MatchPath"
}

$profilePaths = [string[]](Get-ChildItem -LiteralPath $ProfilesPath -Filter "*.raas2" -File |
    ForEach-Object FullName)
[Array]::Sort($profilePaths, [StringComparer]::OrdinalIgnoreCase)
if ($profilePaths.Count -eq 0) {
    throw "No .raas2 profiles found in $ProfilesPath"
}

try {
    $matchJson = [IO.File]::ReadAllText($MatchPath)
    $authoredMatches = @($matchJson | ConvertFrom-Json)
}
catch {
    throw "Invalid JSON in $MatchPath`: $($_.Exception.Message)"
}

$matchesByModel = @{}
$matchTable = @()
foreach ($entry in $authoredMatches) {
    $modelId = [string]$entry.modelId
    $patterns = @($entry.titleMatch)

    if ([string]::IsNullOrWhiteSpace($modelId)) {
        throw "Every entry in $MatchPath must have a non-empty modelId."
    }
    if ($matchesByModel.ContainsKey($modelId)) {
        throw "Duplicate modelId in $MatchPath`: $modelId"
    }
    if ($patterns.Count -eq 0) {
        throw "$modelId has no titleMatch patterns in $MatchPath"
    }

    foreach ($pattern in $patterns) {
        if ([string]::IsNullOrWhiteSpace([string]$pattern) -or $pattern -eq "TODO") {
            throw "$modelId contains an empty or TODO titleMatch pattern in $MatchPath"
        }
    }

    $matchesByModel[$modelId] = $true
    $matchTable += [ordered]@{
        modelId = $modelId
        titleMatch = [string[]]$patterns
    }
}

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
    if (-not $matchesByModel.ContainsKey($modelId)) {
        throw "$modelId has no authored titleMatch entry in $MatchPath"
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
