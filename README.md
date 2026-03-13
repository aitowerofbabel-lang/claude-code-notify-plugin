# Claude Code 桌面通知插件

一款为 Claude Code 打造的桌面通知插件，当任务完成或需要你输入时，会在桌面右下角弹出通知提醒。

## 功能特性

- **任务完成通知** - 当 Claude 完成一个任务时，桌面弹出通知
- **输入提醒** - 当 Claude 需要你的输入时，发送桌面通知
- **跨平台兼容** - 支持 Windows 10/11，使用系统原生通知

## 系统要求

- Windows 10 或 Windows 11
- PowerShell 5.1 或更高版本
- Claude Code 最新版

## 安装步骤

### 步骤 1：下载插件

```powershell
# 方式 A：使用 Git 克隆
git clone https://github.com/aitowerofbabel-lang/claude-code-notify-plugin.git

# 方式 B：直接下载 ZIP
# 访问 GitHub 仓库 → Code → Download ZIP → 解压
```

### 步骤 2：运行安装

```powershell
# 进入插件目录
cd claude-code-notify-plugin

# 运行安装脚本
.\install.ps1
```

安装程序会自动完成以下操作：
1. 创建插件目录 `~/.claude/plugins/desktop-notify/`
2. 复制通知脚本到插件目录
3. 配置 Claude Code 的 hooks
4. 添加必要的权限

### 步骤 3：重启 Claude Code

安装完成后，**重启 Claude Code** 或开启新的对话窗口即可生效。

## 使用方法

安装完成后无需任何配置，插件会自动工作：

| 场景 | 触发条件 | 通知内容 |
|------|---------|---------|
| 任务完成 | Claude 完成一个任务 | "任务已完成" |
| 需要输入 | Claude 等待你的回复 | "需要您的输入" |

收到通知后，通知气泡会在几秒后自动消失。

## 卸载插件

```powershell
# 进入插件目录
cd claude-code-notify-plugin

# 运行卸载脚本
.\uninstall.ps1
```

卸载程序会：
1. 移除 Claude Code 配置中的 hooks
2. 删除插件目录 `~/.claude/plugins/desktop-notify/`

## 手动卸载

如果安装脚本出现问题，可以手动卸载：

```powershell
# 1. 编辑配置文件
notepad $env:USERPROFILE\.claude\settings.local.json

# 2. 删除 hooks 中的 "Notification" 和 "TaskCompleted" 部分

# 3. 删除插件目录
Remove-Item -Recurse -Force $env:USERPROFILE\.claude\plugins\desktop-notify
```

## 常见问题

### Q: 安装后通知没有弹出？

A: 请检查以下几点：
1. 确保已重启 Claude Code
2. 检查 Windows 通知设置是否被阻止
3. 确保电脑有桌面环境（不支持纯命令行服务器）

### Q: 通知显示为乱码？

A: 这可能是 PowerShell 控制台编码问题。尝试在 PowerShell 中运行：
```powershell
chcp 65001
```

### Q: 可以自定义通知内容吗？

A: 可以。修改 `install.ps1` 中的这两行：
```powershell
$notificationCommand = "... -Message `"自定义内容`""
$taskCompletedCommand = "... -Message `"自定义内容`""
```

## 文件结构

```
claude-code-notify-plugin/
├── install.ps1       # 安装脚本
├── uninstall.ps1     # 卸载脚本
├── notify.ps1       # 通知执行脚本
├── plugin.json      # 插件元数据
└── README.md        # 说明文档
```

## 技术原理

插件利用 Claude Code 的 Hooks 机制：

1. **Notification Hook** - 当需要用户输入时触发
2. **TaskCompleted Hook** - 当任务完成时触发

这两个 hook 会调用 PowerShell 脚本，脚本使用 Windows 的 `NotifyIcon` API 显示桌面气泡通知。

## License

MIT License

## 问题反馈

如果你遇到问题或有任何建议，请提交 [Issue](https://github.com/你的用户名/claude-code-notify-plugin/issues)。
