param(
    [string]$Title = "Claude Code",
    [string]$Message = "Task completed!",
    [int]$WaitSeconds = 30
)

Write-Host "Notification: $Title - $Message"

# 使用 NotifyIcon 方式（不需要注册 App ID，更可靠）
try {
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop

    $notify = New-Object System.Windows.Forms.NotifyIcon
    $notify.Icon = [System.Drawing.SystemIcons]::Information
    $notify.Visible = $true
    $notify.ShowBalloonTip(5000, $Title, $Message, "Info")

    Write-Host "NotifyIcon shown successfully"

    # 等待通知显示
    Start-Sleep 6

    $notify.Dispose()
} catch {
    Write-Host "NotifyIcon failed: $_"

    # 备用方案：尝试 Windows Toast
    try {
        Add-Type -AssemblyName System.WindowsRuntime -ErrorAction SilentlyContinue
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
        [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

        $template = "<toast><visual><binding template=`"ToastText02`"><text id=`"1`">$Title</text><text id=`"2`">$Message</text></binding></visual></toast>"
        $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
        $xml.LoadXml($template)

        $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
        $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("powershell.exe")
        $notifier.Show($toast)
        Write-Host "Toast notification shown"
    } catch {
        Write-Host "Toast also failed: $_"
    }
}

Write-Host "Done."
