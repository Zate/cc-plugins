# init-devloop.ps1 - Initialize devloop project structure (Windows)
# Triggered by: claude --init (Setup hook)
# Creates .devloop/ directory with default configuration
$ErrorActionPreference = 'Stop'

$devloopDir = '.devloop'

# Check if already initialized
if (Test-Path $devloopDir) {
    Write-Output 'devloop already initialized in this project.'
    exit 0
}

# Detect tech stack
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

function Detect-Framework {
    if (Test-Path 'package.json') {
        $pkg = Get-Content 'package.json' -Raw
        if ($pkg -match '"next"') { return 'nextjs' }
        if ($pkg -match '"react"') { return 'react' }
        if ($pkg -match '"vue"') { return 'vue' }
        if ($pkg -match '"express"') { return 'express' }
    }
    if (Test-Path 'requirements.txt') {
        $reqs = Get-Content 'requirements.txt' -Raw
        if ($reqs -match '(?i)django') { return 'django' }
        if ($reqs -match '(?i)flask') { return 'flask' }
        if ($reqs -match '(?i)fastapi') { return 'fastapi' }
    }
    return ''
}

$lang = Detect-Language
$framework = Detect-Framework
$projectName = Split-Path -Leaf (Get-Location)
$timestamp = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

# Create directory structure
New-Item -ItemType Directory -Path $devloopDir -Force | Out-Null
New-Item -ItemType Directory -Path "$devloopDir/archive" -Force | Out-Null
New-Item -ItemType Directory -Path "$devloopDir/spikes" -Force | Out-Null

# Create context.json with detected stack
$contextJson = @{
    project = $projectName
    language = $lang
    framework = $framework
    initialized_at = $timestamp
    devloop_version = '3.17.0'
} | ConvertTo-Json
Set-Content -Path "$devloopDir/context.json" -Value $contextJson

# Create default local.md (not git-tracked)
$localMd = @'
---
# Local devloop configuration (not git-tracked)
# Customize these settings for your workflow

git:
  auto-branch: false          # Create branch when plan starts
  pr-on-complete: ask         # ask | always | never

commits:
  style: conventional         # conventional | simple
  auto-commit: false          # Auto-commit at phase boundaries

review:
  before-commit: ask          # ask | always | never

github:
  link-issues: false          # Enable issue linking
  auto-close: ask             # ask | always | never

context:
  threshold: 70               # Percent context usage before suggesting /fresh
---

# Project Notes

Add project-specific notes here for devloop context.
'@
Set-Content -Path "$devloopDir/local.md" -Value $localMd

# Create .gitignore entries
$gitignore = @'
# Devloop local files (not git-tracked)
local.md
spikes/
'@
Set-Content -Path "$devloopDir/.gitignore" -Value $gitignore

# Output JSON result for hook
$frameworkSuffix = if ($framework) { " ($framework)" } else { '' }
$output = @{
    hookSpecificOutput = @{
        hookEventName = 'Setup'
        additionalContext = "devloop initialized in .devloop/ with $lang$frameworkSuffix project detected. Run /devloop to start planning."
    }
}

$output | ConvertTo-Json -Depth 5 -Compress

exit 0
