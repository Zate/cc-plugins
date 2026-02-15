$ErrorActionPreference = 'Stop'

# Security Guard - Fast Security Validation Script (PowerShell)
# Used by hooks for real-time security checks on code changes
#
# Usage: validate-security.ps1 [file_path] [--quick|--full]
#
# Exit codes:
#   0 - No issues found
#   1 - Critical security issues (block)
#   2 - High severity issues (warn)
#   3 - Medium severity issues (info)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PluginRoot = Split-Path -Parent $ScriptDir

# Track findings
$script:CriticalCount = 0
$script:HighCount = 0
$script:MediumCount = 0
$script:Findings = @()

function Test-FilePath {
    param([string]$File)
    if ([string]::IsNullOrWhiteSpace($File)) { return $false }
    if ($File -match '[\$`|;&<>!()\{\}\[\]''"]') {
        Write-Error "Warning: Skipping file with suspicious characters: $($File.Substring(0, [Math]::Min(50, $File.Length)))..." -ErrorAction SilentlyContinue
        return $false
    }
    return $true
}

function Add-Finding {
    param(
        [string]$Severity,
        [string]$Message,
        [string]$File,
        [string]$Line = ''
    )
    $location = if ($Line) { "${File}:${Line}" } else { $File }
    $escapedMsg = $Message -replace '\\', '\\\\' -replace '"', '\"'
    $escapedLoc = $location -replace '\\', '\\\\' -replace '"', '\"'
    $script:Findings += "[$Severity] $escapedMsg ($escapedLoc)"
    switch ($Severity) {
        'CRITICAL' { $script:CriticalCount++ }
        'HIGH' { $script:HighCount++ }
        'MEDIUM' { $script:MediumCount++ }
    }
}

function Search-Pattern {
    param(
        [string]$File,
        [string]$Pattern,
        [string]$Severity,
        [string]$Message
    )
    try {
        $matches = Select-String -Path $File -Pattern $Pattern -ErrorAction SilentlyContinue
        foreach ($m in $matches) {
            Add-Finding -Severity $Severity -Message $Message -File $File -Line $m.LineNumber
        }
    } catch { }
}

function Test-Secrets {
    param([string]$File)
    Search-Pattern $File '(api[_-]?key|apikey)\s*[:=]\s*[''"][a-zA-Z0-9]{16,}[''"]' 'CRITICAL' 'Hardcoded API key detected'
    Search-Pattern $File 'AKIA[A-Z0-9]{16}' 'CRITICAL' 'AWS access key detected'
    Search-Pattern $File 'BEGIN.*PRIVATE KEY' 'CRITICAL' 'Private key detected'
    try {
        $pwMatches = Select-String -Path $File -Pattern '(password|passwd|pwd)\s*[:=]\s*[''"][^''"]{8,}[''"]' -ErrorAction SilentlyContinue
        foreach ($m in $pwMatches) {
            if ($m.Line -notmatch '(example|placeholder|your[_-]?password|changeme|test)') {
                Add-Finding -Severity 'HIGH' -Message 'Hardcoded password detected' -File $File -Line $m.LineNumber
            }
        }
    } catch { }
}

function Test-SqlInjection {
    param([string]$File)
    $ext = [System.IO.Path]::GetExtension($File).TrimStart('.')
    switch ($ext) {
        'py' {
            Search-Pattern $File 'f["\x27]SELECT|f["\x27]INSERT|f["\x27]UPDATE|f["\x27]DELETE' 'CRITICAL' 'SQL injection risk - f-string in SQL query'
            Search-Pattern $File '(SELECT|INSERT|UPDATE|DELETE).*%\s*\(' 'CRITICAL' 'SQL injection risk - string formatting in query'
        }
        { $_ -in 'js','ts','jsx','tsx' } {
            Search-Pattern $File '`SELECT.*\$\{|`INSERT.*\$\{|`UPDATE.*\$\{|`DELETE.*\$\{' 'CRITICAL' 'SQL injection risk - template literal in SQL query'
        }
        'java' {
            Search-Pattern $File '"SELECT.*"\s*\+|"INSERT.*"\s*\+|"UPDATE.*"\s*\+|"DELETE.*"\s*\+' 'CRITICAL' 'SQL injection risk - string concatenation in query'
        }
        'go' {
            Search-Pattern $File 'fmt\.Sprintf.*SELECT|fmt\.Sprintf.*INSERT' 'CRITICAL' 'SQL injection risk - fmt.Sprintf in SQL query'
        }
    }
}

function Test-CommandInjection {
    param([string]$File)
    $ext = [System.IO.Path]::GetExtension($File).TrimStart('.')
    switch ($ext) {
        'py' {
            Search-Pattern $File 'shell\s*=\s*True' 'HIGH' 'Command injection risk - shell=True detected'
            Search-Pattern $File 'os\.system\s*\(.*f["\x27]|os\.system\s*\(.*%' 'CRITICAL' 'Command injection risk - os.system with user input'
        }
        { $_ -in 'js','ts' } {
            Search-Pattern $File 'exec\s*\(.*\$\{|exec\s*\(.*\+' 'CRITICAL' 'Command injection risk - exec with user input'
        }
        'php' {
            Search-Pattern $File '(system|exec|shell_exec|passthru)\s*\(\s*\$' 'CRITICAL' 'Command injection risk - shell function with variable'
        }
        'rb' {
            Search-Pattern $File '`.*#\{|system\s*\(.*#\{' 'CRITICAL' 'Command injection risk - command with interpolation'
        }
    }
}

function Test-Deserialization {
    param([string]$File)
    $ext = [System.IO.Path]::GetExtension($File).TrimStart('.')
    switch ($ext) {
        'py' {
            Search-Pattern $File 'pickle\.load' 'CRITICAL' 'Unsafe deserialization - pickle.load detected'
            try {
                $yamlMatches = Select-String -Path $File -Pattern 'yaml\.load' -ErrorAction SilentlyContinue
                foreach ($m in $yamlMatches) {
                    if ($m.Line -notmatch 'SafeLoader|safe_load') {
                        Add-Finding -Severity 'CRITICAL' -Message 'Unsafe deserialization - yaml.load without SafeLoader' -File $File -Line $m.LineNumber
                    }
                }
            } catch { }
        }
        'java' {
            Search-Pattern $File 'ObjectInputStream|readObject\(\)' 'HIGH' 'Potential unsafe deserialization - ObjectInputStream detected'
        }
        'php' {
            Search-Pattern $File 'unserialize\s*\(\s*\$' 'CRITICAL' 'Unsafe deserialization - unserialize with user input'
        }
    }
}

function Test-Xss {
    param([string]$File)
    $ext = [System.IO.Path]::GetExtension($File).TrimStart('.')
    if ($ext -in 'js','ts','jsx','tsx') {
        try {
            $innerHtmlMatches = Select-String -Path $File -Pattern '\.innerHTML\s*=' -ErrorAction SilentlyContinue
            foreach ($m in $innerHtmlMatches) {
                if ($m.Line -notmatch '\.innerHTML\s*=\s*["\x27]<') {
                    Add-Finding -Severity 'HIGH' -Message 'XSS risk - innerHTML assignment' -File $File -Line $m.LineNumber
                }
            }
        } catch { }
        Search-Pattern $File 'dangerouslySetInnerHTML' 'HIGH' 'XSS risk - dangerouslySetInnerHTML usage'
        Search-Pattern $File 'document\.write' 'HIGH' 'XSS risk - document.write usage'
        Search-Pattern $File 'eval\s*\(' 'CRITICAL' 'Code injection risk - eval() detected'
    }
}

function Test-WeakCrypto {
    param([string]$File)
    $ext = [System.IO.Path]::GetExtension($File).TrimStart('.')
    switch ($ext) {
        'py' {
            Search-Pattern $File 'hashlib\.(md5|sha1)\s*\(' 'HIGH' 'Weak cryptography - MD5/SHA1 detected'
        }
        { $_ -in 'js','ts' } {
            Search-Pattern $File "createHash\s*\(\s*['\x22]md5|createHash\s*\(\s*['\x22]sha1" 'HIGH' 'Weak cryptography - MD5/SHA1 detected'
        }
        'java' {
            Search-Pattern $File 'getInstance\s*\(\s*"MD5|getInstance\s*\(\s*"SHA-?1' 'HIGH' 'Weak cryptography - MD5/SHA1 detected'
        }
        'go' {
            Search-Pattern $File 'crypto/md5|crypto/sha1' 'HIGH' 'Weak cryptography - MD5/SHA1 import detected'
        }
    }
}

function Test-Tls {
    param([string]$File)
    $ext = [System.IO.Path]::GetExtension($File).TrimStart('.')
    switch ($ext) {
        'py' { Search-Pattern $File 'verify\s*=\s*False' 'HIGH' 'TLS verification disabled' }
        { $_ -in 'js','ts' } {
            Search-Pattern $File 'rejectUnauthorized.*false' 'HIGH' 'TLS verification disabled'
            Search-Pattern $File 'NODE_TLS_REJECT_UNAUTHORIZED.*0' 'HIGH' 'TLS verification disabled via environment'
        }
        'go' { Search-Pattern $File 'InsecureSkipVerify.*true' 'HIGH' 'TLS verification disabled' }
    }
}

function Test-DebugMode {
    param([string]$File)
    $filename = [System.IO.Path]::GetFileName($File)
    if ($filename -match '(test|spec|dev|local|example)') { return }
    if ($filename -match '(settings|config|app)') {
        Search-Pattern $File 'DEBUG\s*=\s*True' 'MEDIUM' 'Debug mode enabled in config file'
    }
}

function Invoke-FileScan {
    param([string]$File)
    if (-not (Test-FilePath $File)) { return }
    if (-not (Test-Path $File -PathType Leaf)) { return }

    $ext = [System.IO.Path]::GetExtension($File).TrimStart('.')
    $codeExts = @('py','js','ts','jsx','tsx','java','go','rb','php','cs','sh','yaml','yml','json','env')
    if ($ext -notin $codeExts) { return }

    if ($script:Mode -eq 'quick') {
        if ($File -match '(test|spec|mock|fixture|__test__|\.test\.|_test\.)') { return }
    }

    Test-Secrets $File
    Test-SqlInjection $File
    Test-CommandInjection $File
    Test-Deserialization $File
    Test-Xss $File
    Test-WeakCrypto $File
    Test-Tls $File
    Test-DebugMode $File
}

# Parse arguments
$script:Mode = 'quick'
$Files = @()

foreach ($arg in $args) {
    switch ($arg) {
        '--quick' { $script:Mode = 'quick' }
        '--full' { $script:Mode = 'full' }
        { $_ -in '--help','-h' } {
            Write-Output 'Usage: validate-security.ps1 [file_path...] [--quick|--full]'
            Write-Output ''
            Write-Output 'Options:'
            Write-Output '  --quick    Skip test files, use fast patterns (default)'
            Write-Output '  --full     Scan all files with all patterns'
            Write-Output ''
            Write-Output 'Exit codes:'
            Write-Output '  0 - No issues found'
            Write-Output '  1 - Critical security issues (block)'
            Write-Output '  2 - High severity issues (warn)'
            Write-Output '  3 - Medium severity issues (info)'
            exit 0
        }
        default { $Files += $arg }
    }
}

# Scan files
if ($Files.Count -eq 0) {
    $codeFiles = Get-ChildItem -Recurse -File -Include '*.py','*.js','*.ts','*.jsx','*.tsx','*.java','*.go','*.rb','*.php' -ErrorAction SilentlyContinue
    foreach ($f in $codeFiles) {
        Invoke-FileScan $f.FullName
    }
} else {
    foreach ($f in $Files) {
        Invoke-FileScan $f
    }
}

# Output results
if ($script:Findings.Count -eq 0) {
    Write-Output '{"status": "clean", "message": "No security issues found"}'
    exit 0
}

$findingsJson = ($script:Findings | ForEach-Object { "    `"$_`"" }) -join ",`n"

Write-Output "{"
Write-Output "  `"status`": `"issues_found`","
Write-Output "  `"summary`": {"
Write-Output "    `"critical`": $($script:CriticalCount),"
Write-Output "    `"high`": $($script:HighCount),"
Write-Output "    `"medium`": $($script:MediumCount)"
Write-Output "  },"
Write-Output "  `"findings`": ["
Write-Output $findingsJson
Write-Output "  ]"
Write-Output "}"

if ($script:CriticalCount -gt 0) { exit 1 }
elseif ($script:HighCount -gt 0) { exit 2 }
else { exit 3 }
