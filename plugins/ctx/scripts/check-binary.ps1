# Check if ctx binary is available and working
$ErrorActionPreference = 'Stop'

$ctxCmd = Get-Command ctx -ErrorAction SilentlyContinue
if (-not $ctxCmd) {
    $fallback = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\ctx.exe'
    if (Test-Path $fallback) {
        $ctxCmd = $fallback
    } else {
        Write-Output 'not-found'
        exit 1
    }
}

try {
    $version = & $ctxCmd version 2>$null
    if (-not $version) { $version = 'unknown' }
    Write-Output "found:$version"
    exit 0
} catch {
    Write-Output 'not-found'
    exit 1
}
