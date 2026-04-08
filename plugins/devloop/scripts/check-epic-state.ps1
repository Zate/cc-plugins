$ErrorActionPreference = 'Stop'

# check-epic-state.ps1 - Check epic state and current phase progress
#
# Usage: check-epic-state.ps1 [epic-file]

$EpicFile = if ($args.Count -gt 0) { $args[0] } else { '.devloop/epic.md' }

if (-not (Test-Path $EpicFile)) {
    Write-Output '{"exists": false, "error": "no_epic", "message": "Epic file not found"}'
    exit 2
}

$lines = Get-Content $EpicFile

# Extract title
$Title = ($lines | Where-Object { $_ -match '^# ' } | Select-Object -First 1) -replace '^# (Epic: )?', ''

# Parse phase tracker table
$TotalPhases = 0; $CompletedPhases = 0
$CurrentPhase = 0; $CurrentPhaseName = ''; $CurrentPhaseStatus = ''

foreach ($line in $lines) {
    if ($line -match '^\|\s*(\d+)\s*\|([^|]+)\|([^|]+)\|([^|]+)\|') {
        $phaseNum = [int]$Matches[1]
        $name = $Matches[2].Trim()
        $status = $Matches[4].Trim().ToLower() -replace '`', ''

        $TotalPhases++

        if ($status -eq 'complete') {
            $CompletedPhases++
        } elseif ($CurrentPhase -eq 0) {
            $CurrentPhase = $phaseNum
            $CurrentPhaseName = $name
            $CurrentPhaseStatus = $status
        }
    }
}

$AllComplete = ($CompletedPhases -eq $TotalPhases) -and ($TotalPhases -gt 0)
$allCompleteStr = if ($AllComplete) { 'true' } else { 'false' }

# Check plan.md
$PlanPhase = 0; $PlanComplete = $false
if (Test-Path '.devloop/plan.md') {
    $planLines = Get-Content '.devloop/plan.md'
    $phaseLine = $planLines | Where-Object { $_ -match '^\*\*Phase\*\*:' } | Select-Object -First 1
    if ($phaseLine -match '(\d+)') { $PlanPhase = [int]$Matches[1] }

    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $checkPlan = Join-Path $scriptDir 'check-plan-complete.ps1'
    if (Test-Path $checkPlan) {
        try { & $checkPlan '.devloop/plan.md' | Out-Null; $PlanComplete = $true } catch { $PlanComplete = $false }
    }
}
$planCompleteStr = if ($PlanComplete) { 'true' } else { 'false' }

Write-Output "{`"exists`": true, `"title`": `"$Title`", `"total_phases`": $TotalPhases, `"completed_phases`": $CompletedPhases, `"current_phase`": $CurrentPhase, `"current_phase_name`": `"$CurrentPhaseName`", `"current_phase_status`": `"$CurrentPhaseStatus`", `"plan_phase`": $PlanPhase, `"plan_complete`": $planCompleteStr, `"all_complete`": $allCompleteStr}"

if ($AllComplete) { exit 0 } else { exit 1 }
