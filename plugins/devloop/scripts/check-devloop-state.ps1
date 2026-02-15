$ErrorActionPreference = 'Stop'

# check-devloop-state.ps1 - Detect current devloop state for smart command routing
#
# Usage: check-devloop-state.ps1
#
# Output (JSON): state, priority, details, suggestions

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$State = 'clean'
$Priority = 7
$Details = @{ message = 'Ready for new work' }
$Suggestions = @('Start new spike', 'Create new issue', 'View GitHub issues', 'Quick task')

function ConvertTo-JsonArray { param([string[]]$Items) return ($Items | ForEach-Object { "`"$_`"" }) -join ',' }

# Check 1: Is devloop set up?
if (-not (Test-Path '.devloop' -PathType Container)) {
    $State = 'not_setup'
    $Priority = 1
    $Details = @{ message = 'No .devloop directory found' }
    $Suggestions = @('Set up devloop', 'Create first spike', 'Start new task')
} else {
    # Check 2: Active plan?
    if (Test-Path '.devloop/plan.md') {
        $planOutput = ''
        try {
            $planOutput = & "$ScriptDir/check-plan-complete.ps1" '.devloop/plan.md' 2>$null
        } catch { }
        if (-not $planOutput) { $planOutput = '{"complete": false, "total": 0, "done": 0, "pending": 0}' }

        $planComplete = $false
        $planTotal = 0; $planDone = 0; $planPending = 0

        if ($planOutput -match '"complete":\s*(true|false)') { $planComplete = $Matches[1] -eq 'true' }
        if ($planOutput -match '"total":\s*(\d+)') { $planTotal = [int]$Matches[1] }
        if ($planOutput -match '"done":\s*(\d+)') { $planDone = [int]$Matches[1] }
        if ($planOutput -match '"pending":\s*(\d+)') { $planPending = [int]$Matches[1] }

        $planTitle = (Get-Content '.devloop/plan.md' -TotalCount 1) -replace '^# ', '' -replace '^Devloop Plan: ', ''

        $nextTask = ''
        $planLines = Get-Content '.devloop/plan.md'
        foreach ($l in $planLines) {
            if ($l -match '^\s*- \[ \] (.+)') {
                $nextTask = $Matches[1]
                break
            }
        }

        if (-not $planComplete -and $planTotal -gt 0) {
            $State = 'active_plan'
            $Priority = 2
            $Details = @{ plan_title = $planTitle; total = $planTotal; done = $planDone; pending = $planPending; next_task = $nextTask }
            $Suggestions = @('Continue plan', 'Ship current progress', 'View plan', 'Start fresh')
        } elseif ($planComplete) {
            $State = 'complete_plan'
            $Priority = 6
            $Details = @{ plan_title = $planTitle; total = $planTotal }
            $Suggestions = @('Archive and start new', 'Ship completed work', 'Review before shipping')
        }
    }

    # Check 3: Uncommitted git changes
    if ($State -eq 'clean' -or $State -eq 'complete_plan') {
        try {
            $gitChanges = (git status --porcelain 2>$null | Measure-Object -Line).Lines
            if ($gitChanges -gt 0 -and $State -ne 'active_plan') {
                $State = 'uncommitted'
                $Priority = 3
                $Details = @{ total_changes = $gitChanges }
                $Suggestions = @('Commit changes', 'Review changes', 'Start new work', 'Stash and continue')
            }
        } catch { }
    }

    # Check 4: Open bugs
    if ($State -eq 'clean' -and (Test-Path '.devloop/issues' -PathType Container)) {
        $bugCount = 0
        $issueFiles = Get-ChildItem '.devloop/issues/*.md' -ErrorAction SilentlyContinue
        foreach ($f in $issueFiles) {
            $content = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue
            if ($content -match 'type: bug' -and $content -match 'status: open') { $bugCount++ }
        }
        if ($bugCount -gt 0) {
            $State = 'open_bugs'
            $Priority = 4
            $Details = @{ bug_count = $bugCount }
            $Suggestions = @('Fix a bug', 'View open bugs', 'Start new feature', 'Create spike')
        }
    }

    # Check 5: Features in backlog
    if ($State -eq 'clean' -and (Test-Path '.devloop/issues' -PathType Container)) {
        $featureCount = 0
        $issueFiles = Get-ChildItem '.devloop/issues/*.md' -ErrorAction SilentlyContinue
        foreach ($f in $issueFiles) {
            $content = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue
            if ($content -match 'type: feature' -and $content -match 'status: open') { $featureCount++ }
        }
        if ($featureCount -gt 0) {
            $State = 'backlog'
            $Priority = 5
            $Details = @{ feature_count = $featureCount }
            $Suggestions = @('Work on backlog item', 'View backlog', 'Create new spike', 'Start fresh task')
        }
    }
}

# Output
$suggestionsJson = '[' + (ConvertTo-JsonArray $Suggestions) + ']'
$detailsJson = $Details | ConvertTo-Json -Compress

Write-Output "devloop: state=$State priority=$Priority"
Write-Output "{`"state`": `"$State`", `"priority`": $Priority, `"details`": $detailsJson, `"suggestions`": $suggestionsJson}"
