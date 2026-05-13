$ErrorActionPreference = 'Stop'

try {
    $InputJson = [Console]::In.ReadToEnd()
    $Hook = $InputJson | ConvertFrom-Json
} catch {
    Write-Output '{"suppressOutput":true,"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
    exit 0
}

function Hook-Response {
    param(
        [string]$Decision,
        [string]$Reason = '',
        [string]$Message = ''
    )
    $obj = [ordered]@{
        suppressOutput = $true
        hookSpecificOutput = [ordered]@{
            hookEventName = 'PreToolUse'
            permissionDecision = $Decision
        }
    }
    if ($Reason) { $obj.hookSpecificOutput.permissionDecisionReason = $Reason }
    if ($Message) { $obj.systemMessage = $Message }
    $obj | ConvertTo-Json -Compress -Depth 6
}

function Test-LowRiskPath {
    param([string]$Path)
    return ($Path -match 'test|spec|fixture|example|\.md$|(^|/)docs/')
}

function Check-Content {
    param(
        [string]$Content,
        [string]$Path
    )

    if (Test-LowRiskPath $Path) {
        Hook-Response -Decision 'allow'
        return
    }

    if ($Content -match 'AKIA[A-Z0-9]{16}') {
        Hook-Response -Decision 'deny' -Reason 'AWS access key literal detected in code change.' -Message '[SECURITY] Blocked: AWS access key literal detected.'
        return
    }

    if ($Content -match 'BEGIN' -and $Content -match 'PRIVATE KEY') {
        Hook-Response -Decision 'deny' -Reason 'Private key material detected in code change.' -Message '[SECURITY] Blocked: private key material detected.'
        return
    }

    if ($Content -match 'subprocess\.(run|call|Popen)\([^)]*shell\s*=\s*True|os\.system\s*\(|child_process\.exec\s*\(') {
        Hook-Response -Decision 'allow' -Reason 'Potential command injection sink introduced; follow up with /security:scan --diff.' -Message '[SECURITY] Warning: command execution sink changed.'
        return
    }

    if ($Content -match 'dangerouslySetInnerHTML|\.innerHTML\s*=|document\.write\s*\(') {
        Hook-Response -Decision 'allow' -Reason 'Potential XSS sink introduced; follow up with /security:scan --diff.' -Message '[SECURITY] Warning: browser HTML sink changed.'
        return
    }

    Hook-Response -Decision 'allow'
}

$ToolName = if ($Hook.tool_name) { [string]$Hook.tool_name } else { '' }

switch ($ToolName) {
    'Write' {
        Check-Content -Content ([string]$Hook.tool_input.content) -Path ([string]$Hook.tool_input.file_path)
    }
    'Edit' {
        Check-Content -Content ([string]$Hook.tool_input.new_string) -Path ([string]$Hook.tool_input.file_path)
    }
    'MultiEdit' {
        $content = ''
        if ($Hook.tool_input.edits) {
            $content = ($Hook.tool_input.edits | ForEach-Object { $_.new_string }) -join "`n"
        }
        Check-Content -Content $content -Path ([string]$Hook.tool_input.file_path)
    }
    'Bash' {
        $cmd = [string]$Hook.tool_input.command
        if ($cmd -match 'rm\s+-rf\s+(/|~|\*)($|\s)') {
            Hook-Response -Decision 'deny' -Reason 'Destructive rm command targets a broad path.' -Message '[SECURITY] Blocked: destructive rm command targets a broad path.'
        } elseif ($cmd -match 'curl[^|]*\|\s*(sh|bash)|wget[^|]*\|\s*(sh|bash)') {
            Hook-Response -Decision 'ask' -Reason 'Remote script execution requires explicit user approval.' -Message '[SECURITY] Approval required: remote script piped to shell.'
        } elseif ($cmd -match '(^|\s)(env|printenv)($|\s)|git push --force') {
            Hook-Response -Decision 'allow' -Reason 'Command may expose environment data or rewrite remote history.' -Message '[SECURITY] Warning: risky command, check intent.'
        } else {
            Hook-Response -Decision 'allow'
        }
    }
    default {
        Hook-Response -Decision 'allow'
    }
}
