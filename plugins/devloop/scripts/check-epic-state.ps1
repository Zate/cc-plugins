$ErrorActionPreference = 'Stop'

# check-epic-state.ps1 - Check epic state from epic.json
#
# Usage: check-epic-state.ps1 [epic-dir]

$EpicDir = if ($args.Count -gt 0) { $args[0] } else { '.devloop' }
$EpicJson = Join-Path $EpicDir 'epic.json'

if (-not (Test-Path $EpicJson)) {
    Write-Output '{"exists": false, "error": "no_epic", "message": "No epic.json found"}'
    exit 2
}

$epic = Get-Content $EpicJson -Raw | ConvertFrom-Json
$Title = $epic.title
$Status = $epic.status
$TotalPhases = $epic.phases.Count
$CompletedPhases = ($epic.phases | Where-Object { $_.status -eq 'complete' }).Count
$CurrentPhase = $epic.current_phase
$phase = $epic.phases | Where-Object { $_.number -eq $CurrentPhase } | Select-Object -First 1
$CurrentPhaseName = if ($phase) { $phase.name } else { 'Unknown' }
$TestCommand = if ($epic.test_command) { $epic.test_command } else { '' }

$AllComplete = ($CompletedPhases -eq $TotalPhases) -and ($TotalPhases -gt 0)
$allCompleteStr = if ($AllComplete) { 'true' } else { 'false' }

Write-Output "{`"exists`": true, `"title`": `"$Title`", `"status`": `"$Status`", `"total_phases`": $TotalPhases, `"completed_phases`": $CompletedPhases, `"current_phase`": $CurrentPhase, `"current_phase_name`": `"$CurrentPhaseName`", `"all_complete`": $allCompleteStr, `"test_command`": `"$TestCommand`"}"

if ($AllComplete) { exit 0 } else { exit 1 }
