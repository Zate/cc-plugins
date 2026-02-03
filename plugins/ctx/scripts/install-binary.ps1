# Download and install ctx binary from GitHub releases (Windows)
$ErrorActionPreference = 'Stop'

$repo = 'Zate/Memdown'
$binaryName = 'ctx'

# Detect architecture
switch ($env:PROCESSOR_ARCHITECTURE) {
    'AMD64'   { $arch = 'amd64' }
    'ARM64'   { $arch = 'arm64' }
    default   {
        Write-Error "Unsupported architecture: $env:PROCESSOR_ARCHITECTURE"
        exit 1
    }
}

# Get latest version tag
try {
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases/latest" -UseBasicParsing
    $version = $release.tag_name
} catch {
    Write-Error 'Failed to determine latest version'
    exit 1
}

if (-not $version) {
    Write-Error 'Failed to determine latest version'
    exit 1
}

$assetVersion = $version -replace '^v', ''
$assetName = "${binaryName}_${assetVersion}_windows_${arch}.zip"
$url = "https://github.com/$repo/releases/download/$version/$assetName"

# Install directory
$installDir = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps'
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}

# Download
$tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) "ctx-install-$([guid]::NewGuid().ToString('N').Substring(0,8))"
New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null

try {
    $zipPath = Join-Path $tmpDir $assetName
    Write-Host "Downloading ctx $version for windows/$arch..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing

    # Extract
    Expand-Archive -Path $zipPath -DestinationPath $tmpDir -Force

    # Move binary
    $srcBinary = Join-Path $tmpDir "$binaryName.exe"
    if (-not (Test-Path $srcBinary)) {
        # Some archives nest in a folder; search for it
        $srcBinary = Get-ChildItem -Path $tmpDir -Filter "$binaryName.exe" -Recurse | Select-Object -First 1 -ExpandProperty FullName
    }

    if (-not $srcBinary -or -not (Test-Path $srcBinary)) {
        Write-Error "Binary not found in archive"
        exit 1
    }

    $destBinary = Join-Path $installDir "$binaryName.exe"
    Copy-Item -Path $srcBinary -Destination $destBinary -Force

    # Verify
    try {
        $installedVersion = & $destBinary version 2>$null
        Write-Output "installed:$installedVersion"
    } catch {
        Write-Warning "installed but version check failed"
        Write-Output "installed:$destBinary"
    }

    # Initialize database if needed
    $dbPath = Join-Path $env:USERPROFILE '.ctx\store.db'
    if (-not (Test-Path $dbPath)) {
        & $destBinary init
    }

} finally {
    Remove-Item -Path $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
}
