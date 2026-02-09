# Devloop SessionStart hook (Windows) - v3.1 with local config support
# Quick project detection, no heavy processing
# Optimized for speed and low token overhead
$ErrorActionPreference = 'Stop'

# ============================================================================
# Fast Detection Functions
# ============================================================================

function Detect-Language {
    if (Test-Path 'go.mod') { return 'go' }
    if (Test-Path 'package.json') {
        if (Test-Path 'tsconfig.json') { return 'typescript' }
        return 'javascript'
    }
    if ((Test-Path 'requirements.txt') -or (Test-Path 'pyproject.toml')) { return 'python' }
    if ((Test-Path 'pom.xml') -or (Test-Path 'build.gradle')) { return 'java' }
    if (Test-Path 'Cargo.toml') { return 'rust' }
    return 'unknown'
}

function Get-ProjectName {
    return (Split-Path -Leaf (Get-Location))
}

function Get-PlanStatus {
    if (-not (Test-Path '.devloop/plan.md')) { return 'none' }
    $content = Get-Content '.devloop/plan.md' -Raw
    # Filter out code blocks before counting tasks
    $inCode = $false
    $filtered = @()
    foreach ($line in ($content -split "`n")) {
        if ($line -match '^```') { $inCode = -not $inCode; continue }
        if (-not $inCode) { $filtered += $line }
    }
    $all = $filtered | Where-Object { $_ -match '^\s*- \[[ x~!-]\]' }
    $done = $filtered | Where-Object { $_ -match '^\s*- \[x\]' }
    $skipped = $filtered | Where-Object { $_ -match '^\s*- \[-\]' }
    $total = if ($all) { @($all).Count } else { 0 }
    $doneCount = if ($done) { @($done).Count } else { 0 }
    $skippedCount = if ($skipped) { @($skipped).Count } else { 0 }
    $doneCount += $skippedCount
    return "$doneCount/$total"
}

function Check-FreshStart {
    if (Test-Path '.devloop/next-action.json') { return 'true' }
    return 'false'
}

function Get-GitBranch {
    try { return (& git branch --show-current 2>$null) } catch { return '' }
}

function Get-GitWorkflowConfig {
    if (-not (Test-Path '.devloop/local.md')) { return '' }
    $content = Get-Content '.devloop/local.md' -Raw
    if ($content -match 'auto-branch:\s*true' -or $content -match 'auto_branch:\s*true') {
        return 'git-flow'
    }
    return ''
}

function Get-PrStatus {
    $branch = ''
    try { $branch = & git branch --show-current 2>$null } catch {}
    if (-not $branch -or $branch -eq 'main' -or $branch -eq 'master') { return '' }

    $ghCmd = Get-Command gh -ErrorAction SilentlyContinue
    if (-not $ghCmd) { return '' }

    try {
        $prInfo = & gh pr view --json number,reviewDecision,state 2>$null
        if ($prInfo) {
            $pr = $prInfo | ConvertFrom-Json
            if ($pr.state -eq 'OPEN' -and $pr.number) {
                if ($pr.reviewDecision -and $pr.reviewDecision -ne 'null') {
                    return "PR #$($pr.number) ($($pr.reviewDecision))"
                }
                return "PR #$($pr.number)"
            }
        }
    } catch {}
    return ''
}

function Get-LinkedIssueStatus {
    if (-not (Test-Path '.devloop/plan.md')) { return '' }
    $lines = Get-Content '.devloop/plan.md'
    $issueLine = $lines | Where-Object { $_ -match '^\*\*Issue\*\*:' } | Select-Object -First 1
    if (-not $issueLine) { return '' }

    if ($issueLine -match '#(\d+)') {
        $issueNum = $Matches[1]
        $ghCmd = Get-Command gh -ErrorAction SilentlyContinue
        if ($ghCmd) {
            try {
                $state = & gh issue view $issueNum --json state -q '.state' 2>$null
                if ($state) { return "Issue #$issueNum ($state)" }
            } catch {}
        }
        return "Issue #$issueNum"
    }
    return ''
}

function Check-StatuslineConfigured {
    $settingsFile = Join-Path $env:USERPROFILE '.claude\settings.json'
    if (-not (Test-Path $settingsFile)) { return 'unknown' }
    try {
        $settings = Get-Content $settingsFile -Raw | ConvertFrom-Json
        $cmd = $settings.statusLine.command
        if ($cmd -and $cmd -match 'devloop') { return 'configured' }
        if ($cmd) { return 'other' }
        return 'none'
    } catch { return 'unknown' }
}

# ============================================================================
# Main Execution
# ============================================================================

$lang = Detect-Language
$project = Get-ProjectName
$plan = Get-PlanStatus
$fresh = Check-FreshStart
$branch = Get-GitBranch
$gitWorkflow = Get-GitWorkflowConfig
$prStatus = Get-PrStatus
$issueStatus = Get-LinkedIssueStatus
$statuslineStatus = Check-StatuslineConfigured

# Build minimal context message
$context = "## devloop v3.0`n`n**Project**: $project"
if ($lang -ne 'unknown') { $context += " ($lang)" }
if ($branch) { $context += " | branch: $branch" }

if ($plan -ne 'none') {
    $context += "`n**Plan**: $plan tasks complete"
}

if ($prStatus) {
    $context += "`n**PR**: $prStatus"
}

if ($issueStatus) {
    $context += "`n**Linked**: $issueStatus"
}

if ($fresh -eq 'true') {
    $context += "`n`n**Fresh start detected** -> Run ``/devloop:continue`` to resume"
}

$context += "`n`n**Commands**: /devloop, /devloop:continue, /devloop:spike, /devloop:fresh"

if ($gitWorkflow) {
    $context += ', /devloop:ship'
}

$context += "`n**Skills**: Load on demand with ``Skill: skill-name`` (see skills/INDEX.md)"

if ($statuslineStatus -eq 'none' -or $statuslineStatus -eq 'unknown') {
    $context += "`n`n**Tip**: Run ``/devloop:statusline`` to enable the devloop statusline"
}

# Build status line
$status = "devloop: $project"
if ($lang -ne 'unknown') { $status += " ($lang)" }
if ($plan -ne 'none') { $status += " | plan: $plan" }
if ($prStatus) { $status += " | $prStatus" }

# Output JSON
$output = @{
    suppressOutput = $true
    systemMessage = $status
    hookSpecificOutput = @{
        hookEventName = 'SessionStart'
        additionalContext = $context
    }
}

$output | ConvertTo-Json -Depth 5 -Compress
