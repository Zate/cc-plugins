$ErrorActionPreference = 'Stop'

# list-issues.ps1 - List GitHub issues for the current repository

$State = 'open'
$Labels = @()
$Assignee = ''
$Limit = 30
$JsonOutput = $false

# Parse arguments
$i = 0
while ($i -lt $args.Count) {
    switch ($args[$i]) {
        '--state'    { $State = $args[++$i] }
        '--label'    { $Labels += $args[++$i] }
        '--assignee' { $Assignee = $args[++$i] }
        '--limit'    { $Limit = $args[++$i] }
        '--json'     { $JsonOutput = $true }
        default      { Write-Error "Unknown option: $($args[$i])"; exit 1 }
    }
    $i++
}

# Check gh CLI
try { $null = Get-Command gh -ErrorAction Stop } catch {
    Write-Error '{"error": "gh_not_found", "message": "GitHub CLI (gh) is required."}'
    exit 1
}

# Check repo
try { $null = gh repo view 2>$null; if ($LASTEXITCODE -ne 0) { throw } } catch {
    Write-Error '{"error": "not_github_repo", "message": "Not in a GitHub repository or not authenticated."}'
    exit 2
}

# Build args
$ghArgs = @('issue', 'list', '--state', $State, '--limit', $Limit)
foreach ($label in $Labels) { $ghArgs += @('--label', $label) }
if ($Assignee) { $ghArgs += @('--assignee', $Assignee) }
$ghArgs += @('--json', 'number,title,labels,assignees,createdAt,state')

$issuesJson = & gh @ghArgs 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "{`"error`": `"gh_error`", `"message`": `"$issuesJson`"}"
    exit 3
}

$issues = $issuesJson | ConvertFrom-Json
$count = $issues.Count

Write-Output "issues: $State count=$count"

if ($JsonOutput) {
    Write-Output $issuesJson
} else {
    if ($count -eq 0) {
        Write-Output 'No issues found matching criteria.'
    } else {
        $stateTitle = (Get-Culture).TextInfo.ToTitleCase($State)
        Write-Output "# $stateTitle Issues ($count)"
        Write-Output ''
        foreach ($issue in $issues) {
            $num = "#$($issue.number)".PadRight(6)
            $labelStr = ''
            if ($issue.labels.Count -gt 0) {
                $labelNames = ($issue.labels | Select-Object -First 2 | ForEach-Object { $_.name.Substring(0, [Math]::Min(10, $_.name.Length)) }) -join ','
                $labelStr = "[$labelNames]"
            }
            $labelStr = $labelStr.PadRight(16)
            $title = $issue.title
            if ($title.Length -gt 45) { $title = $title.Substring(0, 45) }
            $title = $title.PadRight(46)
            $assignee = if ($issue.assignees.Count -gt 0) { "@$($issue.assignees[0].login)" } else { '-' }
            $assignee = $assignee.PadRight(14).Substring(0, 14)
            $created = [DateTime]::Parse($issue.createdAt)
            $ago = (Get-Date) - $created
            $timeStr = if ($ago.TotalMinutes -lt 60) { "$([math]::Floor($ago.TotalMinutes))m ago" }
                       elseif ($ago.TotalHours -lt 24) { "$([math]::Floor($ago.TotalHours))h ago" }
                       elseif ($ago.TotalDays -lt 7) { "$([math]::Floor($ago.TotalDays))d ago" }
                       elseif ($ago.TotalDays -lt 30) { "$([math]::Floor($ago.TotalDays / 7))w ago" }
                       else { "$([math]::Floor($ago.TotalDays / 30))mo ago" }
            Write-Output "$num $labelStr $title $assignee $timeStr"
        }
    }
}
