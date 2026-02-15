$ErrorActionPreference = 'Stop'

# check-gh-setup.ps1 - Check GitHub CLI setup status and available methods

$ghInstalled = $false
$ghAuthenticated = $false
$githubTokenSet = $false
$repoDetected = $false
$repoOwner = ''
$repoName = ''
$preferredMethod = 'none'
$message = ''

# Check gh CLI
try {
    $null = Get-Command gh -ErrorAction Stop
    $ghInstalled = $true
    try {
        $null = & gh auth status 2>&1
        if ($LASTEXITCODE -eq 0) { $ghAuthenticated = $true }
    } catch { }
} catch { }

# Check GITHUB_TOKEN
if ($env:GITHUB_TOKEN) { $githubTokenSet = $true }

# Detect repo from git remote
try {
    $remoteUrl = git remote get-url origin 2>$null
    if ($remoteUrl) {
        if ($remoteUrl -match 'git@github\.com:([^/]+)/([^/.]+?)(?:\.git)?$') {
            $repoOwner = $Matches[1]; $repoName = $Matches[2]; $repoDetected = $true
        } elseif ($remoteUrl -match 'https://github\.com/([^/]+)/([^/.]+?)(?:\.git)?/?$') {
            $repoOwner = $Matches[1]; $repoName = $Matches[2]; $repoDetected = $true
        }
    }
} catch { }

# Determine preferred method
if ($ghInstalled -and $ghAuthenticated) {
    $preferredMethod = 'gh'
    $message = 'GitHub CLI is installed and authenticated'
} elseif ($ghInstalled -and -not $ghAuthenticated) {
    if ($githubTokenSet) {
        $preferredMethod = 'curl'
        $message = 'GitHub CLI installed but not authenticated. Using GITHUB_TOKEN fallback'
    } else {
        $preferredMethod = 'none'
        $message = "GitHub CLI installed but not authenticated. Run 'gh auth login' to authenticate"
    }
} elseif ($githubTokenSet) {
    $preferredMethod = 'curl'
    $message = 'GitHub CLI not installed. Using GITHUB_TOKEN for API access'
} else {
    $preferredMethod = 'none'
    $message = 'No GitHub access method available. Install gh CLI (https://cli.github.com) or set GITHUB_TOKEN'
}

$ghInstalledStr = if ($ghInstalled) { 'true' } else { 'false' }
$ghAuthStr = if ($ghAuthenticated) { 'true' } else { 'false' }
$tokenStr = if ($githubTokenSet) { 'true' } else { 'false' }
$repoStr = if ($repoDetected) { 'true' } else { 'false' }

Write-Output @"
{
  "gh_installed": $ghInstalledStr,
  "gh_authenticated": $ghAuthStr,
  "github_token": $tokenStr,
  "repo_detected": $repoStr,
  "repo_owner": "$repoOwner",
  "repo_name": "$repoName",
  "preferred_method": "$preferredMethod",
  "message": "$message"
}
"@

if ($preferredMethod -ne 'none') { exit 0 } else { exit 1 }
