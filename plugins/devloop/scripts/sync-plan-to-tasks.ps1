$ErrorActionPreference = 'Stop'

# sync-plan-to-tasks.ps1 - Parse plan.md and output pending tasks as JSON for TaskCreate

$PlanFile = if ($args.Count -gt 0) { $args[0] } else { '.devloop/plan.md' }

if (-not (Test-Path $PlanFile)) {
    Write-Output '{"error": "no_plan", "message": "Plan file not found"}'
    exit 2
}

$lines = Get-Content $PlanFile
$phase = ''
$inCode = $false
$taskNum = 0
$tasks = @()

# Verb transformation map
$verbMap = @{
    'Create' = 'Creating'; 'Add' = 'Adding'; 'Update' = 'Updating'
    'Test' = 'Testing'; 'Document' = 'Documenting'; 'Implement' = 'Implementing'
    'Fix' = 'Fixing'; 'Remove' = 'Removing'; 'Ensure' = 'Ensuring'; 'Verify' = 'Verifying'
}

foreach ($line in $lines) {
    if ($line -match '^```') { $inCode = -not $inCode; continue }
    if ($inCode) { continue }

    # Track phase
    if ($line -match '^## Phase') {
        $phase = $line -replace '^## ', ''
    }

    # Match pending tasks
    if ($line -match '^\s*- \[ \] (.+)') {
        $taskNum++
        $desc = $Matches[1]

        # Extract task ID if present
        $taskId = "$taskNum"
        if ($desc -match '^Task (\d+\.\d+): (.+)') {
            $taskId = $Matches[1]
            $desc = $Matches[2]
        }

        # Generate activeForm
        $active = "Working on $desc"
        if ($desc -match '^([A-Z][a-z]+)(.*)') {
            $verb = $Matches[1]
            $rest = $Matches[2]
            if ($verbMap.ContainsKey($verb)) {
                $active = "$($verbMap[$verb])$rest"
            }
        }

        $tasks += @{
            id = $taskId
            subject = $desc
            phase = $phase
            activeForm = $active
        }
    }
}

# Output as JSON array
$jsonTasks = $tasks | ForEach-Object {
    $s = $_.subject -replace '\\', '\\\\' -replace '"', '\"'
    $p = $_.phase -replace '\\', '\\\\' -replace '"', '\"'
    $a = $_.activeForm -replace '\\', '\\\\' -replace '"', '\"'
    "  {`"id`": `"$($_.id)`", `"subject`": `"$s`", `"phase`": `"$p`", `"activeForm`": `"$a`"}"
}

Write-Output '['
Write-Output ($jsonTasks -join ",`n")
Write-Output ']'
