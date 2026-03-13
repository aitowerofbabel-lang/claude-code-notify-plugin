# Claude Code Desktop Notify Plugin Installer

$PluginDir = $PSScriptRoot
$NotifyScript = Join-Path $PluginDir "notify.ps1"

if (-not (Test-Path $NotifyScript)) {
    Write-Host "Error: notify.ps1 not found in $PluginDir"
    exit 1
}

$UserHome = $env:USERPROFILE
$ClaudeConfigDir = Join-Path $UserHome ".claude"
$PluginInstallDir = Join-Path $ClaudeConfigDir "plugins/desktop-notify"
$SettingsFile = Join-Path $ClaudeConfigDir "settings.local.json"

# 创建插件安装目录
if (-not (Test-Path $PluginInstallDir)) {
    New-Item -ItemType Directory -Path $PluginInstallDir -Force | Out-Null
}

# 复制 notify.ps1 到插件目录
Copy-Item $NotifyScript -Destination $PluginInstallDir -Force
$InstalledNotifyScript = Join-Path $PluginInstallDir "notify.ps1"

Write-Host "Plugin files copied to: $PluginInstallDir"

# 创建/读取配置文件
$settings = @{
    hooks = @{}
    permissions = @{}
}

if (Test-Path $SettingsFile) {
    try {
        $existingSettings = Get-Content $SettingsFile -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($existingSettings.hooks) {
            $settings.hooks = $existingSettings.hooks
        }
        if ($existingSettings.permissions) {
            $settings.permissions = $existingSettings.permissions
        }
    } catch {
        Write-Host "Warning: Could not read existing settings"
    }
}

# 使用 %USERPROFILE% 环境变量，使配置可移植
$notificationCommand = "powershell.exe -ExecutionPolicy Bypass -File `"`$env:USERPROFILE\.claude\plugins\desktop-notify\notify.ps1`" -Title `"Claude Code`" -Message `"需要您的输入`""
$taskCompletedCommand = "powershell.exe -ExecutionPolicy Bypass -File `"`$env:USERPROFILE\.claude\plugins\desktop-notify\notify.ps1`" -Title `"Claude Code`" -Message `"任务已完成`""

$settings.hooks = @{
    Notification = @(
        @{
            matcher = "idle_prompt"
            hooks = @(
                @{
                    type = "command"
                    command = $notificationCommand
                }
            )
        }
    )
    TaskCompleted = @(
        @{
            hooks = @(
                @{
                    type = "command"
                    command = $taskCompletedCommand
                }
            )
        }
    )
}

# 确保 permissions 存在
if (-not $settings.permissions) {
    $settings.permissions = @{}
}
if (-not $settings.permissions.allow) {
    $settings.permissions.allow = @()
}

# 添加必要权限
$requiredPermissions = @(
    "WebFetch(domain:github.com)",
    "Bash(powershell.exe:*)"
)

foreach ($perm in $requiredPermissions) {
    if ($settings.permissions.allow -notcontains $perm) {
        $settings.permissions.allow += $perm
    }
}

# 写入配置
$json = $settings | ConvertTo-Json -Depth 10
$json | Set-Content $SettingsFile -Encoding UTF8

Write-Host ""
Write-Host "=============================================="
Write-Host "  Claude Code Desktop Notify Plugin Installed!"
Write-Host "=============================================="
Write-Host ""
Write-Host "Plugin files: $PluginInstallDir"
Write-Host "Config file:  $SettingsFile"
Write-Host ""
Write-Host "Please restart Claude Code or start a new conversation."
Write-Host ""
