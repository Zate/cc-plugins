$ErrorActionPreference = 'Stop'

# check-epic-state.ps1 - Check epic state from epic.json (with epic.md fallback)
#
# Usage: check-epic-state.ps1 [epic-dir]

$EpicDir = if ($args.Count -gt 0) { $args[0] } else { '.devloop' }
$EpicJson = Join-Path $EpicDir 'epic.json'
$EpicMd = Join-Path $EpicDir 'epic.md'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if ((Test-Path $EpicJson)) {
    # Parse from JSON
    $epic = Get-Content $EpicJson -Raw | ConvertFrom-Json
    $Title = $epic.title
    $Status = $epic.status
    $TotalPhases = $epic.phases.Count
    $CompletedPhases = ($epic.phases | Where-Object { $_.status -eq 'complete' }).Count
    $CurrentPhase = $epic.current_phase
    $phase = $epic.phases | Where-Object { $_.number -eq $CurrentPhase } | Select-Object -First 1
    $CurrentPhaseName = if ($phase) { $phase.name } else { 'Unknown' }
    $CurrentPhaseStatus = if ($phase) { $phase.status } else { 'pending' }
    $TestCommand = if ($epic.test_command) { $epic.test_command } else { '' }
} elseif ((Test-Path $EpicMd)) {
    $lines = Get-Content $EpicMd
    $Title = ($lines | Where-Object { $_ -match '^# ' } | Select-Object -First 1) -replace '^# (Epic: )?', ''
    $Status = 'unknown'
    $TotalPhases = 0; $CompletedPhases = 0
    $CurrentPhase = 0; $CurrentPhaseName = ''; $CurrentPhaseStatus = ''
    $TestCommand = ''

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
    if ($CompletedPhases -eq $TotalPhases -and $TotalPhases -gt 0) { $Status = 'complete' }
    elseif ($CompletedPhases -gt 0) { $Status = 'in_progress' }
    else { $Status = 'planning' }
} else {
    Write-Output '{"exists": false, "error": "no_epic", "message": "No epic.json or epic.md found"}'
    exit 2
}

# Check plan alignment
$PlanPhase = 0; $PlanComplete = $false
$planFile = Join-Path $EpicDir 'plan.md'
if (Test-Path $planFile) {
    $planLines = Get-Content $planFile
    $phaseLine = $planLines | Where-Object { $_ -match '^\*\*Phase\*\*:' } | Select-Object -First 1
    if ($phaseLine -match '(\d+)') { $PlanPhase = [int]$Matches[1] }
    $checkPlan = Join-Path $scriptDir 'check-plan-complete.ps1'
    if (Test-Path $checkPlan) {
        try { & $checkPlan $planFile | Out-Null; $PlanComplete = $true } catch { $PlanComplete = $false }
    }
}

$AllComplete = ($CompletedPhases -eq $TotalPhases) -and ($TotalPhases -gt 0)
$allCompleteStr = if ($AllComplete) { 'true' } else { 'false' }
$planCompleteStr = if ($PlanComplete) { 'true' } else { 'false' }

Write-Output "{`"exists`": true, `"title`": `"$Title`", `"status`": `"$Status`", `"total_phases`": $TotalPhases, `"completed_phases`": $CompletedPhases, `"current_phase`": $CurrentPhase, `"current_phase_name`": `"$CurrentPhaseName`", `"current_phase_status`": `"$CurrentPhaseStatus`", `"plan_phase`": $PlanPhase, `"plan_complete`": $planCompleteStr, `"all_complete`": $allCompleteStr, `"test_command`": `"$TestCommand`"}"

if ($AllComplete) { exit 0 } else { exit 1 }
