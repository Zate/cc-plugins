$ErrorActionPreference = 'SilentlyContinue'

# Devloop statusline for Claude Code (PowerShell)
# Displays: Model | Context | Tokens | API Limits | Path | Branch | Plan | Bugs

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ANSI color codes
$RESET = "`e[0m"; $BOLD = "`e[1m"; $DIM = "`e[2m"
$CYAN = "`e[36m"; $YELLOW = "`e[33m"; $RED = "`e[31m"
$MAGENTA = "`e[35m"; $BLUE = "`e[34m"; $GREEN = "`e[32m"; $WHITE = "`e[37m"

# Read JSON input from stdin
$input = [Console]::In.ReadToEnd()

# Try parsing with ConvertFrom-Json
$data = $null
try { $data = $input | ConvertFrom-Json } catch { }

if ($null -eq $data) {
    # Fallback: regex extraction
    $ModelDisplay = ''
    if ($input -match '"display_name"\s*:\s*"([^"]*)"') { $ModelDisplay = $Matches[1] }
    if (-not $ModelDisplay) {
        Write-Output "${YELLOW}Could not parse statusline input${RESET}"
        exit 0
    }
    $CurrentDir = ''; $ProjectDir = ''
    if ($input -match '"current_dir"\s*:\s*"([^"]*)"') { $CurrentDir = $Matches[1] }
    if ($input -match '"project_dir"\s*:\s*"([^"]*)"') { $ProjectDir = $Matches[1] }
    $ContextSize = 0; $InputTokens = 0; $CacheCreate = 0; $CacheRead = 0
    $TotalInput = 0; $TotalOutput = 0
} else {
    $ModelDisplay = if ($data.model.display_name) { $data.model.display_name } else { 'Unknown' }
    $CurrentDir = if ($data.workspace.current_dir) { $data.workspace.current_dir } else { '' }
    $ProjectDir = if ($data.workspace.project_dir) { $data.workspace.project_dir } else { '' }
    $ContextSize = if ($data.context_window.context_window_size) { [int]$data.context_window.context_window_size } else { 0 }
    $InputTokens = if ($data.context_window.current_usage.input_tokens) { [int]$data.context_window.current_usage.input_tokens } else { 0 }
    $CacheCreate = if ($data.context_window.current_usage.cache_creation_input_tokens) { [int]$data.context_window.current_usage.cache_creation_input_tokens } else { 0 }
    $CacheRead = if ($data.context_window.current_usage.cache_read_input_tokens) { [int]$data.context_window.current_usage.cache_read_input_tokens } else { 0 }
    $TotalInput = if ($data.context_window.total_input_tokens) { [int]$data.context_window.total_input_tokens } else { 0 }
    $TotalOutput = if ($data.context_window.total_output_tokens) { [int]$data.context_window.total_output_tokens } else { 0 }
}

# Short path (last 2 directories)
$ShortPath = '~'
if ($CurrentDir) {
    $parts = $CurrentDir -split '[/\\]' | Where-Object { $_ }
    if ($parts.Count -ge 2) { $ShortPath = ($parts[-2..-1]) -join '/' }
    elseif ($parts.Count -eq 1) { $ShortPath = $parts[-1] }
}

# Context window percentage
$ContextDisplay = ''
if ($ContextSize -gt 0) {
    $CurrentContext = $InputTokens + $CacheCreate + $CacheRead
    $ContextPct = [math]::Floor($CurrentContext * 100 / $ContextSize)

    # Write context usage
    New-Item -ItemType Directory -Path '.claude' -Force | Out-Null
    $ts = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
    "{`"context_pct`": $ContextPct, `"current_tokens`": $CurrentContext, `"max_tokens`": $ContextSize, `"updated_at`": `"$ts`"}" | Set-Content '.claude/context-usage.json'

    # Mini progress bar
    $filled = [math]::Floor($ContextPct * 5 / 100)
    $empty = 5 - $filled
    $filledBar = ([char]0x2588).ToString() * $filled  # block char
    $emptyBar = ([char]0x2591).ToString() * $empty     # light shade

    if ($ContextPct -ge 80) {
        $ContextDisplay = "${RED}${filledBar}${DIM}${emptyBar}${RESET}${RED}${ContextPct}%${RESET}"
    } elseif ($ContextPct -ge 60) {
        $ContextDisplay = "${YELLOW}${filledBar}${DIM}${emptyBar}${RESET}${YELLOW}${ContextPct}%${RESET}"
    } else {
        $ContextDisplay = "${WHITE}${filledBar}${DIM}${emptyBar}${RESET}${ContextPct}%"
    }
}

# Session tokens
$SessionTokens = ''
$SessionTotal = $TotalInput + $TotalOutput
if ($SessionTotal -gt 0) {
    if ($SessionTotal -ge 1000000) { $SessionTokens = '{0:F1}M' -f ($SessionTotal / 1000000) }
    elseif ($SessionTotal -ge 1000) { $SessionTokens = '{0:F1}K' -f ($SessionTotal / 1000) }
    else { $SessionTokens = "$SessionTotal" }
}

# Git branch
$GitBranch = ''
$WorkDir = if ($CurrentDir) { $CurrentDir } else { (Get-Location).Path }
try {
    $branch = git -C $WorkDir branch --show-current 2>$null
    if ($branch) { $GitBranch = "${CYAN}${branch}${RESET}" }
} catch { }

# Plan progress
$PlanStatus = ''
$PlanFile = ''
$pDir = if ($ProjectDir) { $ProjectDir } else { '.' }
if (Test-Path (Join-Path $pDir '.devloop/plan.md')) { $PlanFile = Join-Path $pDir '.devloop/plan.md' }
elseif (Test-Path (Join-Path $pDir '.claude/devloop-plan.md')) { $PlanFile = Join-Path $pDir '.claude/devloop-plan.md' }

$PlanTotal = 0; $PlanDone = 0
if ($PlanFile -and (Test-Path $PlanFile)) {
    $inCode = $false
    foreach ($line in (Get-Content $PlanFile)) {
        if ($line -match '^```') { $inCode = -not $inCode; continue }
        if (-not $inCode) {
            if ($line -match '^\s*- \[[ x~!-]\]') { $PlanTotal++ }
            if ($line -match '^\s*- \[x\]') { $PlanDone++ }
            if ($line -match '^\s*- \[-\]') { $PlanDone++ }
        }
    }
}
if ($PlanTotal -gt 0) { $PlanStatus = "${MAGENTA}${PlanDone}/${PlanTotal}${RESET}" }

# Bug count
$BugCount = ''
$IssuesDir = ''
if (Test-Path (Join-Path $pDir '.devloop/issues') -PathType Container) { $IssuesDir = Join-Path $pDir '.devloop/issues' }
elseif (Test-Path (Join-Path $pDir '.claude/issues') -PathType Container) { $IssuesDir = Join-Path $pDir '.claude/issues' }
elseif (Test-Path (Join-Path $pDir '.claude/bugs') -PathType Container) { $IssuesDir = Join-Path $pDir '.claude/bugs' }

if ($IssuesDir) {
    $openBugs = 0
    Get-ChildItem "$IssuesDir/*.md" -ErrorAction SilentlyContinue | ForEach-Object {
        $c = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
        if ($c -match 'status: open') { $openBugs++ }
    }
    if ($openBugs -gt 0) { $BugCount = "${RED}${openBugs}${RESET}" }
}

# Build statusline
$ModelShort = $ModelDisplay -replace 'Claude ', '' -replace ' ', '-'
$output = "${BOLD}${ModelShort}${RESET}"

if ($ContextDisplay) { $output += " ${DIM}|${RESET} $ContextDisplay" }
if ($SessionTokens) { $output += " ${DIM}|${RESET} ${CYAN}${SessionTokens}${RESET}" }
$output += " ${DIM}|${RESET} ${BLUE}${ShortPath}${RESET}"
if ($GitBranch) { $output += " ${DIM}|${RESET} $GitBranch" }
if ($PlanStatus) { $output += " ${DIM}|${RESET} ${DIM}P:${RESET}$PlanStatus" }
if ($BugCount) { $output += " ${DIM}|${RESET} ${DIM}B:${RESET}$BugCount" }

Write-Output $output
