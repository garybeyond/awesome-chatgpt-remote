# Awesome ChatGPT Remote

用 ChatGPT 手机端连接 Mac 或 Windows 上的 ChatGPT/Codex：下载、配对、代理诊断与无 TUN 启动。

[English](README.en.md) · [官方 Remote 文档](https://learn.chatgpt.com/docs/remote-connections) · [问题排查](#排查表)

按系统下载源码：[macOS ZIP](https://github.com/garybeyond/awesome-chatgpt-remote/releases/latest/download/awesome-chatgpt-remote-macos-source.zip) · [Windows ZIP](https://github.com/garybeyond/awesome-chatgpt-remote/releases/latest/download/awesome-chatgpt-remote-windows-source.zip)。也可直接查看 [macOS 源码](macos/)和 [Windows 源码](windows/)；两包都包含中英文教程。

> 独立社区教程，并非 OpenAI 官方项目。代理启动器只包装你已经安装的官方 ChatGPT.app；仓库不提供修改版 ChatGPT，也不收集账号或配对码。

## 先看结果

在一台使用 Clash Verge、混合代理端口为 `127.0.0.1:7890` 的 Mac 上，我们观察到：

1. 仅开启 macOS 系统代理时，ChatGPT 的普通功能可用，但 Remote 获取配对码超时：`Timed out waiting for remote control to connect`。
2. 完全退出 ChatGPT，用 `HTTP_PROXY`、`HTTPS_PROXY`、`ALL_PROXY` 临时启动官方 App 后，配对二维码出现，手机成功连接。
3. TUN 全程保持关闭。这个对照支持该机器上的 Remote Host 连接需要进程代理变量；它不证明每台电脑的故障原因都相同。Windows 代码尚未实机验证。

## 目录

- [四步完成手机连接](#四步完成手机连接)
- [macOS：不打开 TUN 的代理方案](#macos不打开-tun-的代理方案)
- [Windows：两种代理变量方案](#windows两种代理变量方案)
- [一键启动 App：AppleScript 源码](#一键启动-appapplescript-源码)
- [给新 App 换上 ChatGPT 图标](#给新-app-换上-chatgpt-图标)
- [排查表](#排查表)
- [边界与安全](#边界与安全)

## 四步完成手机连接

### 1. 下载官方 App

Mac 和 Windows：从 [OpenAI 的桌面版下载页](https://chatgpt.com/download/)选择对应系统安装官方 ChatGPT。iPhone：从 [OpenAI 的 iOS 下载指引](https://help.openai.com/en/articles/7908378-where-can-i-download-the-openai-chatgpt-ios-app-on-the-apple-app-store)进入 App Store。Android：从同一官方下载页进入 Google Play。核对发布者是 OpenAI，并更新到最新版。手机 App 的下载、账号和扫码步骤对 Mac/Windows Host 相同。

#### 关于美区 Apple ID

如果你的本地 App Store 商店没有显示官方 ChatGPT，且你已有可使用的美区 Apple ID，可以用它在美区商店下载。这是商店获取方式，不是 Remote 的技术前提，也不能改变 OpenAI 的服务地区与账号资格要求。先核对 [官方支持地区](https://help.openai.com/en/articles/7947663-chatgpt-supported-countries)；不同国家、账号和商店的可用性会变化。

### 2. 让电脑成为 Remote Host

在电脑的 ChatGPT 中登录与手机相同的 ChatGPT 账号及 Workspace，打开 Settings → Connections → Control this Mac/PC → Set up / Add，允许远程连接。电脑应保持开机、联网且 ChatGPT 正在运行。若 Workspace 有管理员策略，可能还需要管理员开放 Remote。[官方设置步骤](https://learn.chatgpt.com/docs/remote-connections)

### 3. 手机扫码配对

电脑显示二维码后，用手机上的 ChatGPT 扫描并完成确认。iOS 新版通常在 Codex 中管理已连接的电脑；仍显示 Remote 的版本请进入 Remote。Android 的入口以当前 App 界面为准。每台手机和每台 Host 需要各自配对。[官方配对说明](https://learn.chatgpt.com/docs/remote-connections)

### 4. 验证到位

手机端选择这台电脑，打开一个已有 Codex 对话或在已连接主机上新建任务。能查看任务并发送一条普通跟进指令，才算端到端连接成功。二维码出现只说明 Host 已经越过配对前的连接阶段，不能代替手机端验证。

## macOS：不打开 TUN 的代理方案

以下 Mac 方案只在普通启动无法取得配对码、且你确实需要本地代理时使用。先在 Clash Verge 中开启系统代理、关闭 TUN，并核对混合端口。启动器每次打开都会提示输入实际端口；`7890` 只是输入框中的示例值。

端口不是 7890？例如 Clash Verge 显示混合端口 `7897`：打开启动器，在弹窗输入 `7897`，点击继续。无需改源码或重新编译。下方测试命令也应使用 `7897`。如果 HTTP 与 SOCKS5 端口不同，目前的单端口输入方式不适用，需分别调整脚本中的地址。

```bash
scutil --proxy
curl -I -m 8 -x http://127.0.0.1:7890 https://chatgpt.com
```

`200 Connection established` 只表示 HTTP 代理隧道建立；后续 `403`、`426` 等响应不等于 Remote WebSocket 已成功。最终以取得二维码并从手机连接成功为准。

macOS 系统代理与进程环境变量是两套配置。有些 ChatGPT/Codex 后台组件可能读取进程环境。终端中的 `export` 仅影响该终端启动的程序，之后从 Dock 点击原版 ChatGPT.app 不会自动获得这些变量。不要把 Windows 教程中的 `setx` 复制到 Mac；也无需为此打开 TUN。

## Windows：两种代理变量方案

Windows Host 与 Mac 使用同一套手机配对步骤，但代理设置方式不同。

端口不是 7890？运行脚本时会提示输入实际端口，例如 `7897`；也可传 `-Port 7897` 跳过提示。下方 `curl.exe` 命令也要换成同一个实际的 HTTP/混合代理端口。

1. 在 PowerShell 查看监听端口：`netstat -ano | findstr LISTENING`；确认端口属于你的代理软件。把下方的 `7890` 改成实际端口。
2. 测试本地 HTTP 代理：`curl.exe -I -x http://127.0.0.1:7890 https://chatgpt.com`。出现 `Connection established` 只说明代理隧道可用，不保证 Remote WebSocket 成功。
3. 推荐先试单进程方案：若你能定位到可直接运行的 ChatGPT `.exe`，使用 [`windows/Start-ChatGPT-With-Proxy.ps1`](windows/Start-ChatGPT-With-Proxy.ps1)。它只给新启动的进程注入变量。Microsoft Store 封装 App 的 Shell 快捷方式可能不继承这些变量；不要把这条路径宣称为所有安装方式都适用。
4. 截图中的持久方案：运行 [`windows/Set-UserProxy.ps1`](windows/Set-UserProxy.ps1) 并输入端口，完全退出 ChatGPT，注销再登录 Windows 或重启，然后正常打开 ChatGPT 取码。此脚本设置用户级 `HTTP_PROXY`、`HTTPS_PROXY`、`ALL_PROXY`、`NO_PROXY`，等价于对未来进程使用 `setx` 的主要效果。它也会影响其他读取这些变量的新程序，并非 ChatGPT 专属。用 [`windows/Restore-UserProxy.ps1`](windows/Restore-UserProxy.ps1) 撤销本脚本新增的变量。

示例（在仓库根目录 PowerShell 中）：

```powershell
.\windows\Set-UserProxy.ps1
# 提示输入实际端口，例如 7897；也可用 -Port 7897 直接指定。
# 完全退出 ChatGPT，然后注销/重新登录 Windows 或重启，再试 Remote。
.\windows\Restore-UserProxy.ps1
```

Windows 用户级变量会持续存在，但不会自动更新当前已经运行的 ChatGPT 进程。先正常退出 App。PowerShell 的用户级变量作用与 `setx` 的生效时机参见 [Microsoft 环境变量文档](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_Environment_Variables)和 [`setx` 文档](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/setx)。

## 一键启动 App：AppleScript 源码

仓库提供 Mac 完整源码 [`macos/ChatGPT via Clash.applescript`](macos/ChatGPT%20via%20Clash.applescript)。脚本检查官方 App 是否存在、代理端口是否可用、ChatGPT 是否已经运行，然后给本次启动的 ChatGPT 及其子进程设置：

```text
HTTP_PROXY / HTTPS_PROXY = http://127.0.0.1:7890
ALL_PROXY                = socks5h://127.0.0.1:7890
NO_PROXY                 = localhost,127.0.0.1,::1
```

脚本也设置小写变量，以兼容不同网络库。每次打开启动器时输入实际端口，不要修改已签名的 ChatGPT.app 安装包。

用脚本编辑器生成 App：

1. 打开 macOS「脚本编辑器」；新建文稿，粘贴上述 `.applescript` 的全部源码。
2. 无需改源码；双击新 App 时在弹窗输入 Clash Verge 显示的混合端口。
3. 点「编译」，再选「文件 → 导出」，文件格式选「应用程序」，命名为 `ChatGPT via Clash.app`。
4. 先在原版 ChatGPT 中按 ⌘Q 完全退出；双击新 App 启动。以后从这个入口启动即可，不必保持终端窗口。

也可在仓库目录运行 `zsh macos/build-app.sh`，生成 `dist/ChatGPT via Clash.app`。`dist/` 不提交到 Git：公开源码比公开一个未经签名的二进制 App 更容易审查。首次使用前请自行阅读源码。

> 新入口只影响它启动的 ChatGPT。直接点 Dock 中原版 ChatGPT 图标会绕过它。可将新 App 拖到 Dock，替换原入口。App 运行期间仍需让本地代理软件保持在线。

### 临时回退

按 ⌘Q 退出 ChatGPT，改从原版 `/Applications/ChatGPT.app` 启动即可。删除 `ChatGPT via Clash.app` 不会改动 macOS 网络设置。这个方案不调用 `launchctl setenv`，不会给其他 GUI App 注入代理变量。

## 给新 App 换上 ChatGPT 图标

图标请仅在自己的 Mac 上从已安装的官方 App 复制；仓库不分发 OpenAI 图标。

1. 在 Finder 的「应用程序」中选中原版 `ChatGPT.app`，按 ⌘I 打开「显示简介」。
2. 点击简介窗口左上角的小图标，看到选中边框后按 ⌘C。
3. 在 Finder 中选中新建的 `ChatGPT via Clash.app`，按 ⌘I。
4. 点击新 App 简介窗口左上角的小图标，按 ⌘V。需要时输入 Mac 密码。
5. 若 Dock 仍显示旧图标，把新 App 从 Dock 移除后重新拖入。

## 排查表

先按阶段判断：没有二维码先查 Mac Host 的启用与出站连接；已有二维码但扫码失败先查账号、Workspace 与配对；已连接但随后离线再查 Mac 是否休眠或断网。下面的报错文字会随 App 版本变化，不要只凭一句日志认定根因。

| 报错或现象 | 能说明什么 | 下一步 |
| --- | --- | --- |
| `无法获取配对码：Timed out waiting for remote control to connect` （本机实测） | Mac 已开始配对流程，但 Remote Host 未在期限内就绪；故障发生在扫码前 | 核对代理端口，按 ⌘Q 退出原版 ChatGPT，再从专用入口启动并重试。若仍超时，记录准确时间与节点后查日志；不要把它直接归咎于手机 |
| `无法启用远程控制，请重试` 或启用后立即关闭 | Remote 在 Mac 端未稳定启用；单凭提示无法区分网络、认证或 Workspace 策略 | 更新桌面 App；重启 ChatGPT；确认同一账号与 Workspace、管理员已允许 Remote，再按[官方步骤](https://learn.chatgpt.com/docs/remote-connections)重新开启 |
| 一般 ChatGPT 网络错误，如 `An error occurred while connecting to the websocket` | 说明某条 WebSocket 不稳定，不一定就是 Remote Host 那条连接 | 检查代理、网络过滤与 [WebSocket Upgrade 建议](https://help.openai.com/en/articles/9247338-network-recommendations-for-chatgpt-errors-on-web-and-apps)；只用同时段且明确指向 Remote 的日志判断根因 |
| 新入口提示 ChatGPT 已在运行 | 新变量不会自动进入原本运行的进程 | 在 ChatGPT 按 ⌘Q；不要只关窗口，再双击新入口 |
| Clash 已启动但脚本提示端口不可用 | 混合代理端口不一定是 7890 | 在 Clash 设置查看端口，重新打开启动器并输入正确端口 |
| 二维码出现，但手机找不到 Host 或审批请求不出现 | Mac 已越过取码阶段；配对、账号、Workspace、权限或在线状态仍待确认 | 更新手机 App，确认同一账号和 Workspace，重新扫码；让 Mac 保持唤醒，参照[官方排查](https://learn.chatgpt.com/docs/remote-connections) |
| 连接成功后又离线 | Host 可能休眠、断网、退出 App，或代理软件/节点掉线 | 检查 Mac 与代理仍在线；从 Mac 的 Connections 页面确认 Remote 是否开启 |
| 连接后部分项目没出现 | 手机可能选错 Host/Workspace；项目列表问题与配对是两回事 | 在 Mac 桌面 App 确认项目已存在，再从手机端选择对应主机和项目 |
| 换节点后仍失败 | 普通 HTTPS 可达不代表 Remote 长连接稳定 | 不要把 HTTP `curl` 成功等同于 Remote 成功；记录时间、节点与错误再比较 |

日志辨认提醒：ChatGPT 日志中的 `hostId=durable` 等连接错误可能属于另一类远程环境连接，不能自动当成手机 Remote Host 的失败原因。网络策略也可能影响 WebSocket Upgrade；OpenAI 的[网络建议](https://help.openai.com/en/articles/9247338-network-recommendations-for-chatgpt-errors-on-web-and-apps)列出域名与连接要求。

## 边界与安全

- Mac AppleScript 不创建新的代理服务，不开 TUN，也不修改 `/Applications/ChatGPT.app`。Windows 用户级脚本会影响其他读取代理环境变量的新进程；需要单进程隔离时优先试 Windows 单进程脚本。
- Remote 不是传统的 Mac 桌面远控；手机主要用于选择主机、继续 Codex 工作、审阅结果和处理批准。[官方介绍](https://developers.openai.com/blog/mastering-codex-remote-for-engineering)
- 不要把二维码、配对码、账号、令牌、完整日志或包含个人项目名的截图提交到公开 Issue。
- 脚本只验证本地端口可连接；代理节点质量、服务地区、账号资格和 OpenAI 服务状态仍可能影响连接。
- 独立社区项目，不代表 OpenAI 或 Clash Verge。Mac 路径在一台机器上实测过；Windows 源码未做实机端到端验证。

## 参与和维护

欢迎提交可复现的问题、不同代理软件的测试结果和文档修正。参见 [CONTRIBUTING.md](CONTRIBUTING.md)。
