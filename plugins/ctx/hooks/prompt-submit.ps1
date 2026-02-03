# ctx UserPromptSubmit hook - inject pending recalls and nudges
$ErrorActionPreference = 'Stop'

# Find ctx binary
$ctxCmd = Get-Command ctx -ErrorAction SilentlyContinue
if (-not $ctxCmd) {
    $fallback = Join-Path $env:USERPROFILE '.local\bin\ctx.exe'
    if (Test-Path $fallback) {
        $ctxCmd = $fallback
    } else {
        Write-Output '{}'
        exit 0
    }
}

& $ctxCmd hook prompt-submit
