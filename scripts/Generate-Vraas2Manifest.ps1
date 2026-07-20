[CmdletBinding()]
param(
    [string]$ProfilesPath,
    [string]$MatchPath,
    [string]$OutputPath,
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

$manifestProfiles = @()
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
}

$manifest = [ordered]@{
    appVersion = $AppVersion
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

    Write-Host "Manifest is valid and current: $OutputPath"
    return
}

$outputDirectory = [IO.Path]::GetDirectoryName($OutputPath)
[IO.Directory]::CreateDirectory($outputDirectory) | Out-Null
[IO.File]::WriteAllText($OutputPath, $generatedJson, [Text.UTF8Encoding]::new($false))
Write-Host "Wrote manifest for $($manifestProfiles.Count) profiles to $OutputPath"
