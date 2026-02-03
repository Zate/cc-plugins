# Check if a newer version of ctx is available on GitHub releases.
# Outputs one of:
#   up-to-date:<current_version>
#   update-available:<current_version>:<latest_version>
#   check-failed:<reason>
$ErrorActionPreference = 'Stop'

$repo = 'Zate/Memdown'

# Find ctx binary
$ctxCmd = Get-Command ctx -ErrorAction SilentlyContinue
if (-not $ctxCmd) {
    $fallback = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\ctx.exe'
    if (Test-Path $fallback) {
        $ctxCmd = $fallback
    } else {
        Write-Output 'check-failed:binary-not-found'
        exit 0
    }
}

# Get current version
try {
    $current = & $ctxCmd version 2>$null
} catch {
    $current = ''
}

if (-not $current) {
    Write-Output 'check-failed:version-unknown'
    exit 0
}

# Extract semver from "ctx v0.1.0 (commit abc, built ...)" or "ctx dev ..."
if ($current -match 'ctx\s+(\S+)') {
    $currentTag = $Matches[1]
} else {
    Write-Output 'check-failed:version-parse'
    exit 0
}

if ($currentTag -eq 'dev') {
    Write-Output 'check-failed:dev-build'
    exit 0
}

# Normalize: ensure it starts with v
if ($currentTag -notmatch '^v') {
    $currentTag = "v$currentTag"
}

# Get latest release tag from GitHub
try {
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases/latest" -UseBasicParsing -TimeoutSec 3
    $latestTag = $release.tag_name
} catch {
    Write-Output 'check-failed:network'
    exit 0
}

if (-not $latestTag) {
    Write-Output 'check-failed:network'
    exit 0
}

# Extract base semver (strip git describe suffixes like -4-gabc123-dirty)
$currentClean = $currentTag -replace '^v', ''
$currentBase = $currentClean -replace '-\d+-g[0-9a-f].*$', ''
$latestClean = $latestTag -replace '^v', ''

if ($currentBase -eq $latestClean) {
    Write-Output "up-to-date:$currentTag"
} else {
    # Compare versions
    try {
        $currentVer = [Version]$currentBase
        $latestVer = [Version]$latestClean
        if ($latestVer -gt $currentVer) {
            Write-Output "update-available:${currentTag}:${latestTag}"
        } else {
            Write-Output "up-to-date:$currentTag"
        }
    } catch {
        # Fallback: string comparison
        Write-Output "update-available:${currentTag}:${latestTag}"
    }
}
