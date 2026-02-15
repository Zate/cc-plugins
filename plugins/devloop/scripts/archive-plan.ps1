$ErrorActionPreference = 'Stop'

# archive-plan.ps1 - Archive a completed plan
#
# Usage: archive-plan.ps1 [plan-file] [--force]
#
# Output (JSON):
#   {"archived": true, "path": "...", "tasks_completed": N}
#   {"archived": false, "reason": "not_complete|no_plan|error"}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PlanFile = '.devloop/plan.md'
$Force = $false

foreach ($arg in $args) {
    switch ($arg) {
        '--force' { $Force = $true }
        default { if (-not $arg.StartsWith('--')) { $PlanFile = $arg } }
    }
}

if (-not (Test-Path $PlanFile)) {
    Write-Output '{"archived": false, "reason": "no_plan", "message": "Plan file not found"}'
    exit 2
}

$PlanDir = Split-Path -Parent $PlanFile
$ArchiveDir = Join-Path $PlanDir 'archive'

# Check completion (unless --force)
if (-not $Force) {
    $completionOutput = ''
    try {
        $completionOutput = & "$ScriptDir/check-plan-complete.ps1" $PlanFile 2>$null
    } catch { }
    $isComplete = $false
    if ($completionOutput -match '"complete":\s*true') { $isComplete = $true }
    if (-not $isComplete) {
        $pending = 0
        if ($completionOutput -match '"pending":\s*(\d+)') { $pending = [int]$Matches[1] }
        Write-Output "{`"archived`": false, `"reason`": `"not_complete`", `"pending_tasks`": $pending, `"message`": `"Plan has pending tasks. Use --force to archive anyway.`"}"
        exit 1
    }
}

# Extract plan title
$planTitle = 'untitled'
$planLines = Get-Content $PlanFile
foreach ($l in $planLines) {
    if ($l -match '^# (.+)') {
        $planTitle = $Matches[1] -replace '^Devloop Plan: ', ''
        break
    }
}

# Create slug
$slug = $planTitle.ToLower() -replace '[^a-z0-9]', '-' -replace '-+', '-' -replace '^-|-$', ''
if ($slug.Length -gt 50) { $slug = $slug.Substring(0, 50) }

$date = Get-Date -Format 'yyyy-MM-dd'
$archiveFilename = "${date}-${slug}.md"
$archivePath = Join-Path $ArchiveDir $archiveFilename

New-Item -ItemType Directory -Path $ArchiveDir -Force | Out-Null

# Avoid overwrite
if (Test-Path $archivePath) {
    $ts = Get-Date -Format 'HHmmss'
    $archiveFilename = "${date}-${slug}-${ts}.md"
    $archivePath = Join-Path $ArchiveDir $archiveFilename
}

# Count tasks
$done = 0; $total = 0
foreach ($l in $planLines) {
    if ($l -match '^\s*- \[[ x~!]\]') { $total++ }
    if ($l -match '^\s*- \[x\]') { $done++ }
}

# Extract issue reference
$issueNumber = ''; $issueUrl = ''
foreach ($l in $planLines) {
    if ($l -match '^\*\*Issue\*\*:') {
        if ($l -match '#(\d+)') { $issueNumber = $Matches[1] }
        if ($l -match '(https://[^)]+)') { $issueUrl = $Matches[1] }
        break
    }
}

# Write archive with metadata header
$timestamp = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$header = @("---", "archived_at: $timestamp", "original_path: $PlanFile", "tasks_completed: $done", "tasks_total: $total")
if ($issueNumber) { $header += "issue_number: $issueNumber" }
if ($issueUrl) { $header += "issue_url: $issueUrl" }
$header += @("---", "")

($header + $planLines) | Set-Content -Path $archivePath -Encoding UTF8

# Replace plan with placeholder
@"
# Devloop Plan

**Status**: No active plan

Run ``/devloop`` or ``/devloop:plan`` to start a new plan.
"@ | Set-Content -Path $PlanFile -Encoding UTF8

# Output JSON
$output = "{`"archived`": true, `"path`": `"$($archivePath -replace '\\', '\\\\')`", `"tasks_completed`": $done, `"tasks_total`": $total, `"title`": `"$planTitle`""
if ($issueNumber) { $output += ", `"issue_number`": $issueNumber" }
if ($issueUrl) { $output += ", `"issue_url`": `"$issueUrl`"" }
$output += "}"

Write-Output $output
exit 0
