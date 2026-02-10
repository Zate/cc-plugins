# Devloop Context Guard - Stop Hook (Windows)
# Monitors context usage and gracefully exits ralph loop when threshold exceeded
$ErrorActionPreference = 'Stop'

$defaultThreshold = 70
$ralphStateFile = '.claude/ralph-loop.local.md'
$contextFile = '.claude/context-usage.json'
$localConfig = '.devloop/local.md'

# If no ralph loop active, nothing to do
if (-not (Test-Path $ralphStateFile)) { exit 0 }

# If no context file, statusline hasn't run yet - continue
if (-not (Test-Path $contextFile)) { exit 0 }

# Read threshold from local config if available
$threshold = $defaultThreshold
if (Test-Path $localConfig) {
    $content = Get-Content $localConfig -Raw
    if ($content -match 'context_threshold:\s*(\d+)') {
        $threshold = [int]$Matches[1]
    }
}

# Read current context percentage
$contextPct = 0
try {
    $contextData = Get-Content $contextFile -Raw | ConvertFrom-Json
    $contextPct = [int]($contextData.context_pct)
} catch {
    exit 0
}

# Check if context exceeds threshold
if ($contextPct -ge $threshold) {
    [Console]::Error.WriteLine("Warning: Context usage at ${contextPct}% (threshold: ${threshold}%)")
    [Console]::Error.WriteLine('   Gracefully stopping ralph loop to preserve context quality.')
    [Console]::Error.WriteLine('')
    [Console]::Error.WriteLine('   Run /devloop:fresh then /devloop:run to resume with fresh context.')

    # Remove ralph state file - ralph-loop's hook will then allow exit
    Remove-Item -Force $ralphStateFile -ErrorAction SilentlyContinue
}

exit 0
