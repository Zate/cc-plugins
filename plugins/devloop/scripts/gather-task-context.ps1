$ErrorActionPreference = 'SilentlyContinue'

# gather-task-context.ps1 - Find relevant files for a task description

$TaskDesc = if ($args.Count -gt 0) { $args[0] } else { '' }

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
$allFiles = @()

foreach ($kw in $keywords) {
    # Search file contents
    try {
        $matches = Get-ChildItem -Recurse -File -Include $codeExts -ErrorAction SilentlyContinue |
            Where-Object { $excludeDirs | ForEach-Object { $d = $_; $_.FullName -notmatch [regex]::Escape($d) } | Where-Object { $_ } | Select-Object -First 1 } |
            Select-String -Pattern $kw -List -ErrorAction SilentlyContinue |
            Select-Object -First 5 -ExpandProperty Path
        if ($matches) { $allFiles += $matches }
    } catch { }

    # Search file names
    try {
        $nameMatches = Get-ChildItem -Recurse -File -Filter "*${kw}*" -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch 'node_modules|\.git[\\/]|\.devloop' } |
            Select-Object -First 3 -ExpandProperty FullName
        if ($nameMatches) { $allFiles += $nameMatches }
    } catch { }
}

# Deduplicate, make relative, limit
$pwd = (Get-Location).Path
$uniqueFiles = $allFiles | Sort-Object -Unique | Select-Object -First 20 | ForEach-Object {
    $_ -replace [regex]::Escape("$pwd/"), '' -replace [regex]::Escape("$pwd\"), '' -replace '^\.\/', '' -replace '^\.\\'
}

$keywordsJson = ($keywords | ForEach-Object { "`"$_`"" }) -join ','
$filesJson = ($uniqueFiles | ForEach-Object { "`"$($_ -replace '\\', '/')`"" }) -join ','

Write-Output "{`"files`": [$filesJson], `"keywords`": [$keywordsJson]}"
