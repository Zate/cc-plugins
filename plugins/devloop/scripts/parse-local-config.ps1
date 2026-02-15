$ErrorActionPreference = 'Stop'

# Parse .devloop/local.md YAML frontmatter and return JSON config

$LocalMd = '.devloop/local.md'

$defaultConfig = @{
    git = @{ auto_branch = $false; branch_pattern = 'feat/{slug}'; main_branch = 'main'; pr_on_complete = 'ask' }
    commits = @{ style = 'conventional'; scope_from_plan = $true; sign = $false }
    review = @{ before_commit = 'ask'; use_plugin = $null }
    github = @{ link_issues = $false; auto_close = 'ask'; comment_on_complete = $true }
}

function Get-Frontmatter {
    param([string]$File)
    if (-not (Test-Path $File)) { return $null }
    $lines = Get-Content $File
    if ($lines.Count -eq 0 -or $lines[0] -ne '---') { return $null }
    $fmLines = @()
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -eq '---') { break }
        $fmLines += $lines[$i]
    }
    return $fmLines -join "`n"
}

function Convert-SimpleYamlToHashtable {
    param([string]$Yaml)
    $result = @{}
    foreach ($line in ($Yaml -split "`n")) {
        $line = $line.Trim()
        if ($line -match '^([a-zA-Z_][a-zA-Z0-9_-]*)\s*:\s*(.*)$') {
            $key = $Matches[1] -replace '-', '_'
            $val = $Matches[2].Trim()
            if ($val -eq 'true') { $result[$key] = $true }
            elseif ($val -eq 'false') { $result[$key] = $false }
            elseif ($val -match '^\d+$') { $result[$key] = [int]$val }
            elseif ($val -eq 'null' -or $val -eq '~') { $result[$key] = $null }
            else { $result[$key] = $val -replace '^["'']|["'']$', '' }
        }
    }
    return $result
}

function Merge-Hashtables {
    param($Default, $Override)
    $merged = @{}
    foreach ($key in $Default.Keys) {
        if ($Default[$key] -is [hashtable] -and $Override.ContainsKey($key) -and $Override[$key] -is [hashtable]) {
            $merged[$key] = Merge-Hashtables $Default[$key] $Override[$key]
        } elseif ($Override.ContainsKey($key)) {
            $merged[$key] = $Override[$key]
        } else {
            $merged[$key] = $Default[$key]
        }
    }
    foreach ($key in $Override.Keys) {
        if (-not $merged.ContainsKey($key)) { $merged[$key] = $Override[$key] }
    }
    return $merged
}

$userConfig = @{}
$yaml = Get-Frontmatter $LocalMd
if ($yaml) {
    $userConfig = Convert-SimpleYamlToHashtable $yaml
}

$merged = Merge-Hashtables $defaultConfig $userConfig
$merged | ConvertTo-Json -Depth 4
