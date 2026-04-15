$ErrorActionPreference = 'SilentlyContinue'

# gather-task-context.ps1 - Find relevant files for a task description
#
# Usage:
#   ./gather-task-context.ps1 "task description text" [--token-budget N]
#
# Output (JSON):
#   {"files": ["path1", "path2", ...], "keywords": ["kw1", "kw2", ...]}
#
# Extracts keywords from the task description and searches the codebase
# for relevant files. Returns files prioritized by relevance, capped at
# the token budget (default 4000 tokens, ~4 chars per token).
#
# Priority order:
#   1. Files directly mentioned in the task description (by name)
#   2. Files matching keywords in content/filename
#
# --token-budget N: Estimate tokens per file (~4 chars/token) and stop
#   collecting when the budget is reached. Default: 4000 tokens.

$TaskDesc = if ($args.Count -gt 0) { $args[0] } else { '' }
$TokenBudget = 4000

# Parse optional --token-budget argument
for ($i = 1; $i -lt $args.Count; $i++) {
    if ($args[$i] -eq '--token-budget' -and ($i + 1) -lt $args.Count) {
        $TokenBudget = [int]$args[$i + 1]
        $i++
    }
}

if (-not $TaskDesc) {
    Write-Output '{"files": [], "keywords": [], "error": "No task description provided"}'
    exit 1
}

# Stop words to filter out
$stopWords = @('the','a','an','to','in','for','of','and','or','is','it','this','that','with','from',
    'as','on','at','by','be','do','if','no','not','but','all','can','has','may','new','one','our',
    'out','own','say','she','too','use','her','was','add','create','update','replace','remove',
    'fix','write','implement','task','step')

# Extract keywords
$keywords = ($TaskDesc.ToLower() -replace '[^a-z0-9_ -]', '' -split '\s+') |
    Where-Object { $_.Length -ge 3 -and $_ -notin $stopWords } |
    Sort-Object -Unique |
    Select-Object -First 10

if ($keywords.Count -eq 0) {
    Write-Output '{"files": [], "keywords": [], "error": "No keywords extracted"}'
    exit 0
}

$codeExts = @('*.md','*.sh','*.ts','*.js','*.py','*.go','*.json','*.yaml','*.yml','*.toml','*.ps1')
$excludeDirs = @('node_modules','.git','.devloop')
$CharBudget = $TokenBudget * 4
$budgetUsed = 0

# Phase 1: Directly mentioned files (highest priority)
$directFiles = @()
foreach ($kw in $keywords) {
    try {
        $direct = Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object {
                ($_.Name -eq $kw -or $_.BaseName -eq $kw) -and
                ($_.FullName -notmatch 'node_modules|\.git[\\/]|\.devloop')
            } |
            Select-Object -First 3 -ExpandProperty FullName
        if ($direct) { $directFiles += $direct }
    } catch { }
}

# Phase 2: Keyword matches in content and filenames
$keywordFiles = @()
foreach ($kw in $keywords) {
    # Search file contents
    try {
        $matches = Get-ChildItem -Recurse -File -Include $codeExts -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch 'node_modules|\.git[\\/]|\.devloop' } |
            Select-String -Pattern $kw -List -ErrorAction SilentlyContinue |
            Select-Object -First 5 -ExpandProperty Path
        if ($matches) { $keywordFiles += $matches }
    } catch { }

    # Search file names
    try {
        $nameMatches = Get-ChildItem -Recurse -File -Filter "*${kw}*" -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch 'node_modules|\.git[\\/]|\.devloop' } |
            Select-Object -First 3 -ExpandProperty FullName
        if ($nameMatches) { $keywordFiles += $nameMatches }
    } catch { }
}

# Merge: direct files first (highest priority), then keyword matches
$allFiles = $directFiles + $keywordFiles

# Deduplicate and normalize paths
$pwd = (Get-Location).Path
$seen = @{}
$uniqueFiles = @()
foreach ($f in $allFiles) {
    $rel = $f -replace [regex]::Escape("$pwd/"), '' -replace [regex]::Escape("$pwd\"), '' -replace '^\.\/', '' -replace '^\.\\'
    $rel = $rel -replace '\\', '/'
    if (-not $seen.ContainsKey($rel)) {
        $seen[$rel] = $true
        $uniqueFiles += $rel
    }
}

# Apply token budget: estimate file size and stop when budget exhausted
$selectedFiles = @()
foreach ($fpath in $uniqueFiles) {
    $fullPath = Join-Path $pwd $fpath
    $fileSize = 0
    if (Test-Path $fullPath) {
        try { $fileSize = (Get-Item $fullPath).Length } catch { }
    }
    $budgetUsed += $fileSize
    $selectedFiles += $fpath
    if ($budgetUsed -ge $CharBudget) { break }
}

# Final list: capped at 20
$finalFiles = $selectedFiles | Select-Object -First 20

$keywordsJson = ($keywords | ForEach-Object { "`"$_`"" }) -join ','
$filesJson = ($finalFiles | ForEach-Object { "`"$_`"" }) -join ','

Write-Output "{`"files`": [$filesJson], `"keywords`": [$keywordsJson]}"
