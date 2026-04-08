$ErrorActionPreference = 'Stop'

# promote-phase.ps1 - Promote next epic phase to plan.md
#
# Usage: promote-phase.ps1 [--phase N] [--force]
# Reads epic.json for state, epic.md for task content.

$EpicDir = '.devloop'
$EpicJson = Join-Path $EpicDir 'epic.json'
$EpicMd = Join-Path $EpicDir 'epic.md'
$TargetPhase = ''
$Force = $false
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

for ($i = 0; $i -lt $args.Count; $i++) {
    switch ($args[$i]) {
        '--phase' { $TargetPhase = $args[++$i] }
        '--force' { $Force = $true }
    }
}

if (-not (Test-Path $EpicJson) -and -not (Test-Path $EpicMd)) {
    Write-Output '{"error": "no_epic", "message": "No epic.json or epic.md found"}'
    exit 2
}

# Check plan completion
$planFile = Join-Path $EpicDir 'plan.md'
if ((Test-Path $planFile) -and -not $Force) {
    $checkPlan = Join-Path $scriptDir 'check-plan-complete.ps1'
    try { & $checkPlan $planFile | Out-Null }
    catch {
        Write-Output '{"error": "plan_incomplete", "message": "Plan has incomplete tasks. Use --force to override."}'
        exit 3
    }
}

# Determine target phase from epic.json
if (-not $TargetPhase -and (Test-Path $EpicJson)) {
    $epic = Get-Content $EpicJson -Raw | ConvertFrom-Json
    $TargetPhase = $epic.current_phase
}

if (-not $TargetPhase) {
    # Fall back to epic.md tracker
    $lines = Get-Content $EpicMd
    foreach ($line in $lines) {
        if ($line -match '^\|\s*(\d+)\s*\|([^|]+)\|([^|]+)\|([^|]+)\|') {
            $status = $Matches[4].Trim().ToLower() -replace '`', ''
            if ($status -eq 'pending' -or $status -eq 'in_progress') {
                $TargetPhase = $Matches[1].Trim()
                break
            }
        }
    }
}

if (-not $TargetPhase) {
    Write-Output '{"error": "no_pending", "message": "No pending phases found"}'
    exit 1
}

$lines = Get-Content $EpicMd
$EpicTitle = ($lines | Where-Object { $_ -match '^# ' } | Select-Object -First 1) -replace '^# (Epic: )?', ''

# Extract phase content
$PhaseName = ''; $PhaseContent = @(); $InPhase = $false
foreach ($line in $lines) {
    if ($line -match "^### Phase ${TargetPhase}: (.+)") {
        $InPhase = $true
        $PhaseName = $Matches[1]
        continue
    }
    if ($InPhase) {
        if ($line -match '^### Phase \d+:|^## ') { break }
        $PhaseContent += $line
    }
}

if (-not $PhaseName) {
    Write-Output "{`"error`": `"phase_not_found`", `"message`": `"Phase $TargetPhase not found`"}"
    exit 1
}

$TaskCount = ($PhaseContent | Where-Object { $_ -match '^\s*- \[[ x~!-]\]' }).Count
$Today = Get-Date -Format 'yyyy-MM-dd'
$content = $PhaseContent -join "`n"

@"
# Devloop Plan: Phase $TargetPhase -- $PhaseName

**Created**: $Today
**Updated**: $Today
**Status**: In Progress
**Epic**: .devloop/epic.json (Phase $TargetPhase of $EpicTitle)
**Phase**: $TargetPhase

## Overview

Phase $TargetPhase of Epic: $EpicTitle -- $PhaseName

## Phase ${TargetPhase}: $PhaseName

$content

## Progress Log

"@ | Set-Content $planFile

# Update epic.md tracker
$epicContent = Get-Content $EpicMd -Raw
$epicContent = $epicContent -replace "(\|\s*$TargetPhase\s*\|[^|]+\|[^|]+\|)\s*``?pending``?\s*\|", "`$1 ``in_progress`` |"
Set-Content $EpicMd $epicContent

# Update epic.json
if (Test-Path $EpicJson) {
    $epic = Get-Content $EpicJson -Raw | ConvertFrom-Json
    $epic.current_phase = [int]$TargetPhase
    $epic.status = 'in_progress'
    $phase = $epic.phases | Where-Object { $_.number -eq [int]$TargetPhase }
    if ($phase) { $phase.status = 'in_progress' }
    $epic | ConvertTo-Json -Depth 10 | Set-Content $EpicJson
}

Write-Output "{`"promoted`": true, `"phase`": $TargetPhase, `"phase_name`": `"$PhaseName`", `"tasks`": $TaskCount, `"plan_path`": `"$planFile`", `"epic`": `"$EpicJson`"}"
exit 0
