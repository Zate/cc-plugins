$ErrorActionPreference = 'Stop'

# promote-phase.ps1 - Promote an epic phase to plan.md
#
# Usage: promote-phase.ps1 [--phase N] [--force]

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

if (-not (Test-Path $EpicJson) -or -not (Test-Path $EpicMd)) {
    Write-Output '{"error": "no_epic", "message": "epic.json and epic.md are both required"}'
    exit 2
}

# Guard against overwriting incomplete plan
$planFile = Join-Path $EpicDir 'plan.md'
if ((Test-Path $planFile) -and -not $Force) {
    $checkPlan = Join-Path $scriptDir 'check-plan-complete.ps1'
    try { & $checkPlan $planFile | Out-Null }
    catch {
        Write-Output '{"error": "plan_incomplete", "message": "Plan has incomplete tasks. Use --force to override."}'
        exit 3
    }
}

# Get target phase
$epic = Get-Content $EpicJson -Raw | ConvertFrom-Json
if (-not $TargetPhase) { $TargetPhase = $epic.current_phase }

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
        $InPhase = $true; $PhaseName = $Matches[1]; continue
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
**Epic**: .devloop/epic.json
**Phase**: $TargetPhase

## Overview

Phase $TargetPhase of Epic: $EpicTitle -- $PhaseName

## Phase ${TargetPhase}: $PhaseName

$content

## Progress Log

"@ | Set-Content $planFile

# Update epic.json
$epic.current_phase = [int]$TargetPhase
$epic.status = 'in_progress'
$phase = $epic.phases | Where-Object { $_.number -eq [int]$TargetPhase }
if ($phase) { $phase.status = 'in_progress' }
$epic | ConvertTo-Json -Depth 10 | Set-Content $EpicJson

# Update epic.md tracker (best-effort)
$epicContent = Get-Content $EpicMd -Raw
$epicContent = $epicContent -replace "(\|\s*$TargetPhase\s*\|[^|]+\|[^|]+\|)\s*``?pending``?\s*\|", "`$1 ``in_progress`` |"
Set-Content $EpicMd $epicContent

Write-Output "{`"promoted`": true, `"phase`": $TargetPhase, `"phase_name`": `"$PhaseName`", `"tasks`": $TaskCount, `"plan_path`": `"$planFile`"}"
