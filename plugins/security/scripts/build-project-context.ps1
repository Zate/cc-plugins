$ErrorActionPreference = 'Stop'

# build-project-context.ps1
# Detects project tech stack and generates .claude/project-context.json
#
# Usage: build-project-context.ps1 [project_dir]

$ProjectDir = if ($args.Count -gt 0) { $args[0] } else { '.' }
$ProjectDir = Resolve-Path $ProjectDir -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path
if (-not $ProjectDir) { $ProjectDir = '.' }

$OutputFile = Join-Path $ProjectDir '.claude' 'project-context.json'
New-Item -ItemType Directory -Path (Join-Path $ProjectDir '.claude') -Force | Out-Null

$Languages = @()
$Frameworks = @()
$ProjectName = Split-Path -Leaf (Resolve-Path $ProjectDir)
$ProjectType = 'other'

$Features = @{
    authentication = $false
    oauth = $false
    'file-upload' = $false
    websockets = $false
    database = $false
    api = $false
    graphql = $false
    payments = $false
    email = $false
    logging = $false
}

$SourceDir = $null
$TestsDir = $null
$ConfigDir = $null
$SecurityNotes = @()

function Test-ProjectFile { param([string]$RelPath) Test-Path (Join-Path $ProjectDir $RelPath) -PathType Leaf }
function Test-ProjectDir { param([string]$RelPath) Test-Path (Join-Path $ProjectDir $RelPath) -PathType Container }
function Test-HasFiles {
    param([string]$Pattern)
    $found = Get-ChildItem -Path $ProjectDir -Filter $Pattern -Recurse -Depth 2 -ErrorAction SilentlyContinue | Select-Object -First 1
    return $null -ne $found
}
function Search-ProjectFile {
    param([string]$RelPath, [string]$Pattern)
    $fullPath = Join-Path $ProjectDir $RelPath
    if (Test-Path $fullPath) {
        return (Select-String -Path $fullPath -Pattern $Pattern -Quiet -ErrorAction SilentlyContinue)
    }
    return $false
}

# Language Detection
if ((Test-ProjectFile 'tsconfig.json') -or (Test-HasFiles '*.ts')) { $Languages += 'typescript' }
if ((Test-ProjectFile 'package.json') -or (Test-HasFiles '*.js')) { $Languages += 'javascript' }
if ((Test-ProjectFile 'requirements.txt') -or (Test-ProjectFile 'pyproject.toml') -or (Test-ProjectFile 'setup.py')) { $Languages += 'python' }
if (Test-ProjectFile 'go.mod') { $Languages += 'go' }
if (Test-ProjectFile 'Cargo.toml') { $Languages += 'rust' }
if ((Test-ProjectFile 'pom.xml') -or (Test-ProjectFile 'build.gradle') -or (Test-ProjectFile 'build.gradle.kts')) { $Languages += 'java' }
if (Test-ProjectFile 'Gemfile') { $Languages += 'ruby' }
if (Test-ProjectFile 'composer.json') { $Languages += 'php' }
if (Test-HasFiles '*.sh') { $Languages += 'shell' }

# Node Framework Detection
if (Test-ProjectFile 'package.json') {
    if (Search-ProjectFile 'package.json' '"express"') { $Frameworks += 'express' }
    if (Search-ProjectFile 'package.json' '"fastify"') { $Frameworks += 'fastify' }
    if (Search-ProjectFile 'package.json' '"koa"') { $Frameworks += 'koa' }
    if (Search-ProjectFile 'package.json' '"nest') { $Frameworks += 'nestjs' }
    if (Search-ProjectFile 'package.json' '"next"') { $Frameworks += 'nextjs' }
    if (Search-ProjectFile 'package.json' '"react"') { $Frameworks += 'react' }
    if (Search-ProjectFile 'package.json' '"vue"') { $Frameworks += 'vue' }
    if (Search-ProjectFile 'package.json' '"@angular/core"') { $Frameworks += 'angular' }
    if (Search-ProjectFile 'package.json' '"svelte"') { $Frameworks += 'svelte' }
    if (Search-ProjectFile 'package.json' '"prisma"') { $Frameworks += 'prisma' }
    if (Search-ProjectFile 'package.json' '"typeorm"') { $Frameworks += 'typeorm' }
    if (Search-ProjectFile 'package.json' '"sequelize"') { $Frameworks += 'sequelize' }
    if (Search-ProjectFile 'package.json' '"mongoose"') { $Frameworks += 'mongoose' }
    if (Search-ProjectFile 'package.json' '"jest"') { $Frameworks += 'jest' }
    if (Search-ProjectFile 'package.json' '"mocha"') { $Frameworks += 'mocha' }
    if (Search-ProjectFile 'package.json' '"vitest"') { $Frameworks += 'vitest' }

    # Feature detection from package.json
    if (Search-ProjectFile 'package.json' '"(passport|jsonwebtoken|bcrypt|argon2|express-session)"') { $Features.authentication = $true }
    if (Search-ProjectFile 'package.json' '"(passport-oauth|passport-google|passport-github|openid-client)"') { $Features.oauth = $true }
    if (Search-ProjectFile 'package.json' '"(multer|formidable|busboy)"') { $Features.'file-upload' = $true }
    if (Search-ProjectFile 'package.json' '"(socket\.io|ws|websocket)"') { $Features.websockets = $true }
    if (Search-ProjectFile 'package.json' '"(pg|mysql|mysql2|mongodb|mongoose|prisma|typeorm|sequelize|sqlite)"') { $Features.database = $true }
    if (Search-ProjectFile 'package.json' '"(apollo-server|graphql|@graphql)"') { $Features.graphql = $true }
    if (Search-ProjectFile 'package.json' '"(stripe|paypal|braintree)"') { $Features.payments = $true }
    if (Search-ProjectFile 'package.json' '"(nodemailer|sendgrid|mailgun)"') { $Features.email = $true }
    if (Search-ProjectFile 'package.json' '"(winston|bunyan|pino|morgan)"') { $Features.logging = $true }
}

# Python Framework Detection
$pyReqFile = $null
if (Test-ProjectFile 'requirements.txt') { $pyReqFile = 'requirements.txt' }
elseif (Test-ProjectFile 'pyproject.toml') { $pyReqFile = 'pyproject.toml' }
if ($pyReqFile) {
    if (Search-ProjectFile $pyReqFile 'django') { $Frameworks += 'django' }
    if (Search-ProjectFile $pyReqFile 'flask') { $Frameworks += 'flask' }
    if (Search-ProjectFile $pyReqFile 'fastapi') { $Frameworks += 'fastapi' }
    if (Search-ProjectFile $pyReqFile 'sqlalchemy') { $Frameworks += 'sqlalchemy' }
    if (Search-ProjectFile $pyReqFile 'pytest') { $Frameworks += 'pytest' }
}

# Go Framework Detection
if (Test-ProjectFile 'go.mod') {
    if (Search-ProjectFile 'go.mod' 'gin-gonic/gin') { $Frameworks += 'gin' }
    if (Search-ProjectFile 'go.mod' 'gofiber/fiber') { $Frameworks += 'fiber' }
    if (Search-ProjectFile 'go.mod' 'labstack/echo') { $Frameworks += 'echo' }
    if (Search-ProjectFile 'go.mod' 'gorm.io/gorm') { $Frameworks += 'gorm' }
}

# Java Framework Detection
if (Test-ProjectFile 'pom.xml') {
    if (Search-ProjectFile 'pom.xml' 'spring-boot') { $Frameworks += 'spring-boot' }
}
if ((Test-ProjectFile 'build.gradle') -or (Test-ProjectFile 'build.gradle.kts')) {
    $gradleFile = if (Test-ProjectFile 'build.gradle.kts') { 'build.gradle.kts' } else { 'build.gradle' }
    if (Search-ProjectFile $gradleFile 'spring') { $Frameworks += 'spring-boot' }
}

# Ruby Framework Detection
if (Test-ProjectFile 'Gemfile') {
    if (Search-ProjectFile 'Gemfile' 'rails') { $Frameworks += 'rails' }
    if (Search-ProjectFile 'Gemfile' 'sinatra') { $Frameworks += 'sinatra' }
}

# PHP Framework Detection
if (Test-ProjectFile 'composer.json') {
    if (Search-ProjectFile 'composer.json' 'laravel/framework') { $Frameworks += 'laravel' }
    if (Search-ProjectFile 'composer.json' 'symfony/') { $Frameworks += 'symfony' }
}

# API detection
if ((Test-ProjectDir 'routes') -or (Test-ProjectDir 'api') -or (Test-ProjectDir 'controllers')) { $Features.api = $true }

# Security notes
if ($Features.payments) { $SecurityNotes += 'Payment processing detected - PCI DSS considerations apply' }
if ($Features.'file-upload') { $SecurityNotes += 'File uploads detected - validate types and scan for malware' }
if ($Features.authentication) { $SecurityNotes += 'Authentication detected - review credential storage and session management' }
if ($Features.database) { $SecurityNotes += 'Database access detected - review for SQL injection and data protection' }

# Directory Detection
foreach ($dir in 'src','lib','app','source','pkg') {
    if (Test-ProjectDir $dir) { $SourceDir = "$dir/"; break }
}
foreach ($dir in 'tests','test','__tests__','spec','specs') {
    if (Test-ProjectDir $dir) { $TestsDir = "$dir/"; break }
}
foreach ($dir in 'config','configs','conf','.config') {
    if (Test-ProjectDir $dir) { $ConfigDir = "$dir/"; break }
}

# Project Type Classification
if ((Test-ProjectFile 'package.json') -and (Search-ProjectFile 'package.json' '"bin"')) {
    $ProjectType = 'cli'
} elseif ((Test-ProjectFile 'package.json') -and (Search-ProjectFile 'package.json' '"main"') -and -not (Search-ProjectFile 'package.json' '"start"')) {
    $ProjectType = 'library'
} elseif ((Test-ProjectFile 'app.json') -or (Test-ProjectFile 'expo.json') -or (Test-ProjectDir 'ios') -or (Test-ProjectDir 'android')) {
    $ProjectType = 'mobile'
} elseif ($Frameworks | Where-Object { $_ -in 'react','vue','angular','svelte' }) {
    $ProjectType = 'web-app'
} elseif ($Frameworks | Where-Object { $_ -in 'express','fastify','django','flask','fastapi','gin','spring-boot','rails','laravel' }) {
    $ProjectType = 'web-api'
} elseif ((Test-ProjectDir '.claude-plugin') -or (Test-ProjectDir 'plugins')) {
    $ProjectType = 'plugin'
}

# Build JSON output
$timestamp = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$directories = @{}
if ($SourceDir) { $directories.source = $SourceDir }
if ($TestsDir) { $directories.tests = $TestsDir }
if ($ConfigDir) { $directories.config = $ConfigDir }

$result = @{
    name = $ProjectName
    type = $ProjectType
    languages = $Languages
    frameworks = $Frameworks
    features = $Features
    directories = $directories
    detected_at = $timestamp
    security_notes = $SecurityNotes
}

$json = $result | ConvertTo-Json -Depth 4
$json | Set-Content -Path $OutputFile -Encoding UTF8

Write-Error "Detecting project context for: $ProjectDir" -ErrorAction SilentlyContinue
Write-Error "Project context saved to: $OutputFile" -ErrorAction SilentlyContinue
Write-Error "Summary:" -ErrorAction SilentlyContinue
Write-Error "  Type: $ProjectType" -ErrorAction SilentlyContinue
Write-Error "  Languages: $(if ($Languages.Count -gt 0) { $Languages -join ',' } else { 'none detected' })" -ErrorAction SilentlyContinue
Write-Error "  Frameworks: $(if ($Frameworks.Count -gt 0) { $Frameworks -join ',' } else { 'none detected' })" -ErrorAction SilentlyContinue

Write-Output $json
