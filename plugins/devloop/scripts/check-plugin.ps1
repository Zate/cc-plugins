$ErrorActionPreference = 'Stop'

# check-plugin.ps1 - Check if a plugin is installed

$PluginName = if ($args.Count -gt 0) { $args[0] } else { '' }

if (-not $PluginName) {
    Write-Output '{"error": "missing_argument", "message": "Plugin name required"}'
    exit 2
}

$ClaudePluginDir = Join-Path $env:HOME '.claude' 'plugins'
if (-not $env:HOME) { $ClaudePluginDir = Join-Path $env:USERPROFILE '.claude' 'plugins' }

function Find-Plugin {
    param([string]$Name)

    # Check cache directory (marketplace plugins)
    $cacheDir = Join-Path $ClaudePluginDir 'cache'
    if (Test-Path $cacheDir -PathType Container) {
        foreach ($mDir in (Get-ChildItem $cacheDir -Directory -ErrorAction SilentlyContinue)) {
            $pluginDir = Join-Path $mDir.FullName $Name
            if (Test-Path $pluginDir -PathType Container) {
                $versions = Get-ChildItem $pluginDir -Directory -ErrorAction SilentlyContinue | Sort-Object Name
                if ($versions) {
                    return ($versions | Select-Object -Last 1).FullName
                }
            }
        }
    }

    # Check local directory
    $localDir = Join-Path $ClaudePluginDir 'local' $Name
    if (Test-Path $localDir -PathType Container) { return $localDir }

    # Check marketplaces directory
    $marketDir = Join-Path $ClaudePluginDir 'marketplaces'
    if (Test-Path $marketDir -PathType Container) {
        foreach ($mDir in (Get-ChildItem $marketDir -Directory -ErrorAction SilentlyContinue)) {
            $pluginDir = Join-Path $mDir.FullName 'plugins' $Name
            if (Test-Path $pluginDir -PathType Container) { return $pluginDir }
        }
    }

    return $null
}

$pluginPath = Find-Plugin $PluginName

if ($pluginPath) {
    $escapedPath = $pluginPath -replace '\\', '\\\\' -replace '"', '\"'
    Write-Output "{`"installed`": true, `"name`": `"$PluginName`", `"path`": `"$escapedPath`"}"
    exit 0
} else {
    Write-Output "{`"installed`": false, `"name`": `"$PluginName`", `"path`": null}"
    exit 1
}
