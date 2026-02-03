# ctx Stop hook - parse ctx commands from transcript
$ErrorActionPreference = 'Stop'

# Find ctx binary
$ctxCmd = Get-Command ctx -ErrorAction SilentlyContinue
if (-not $ctxCmd) {
    $fallback = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\ctx.exe'
    if (Test-Path $fallback) {
        $ctxCmd = $fallback
    } else {
        Write-Output '{}'
        exit 0
    }
}

# Read stdin and pipe to ctx hook stop (it reads transcript_path from stdin)
$stdinContent = [Console]::In.ReadToEnd()
$stdinContent | & $ctxCmd hook stop
