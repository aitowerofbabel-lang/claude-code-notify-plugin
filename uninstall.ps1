# Claude Code 桌面通知插件卸载脚本

$UserHome = $env:USERPROFILE
$SettingsFile = Join-Path $UserHome ".claude\settings.local.json"
$PluginInstallDir = Join-Path $UserHome ".claude\plugins\desktop-notify"

if (-not (Test-Path $SettingsFile)) {
    Write-Host "未找到 Claude Code 配置文件，无需卸载" -ForegroundColor Yellow
    exit 0
}

# 读取现有配置
try {
    $settings = Get-Content $SettingsFile -Raw | ConvertFrom-Json
} catch {
    Write-Host "Error: 无法读取配置文件" -ForegroundColor Red
    exit 1
}

# 检查是否有 hooks
if (-not $settings.hooks) {
    Write-Host "未找到任何 hooks 配置，无需卸载" -ForegroundColor Yellow
    exit 0
}

# 检查是否安装了本插件的 hooks (支持新旧路径)
$pluginInstalled = $false

if ($settings.hooks.Notification) {
    $notificationHook = $settings.hooks.Notification | Where-Object {
        $_.hooks -and $_.hooks.command -and ($_.hooks.command -like "*desktop-notify*" -or $_.hooks.command -like "*claude-code-notify-plugin*")
    }
    if ($notificationHook) {
        $settings.hooks.Notification = @()
        $pluginInstalled = $true
    }
}

if ($settings.hooks.TaskCompleted) {
    $taskCompletedHook = $settings.hooks.TaskCompleted | Where-Object {
        $_.hooks -and $_.hooks.command -and ($_.hooks.command -like "*desktop-notify*" -or $_.hooks.command -like "*claude-code-notify-plugin*")
    }
    if ($taskCompletedHook) {
        $settings.hooks.TaskCompleted = @()
        $pluginInstalled = $true
    }
}

if (-not $pluginInstalled) {
    Write-Host "未检测到本插件的配置，可能是已卸载或手动修改过" -ForegroundColor Yellow
    exit 0
}

# 清理空的 hooks
if ($settings.hooks.Notification.Count -eq 0) {
    $settings.hooks.PSObject.Properties.Remove("Notification")
}
if ($settings.hooks.TaskCompleted.Count -eq 0) {
    $settings.hooks.PSObject.Properties.Remove("TaskCompleted")
}

# 如果 hooks 为空，移除整个 hooks 对象
if ($settings.hooks.PSObject.Properties.Count -eq 0) {
    $settings.PSObject.Properties.Remove("hooks")
}

# 保存配置
$settings | ConvertTo-Json -Depth 10 | Set-Content $SettingsFile -Encoding UTF8

# 删除插件安装目录
if (Test-Path $PluginInstallDir) {
    Remove-Item -Path $PluginInstallDir -Recurse -Force
    Write-Host "已删除插件文件: $PluginInstallDir"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Claude Code 通知插件卸载成功!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "配置文件已更新: $SettingsFile"
