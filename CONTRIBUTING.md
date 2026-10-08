# 参与贡献 / Contributing

## 中文

欢迎修正文档、补充其他代理软件的已验证配置，以及报告 macOS 或 Windows 上的实际结果。每个问题请写明：操作系统和版本、ChatGPT 版本、安装来源、代理软件和端口、TUN 是否开启、复现步骤、实际结果、预期结果。Windows 方案尚未实机验证，特别欢迎可复现的测试结果。只提交与 Remote 配对或启动器直接相关的内容。

提交前请删除二维码、配对码、账号 ID、邮箱、令牌、设备名称、私有项目名、代理订阅与完整日志。需要日志时，请只摘录相关错误和时间，并手工脱敏。不要提交对官方 ChatGPT.app 的修改版或 OpenAI 图标文件。

建议先开 Issue 描述问题；修复请提交小而清晰的 Pull Request，并说明在哪台机器上做了何种验证。macOS AppleScript 改动至少应通过 `osacompile` 编译；Windows PowerShell 改动请说明所用 PowerShell 版本、是否实机验证、设置与撤销结果；文档改动请检查中英文两版的一致性。

## English

Documentation fixes, verified results from other proxy apps, and reproducible reports on macOS or Windows are welcome. Include OS version, ChatGPT version and installation source, proxy app and port, TUN state, reproduction steps, actual result, and expected result. Windows scripts still need real-world validation. Keep contributions scoped to Remote pairing or these launchers.

Remove QR codes, pairing codes, account IDs, email addresses, tokens, hostnames, private project names, proxy subscriptions, and full logs before posting. Share only short, redacted error lines with timestamps. Do not submit a modified ChatGPT.app or OpenAI icon assets.

Open an Issue first when diagnosing a new case. Keep Pull Requests small and explain how you verified them. AppleScript changes should compile with `osacompile`; PowerShell changes should state the tested version and results of setup and rollback; documentation changes should keep both language versions aligned.
