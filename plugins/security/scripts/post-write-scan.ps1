$ErrorActionPreference = 'Stop'

# Post-Write Security Scan (PowerShell)
# Lightweight security check after file writes
# Used by PostToolUse hooks to track security status

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PluginRoot = Split-Path -Parent $ScriptDir
$SecurityLog = Join-Path $PluginRoot '.security-scan.log'
$Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

function Log-Finding {
    param(
        [string]$Severity,
        [string]$Message,
        [string]$File = 'unknown'
    )
    $Severity = $Severity -replace '[^A-Z]', '_'
    $Message = $Message -replace '[\r\n]', ''
    $File = $File -replace '[\r\n]', ''
    $entry = "[$Timestamp] [$Severity] $Message (file: $File)"
    try {
        Add-Content -Path $SecurityLog -Value $entry -ErrorAction SilentlyContinue
    } catch {
        Write-Error "Warning: Could not write to log" -ErrorAction SilentlyContinue
    }
}

# Read content from stdin if piped
$Content = ''
if (-not [Console]::IsInputRedirected) {
    # No stdin
} else {
    try {
        $Content = [Console]::In.ReadToEnd()
    } catch {
        $Content = ''
    }
}

if ($Content.Length -gt 0) {
    # AWS Access Key ID pattern
    if ($Content -match 'AKIA[A-Z0-9]{16}') {
        $fileVar = if ($env:TOOL_INPUT_FILE) { $env:TOOL_INPUT_FILE } else { 'unknown' }
        Log-Finding -Severity 'CRITICAL' -Message 'AWS key detected in written content' -File $fileVar
        Write-Output '{"status": "warning", "message": "Security: AWS key detected"}'
        exit 0
    }

    # Private key detection
    if ($Content -match 'BEGIN' -and $Content -match 'PRIVATE KEY') {
        $fileVar = if ($env:TOOL_INPUT_FILE) { $env:TOOL_INPUT_FILE } else { 'unknown' }
        Log-Finding -Severity 'CRITICAL' -Message 'Private key detected in written content' -File $fileVar
        Write-Output '{"status": "warning", "message": "Security: Private key detected"}'
        exit 0
    }

    # SQL injection patterns (Python f-strings)
    if ($Content -match 'f"SELECT|f''SELECT|f"INSERT|f''INSERT') {
        $fileVar = if ($env:TOOL_INPUT_FILE) { $env:TOOL_INPUT_FILE } else { 'unknown' }
        Log-Finding -Severity 'HIGH' -Message 'SQL injection pattern detected' -File $fileVar
    }

    # Command injection (shell=True)
    if ($Content -match 'shell=True') {
        $fileVar = if ($env:TOOL_INPUT_FILE) { $env:TOOL_INPUT_FILE } else { 'unknown' }
        Log-Finding -Severity 'MEDIUM' -Message 'shell=True usage detected' -File $fileVar
    }
}

# Success - no blocking issues
Write-Output '{"status": "ok"}'
exit 0
