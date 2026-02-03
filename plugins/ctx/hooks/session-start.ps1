# ctx SessionStart hook (Windows)
# 1. Ensure ctx binary is installed
# 2. Check for updates (at most once per day)
# 3. Ensure database exists
# 4. Compose and inject stored knowledge
# 5. Inject using-ctx skill content
$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$pluginRoot = Split-Path -Parent $scriptDir

# --- Find or install ctx binary ---
$ctxCmd = $null
$ctxFound = Get-Command ctx -ErrorAction SilentlyContinue
if ($ctxFound) {
    $ctxCmd = 'ctx'
} else {
    $fallback = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\ctx.exe'
    if (Test-Path $fallback) {
        $ctxCmd = $fallback
    } else {
        # Install
        try {
            $installScript = Join-Path $pluginRoot 'scripts\install-binary.ps1'
            & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $installScript 2>&1 | Write-Host
            if (Test-Path $fallback) {
                $ctxCmd = $fallback
            }
        } catch {}
    }
}

if (-not $ctxCmd) {
    Write-Output '{"suppressOutput":true,"systemMessage":"ctx: binary installation failed. Run /ctx:setup to install manually."}'
    exit 0
}

# --- Check for updates (at most once per day) ---
$updateHint = ''
$ctxDir = Join-Path $env:USERPROFILE '.ctx'
$updateCheckFile = Join-Path $ctxDir '.last-update-check'
$shouldCheck = $false

if (-not (Test-Path $updateCheckFile)) {
    $shouldCheck = $true
} else {
    try {
        $lastCheck = [long](Get-Content $updateCheckFile -ErrorAction Stop)
        $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
        if (($now - $lastCheck) -gt 86400) {
            $shouldCheck = $true
        }
    } catch {
        $shouldCheck = $true
    }
}

if ($shouldCheck) {
    try {
        if (-not (Test-Path $ctxDir)) {
            New-Item -ItemType Directory -Path $ctxDir -Force | Out-Null
        }
        [DateTimeOffset]::UtcNow.ToUnixTimeSeconds().ToString() | Set-Content $updateCheckFile -ErrorAction SilentlyContinue
        $checkScript = Join-Path $pluginRoot 'scripts\check-update.ps1'
        $checkResult = & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $checkScript 2>$null
        if ($checkResult -match '^update-available:(.+):(.+)$') {
            $currentV = $Matches[1]
            $latestV = $Matches[2]
            $updateHint = "**ctx update available:** $currentV -> $latestV. Run ``/ctx:setup`` to upgrade."
        }
    } catch {}
}

# --- Ensure database exists ---
$dbPath = Join-Path $env:USERPROFILE '.ctx\store.db'
if (-not (Test-Path $dbPath)) {
    try { & $ctxCmd init 2>&1 | Write-Host } catch {}
}

# --- Detect project from git repo ---
$projectName = ''
try {
    $repoRoot = & git rev-parse --show-toplevel 2>$null
    if ($repoRoot) {
        $projectName = (Split-Path -Leaf $repoRoot).ToLower()
    }
} catch {}

# --- Get ctx hook output ---
$ctxOutput = '{}'
try {
    $ctxOutput = & $ctxCmd hook session-start --project="$projectName" 2>$null
    if (-not $ctxOutput) { $ctxOutput = '{}' }
} catch {
    $ctxOutput = '{}'
}

# --- Extract additionalContext from ctx output ---
$ctxContext = ''
try {
    $parsed = $ctxOutput | ConvertFrom-Json
    if ($parsed.hookSpecificOutput -and $parsed.hookSpecificOutput.additionalContext) {
        $ctxContext = $parsed.hookSpecificOutput.additionalContext
    }
} catch {}

# --- Read skill content (strip frontmatter) ---
$skillContent = ''
$skillPath = Join-Path $pluginRoot 'skills\using-ctx\SKILL.md'
if (Test-Path $skillPath) {
    $lines = Get-Content $skillPath
    $fenceCount = 0
    $contentLines = @()
    foreach ($line in $lines) {
        if ($line -eq '---') {
            $fenceCount++
            continue
        }
        if ($fenceCount -ge 2) {
            $contentLines += $line
        }
    }
    $skillContent = ($contentLines -join "`n").TrimStart("`n")
}

# --- Combine context ---
$parts = @()
if ($updateHint) { $parts += $updateHint }
if ($ctxContext) { $parts += $ctxContext }
if ($skillContent) { $parts += $skillContent }

if ($parts.Count -eq 0) {
    Write-Output '{"suppressOutput":true,"systemMessage":"ctx: ready (empty context)"}'
    exit 0
}

$combined = $parts -join "`n`n"

# Count nodes for status
$nodeCount = 0
foreach ($line in ($ctxContext -split "`n")) {
    if ($line -match '^\- \[') { $nodeCount++ }
}
$status = "ctx: $nodeCount nodes loaded"

# --- Output JSON ---
$output = @{
    suppressOutput = $true
    systemMessage = $status
    hookSpecificOutput = @{
        hookEventName = 'SessionStart'
        additionalContext = $combined
    }
}

$output | ConvertTo-Json -Depth 5 -Compress
