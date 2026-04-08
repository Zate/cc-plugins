$ErrorActionPreference = 'Stop'

# promote-phase.ps1 - Promote next epic phase to plan.md
#
# Usage: promote-phase.ps1 [epic-file] [--phase N] [--force]

$EpicFile = '.devloop/epic.md'
$TargetPhase = ''
$Force = $false

for ($i = 0; $i -lt $args.Count; $i++) {
    switch ($args[$i]) {
        '--phase' { $TargetPhase = $args[++$i] }
        '--force' { $Force = $true }
        default { $EpicFile = $args[$i] }
    }
}

if (-not (Test-Path $EpicFile)) {
    Write-Output '{"error": "no_epic", "message": "Epic file not found"}'
    exit 2
}

# Check plan completion
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ((Test-Path '.devloop/plan.md') -and -not $Force) {
    try { & "$scriptDir\check-plan-complete.ps1" '.devloop/plan.md' | Out-Null }
    catch {
        Write-Output '{"error": "plan_incomplete", "message": "Plan has incomplete tasks. Use --force to override."}'
        exit 3
    }
}

$lines = Get-Content $EpicFile
$EpicTitle = ($lines | Where-Object { $_ -match '^# ' } | Select-Object -First 1) -replace '^# (Epic: )?', ''

# Find target phase
if (-not $TargetPhase) {
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

# Extract phase content
$PhaseName = ''; $PhaseContent = @(); $InPhase = $false

foreach ($line in $lines) {
    if ($line -match "^### Phase ${TargetPhase}: (.+)") {
        $InPhase = $true
        $PhaseName = $Matches[1]
        continue
    }
    if ($InPhase) {
        if ($line -match '^### Phase \d+:|^---|^## ') { break }
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

# Write plan.md
@"
# Devloop Plan: Phase $TargetPhase -- $PhaseName

**Created**: $Today
**Updated**: $Today
**Status**: In Progress
**Epic**: $EpicFile (Phase $TargetPhase of $EpicTitle)
**Phase**: $TargetPhase

## Overview

Phase $TargetPhase of Epic: $EpicTitle -- $PhaseName

## Phase ${TargetPhase}: $PhaseName

$content

## Progress Log

"@ | Set-Content '.devloop/plan.md'

# Update epic tracker
$epicContent = Get-Content $EpicFile -Raw
$epicContent = $epicContent -replace "(\|\s*$TargetPhase\s*\|[^|]+\|[^|]+\|)\s*``?pending``?\s*\|", "`$1 ``in_progress`` |"
$epicContent = $epicContent -replace '\*\*Updated\*\*:.*', "**Updated**: $Today"
$epicContent = $epicContent -replace '\*\*Status\*\*:.*', '**Status**: In Progress'
$epicContent = $epicContent -replace '\*\*Current Phase\*\*:.*', "**Current Phase**: $TargetPhase"
Set-Content $EpicFile $epicContent

Write-Output "{`"promoted`": true, `"phase`": $TargetPhase, `"phase_name`": `"$PhaseName`", `"tasks`": $TaskCount, `"plan_path`": `".devloop/plan.md`", `"epic`": `"$EpicFile`"}"
exit 0
