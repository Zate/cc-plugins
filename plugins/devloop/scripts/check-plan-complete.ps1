$ErrorActionPreference = 'Stop'

# check-plan-complete.ps1 - Check if all plan tasks are complete
#
# Usage: check-plan-complete.ps1 [plan-file]
#
# Output (JSON):
#   {"complete": true/false, "total": N, "done": N, "pending": N, "partial": N}

$PlanFile = if ($args.Count -gt 0) { $args[0] } else { '.devloop/plan.md' }

if (-not (Test-Path $PlanFile)) {
    Write-Output '{"error": "no_plan", "message": "Plan file not found"}'
    exit 2
}

# Read file and filter out code blocks
$lines = Get-Content $PlanFile
$inCode = $false
$filtered = @()
foreach ($line in $lines) {
    if ($line -match '^```') {
        $inCode = -not $inCode
        continue
    }
    if (-not $inCode) {
        $filtered += $line
    }
}

# Count task markers
$Total = 0; $Done = 0; $Partial = 0; $Blocked = 0

foreach ($line in $filtered) {
    if ($line -match '^\s*- \[[ x~!]\]') {
        $Total++
        if ($line -match '^\s*- \[x\]') { $Done++ }
        elseif ($line -match '^\s*- \[~\]') { $Partial++ }
        elseif ($line -match '^\s*- \[!\]') { $Blocked++ }
    }
}

# Also count skipped tasks (- [-]) as done
foreach ($line in $filtered) {
    if ($line -match '^\s*- \[-\]') {
        $Total++
        $Done++
    }
}

$Pending = $Total - $Done
$Complete = ($Total -gt 0) -and ($Done -eq $Total)
$completeStr = if ($Complete) { 'true' } else { 'false' }

Write-Output "{`"complete`": $completeStr, `"total`": $Total, `"done`": $Done, `"pending`": $Pending, `"partial`": $Partial, `"blocked`": $Blocked}"

if ($Complete) { exit 0 } else { exit 1 }
