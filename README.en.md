# Awesome ChatGPT Remote

Connect ChatGPT Mobile to ChatGPT/Codex on macOS or Windows, including proxy troubleshooting without TUN.

[中文教程](README.md) · [Official Remote guide](https://learn.chatgpt.com/docs/remote-connections)

Download source by platform: [macOS ZIP](https://github.com/garybeyond/awesome-chatgpt-remote/releases/latest/download/awesome-chatgpt-remote-macos-source.zip) · [Windows ZIP](https://github.com/garybeyond/awesome-chatgpt-remote/releases/latest/download/awesome-chatgpt-remote-windows-source.zip). You can also inspect the [macOS source](macos/) and [Windows source](windows/) directly. Both archives include the Chinese and English guides.

## What was verified

On one Mac with Clash Verge at `127.0.0.1:7890`, ordinary ChatGPT launch timed out before showing a pairing QR code. Starting the official app with proxy environment variables produced a QR code and the phone connected. TUN stayed off. This supports a process-environment issue on that Mac, not a universal diagnosis. The Windows scripts have not been tested on Windows.

## Pair your phone in four steps

1. Install the official [ChatGPT desktop app](https://chatgpt.com/download/) for Mac or Windows. Install ChatGPT Mobile through OpenAI's [iPhone App Store guide](https://help.openai.com/en/articles/7908378-where-can-i-download-the-openai-chatgpt-ios-app-on-the-apple-app-store) or the Google Play link on the download page. Check that the publisher is OpenAI and update both apps.
2. Sign in to the same ChatGPT account and Workspace on both devices. On desktop, open Settings → Connections → Control this Mac/PC → Set up / Add. Keep the computer awake, online, and running ChatGPT. Workspace administrators may need to enable Remote.
3. Scan the desktop QR code in ChatGPT Mobile and confirm pairing. The mobile entry may appear under Codex or Remote, depending on the app version. Pair each phone and host separately.
4. Select the host on mobile and send a simple follow-up in a Codex task. A QR code alone does not verify the complete connection. See [official pairing steps](https://learn.chatgpt.com/docs/remote-connections).

#### US Apple ID

If the official iOS app is absent from your local App Store and you already have a usable US Apple ID, the US store may be an installation route. A US Apple ID is not a technical Remote requirement and does not change [OpenAI's supported-country rules](https://help.openai.com/en/articles/7947663-chatgpt-supported-countries). The phone steps are the same for Mac and Windows hosts.

## macOS: per-app proxy launcher

Use this when normal launch fails before the QR code and your network requires the local proxy. Keep Clash Verge's system proxy on and TUN off. Confirm the real mixed port; `7890` is an example.

Using port 7897 or another port? Open the launcher, enter `7897` in its dialog, and continue. No source edit or rebuild is needed. Replace `7890` in the test command below as well. If HTTP and SOCKS5 use different ports, the current single-port prompt does not apply; adjust the two URLs separately.

```bash
scutil --proxy
curl -I -m 8 -x http://127.0.0.1:7890 https://chatgpt.com
```

An HTTP `Connection established` response proves a proxy tunnel, not a working Remote WebSocket. A Terminal `export` reaches programs launched from that Terminal; clicking the original Dock icon later does not inherit it.

The full source is [`macos/ChatGPT via Clash.applescript`](macos/ChatGPT%20via%20Clash.applescript). It prompts for the actual port each time it opens. It checks the official app and local port, avoids starting a second ChatGPT process, and supplies HTTP/HTTPS proxy variables, `ALL_PROXY=socks5h://127.0.0.1:7890`, and `NO_PROXY=localhost,127.0.0.1,::1` to this launch. It does not modify ChatGPT.app or global settings.

To build: paste the entire source into macOS Script Editor, click Compile, then File → Export → Application. Name it `ChatGPT via Clash.app`. Or run `zsh macos/build-app.sh` from the repository root to produce `dist/ChatGPT via Clash.app`. Quit ChatGPT fully with Command-Q, then double-click the new app. Keep the proxy running. Pin the new app to Dock if desired.

Rollback: Quit ChatGPT and launch the original `/Applications/ChatGPT.app`. Delete the launcher if unused. No global `launchctl` setting is made.

### Copy the ChatGPT icon locally

1. Select `/Applications/ChatGPT.app` in Finder and press Command-I.
2. Click the small icon at the upper left of Get Info and press Command-C.
3. Select `ChatGPT via Clash.app`, press Command-I, click its small upper-left icon, and press Command-V. Enter your Mac password if prompted.
4. If Dock still shows an old icon, remove and re-add the new app.

The icon is copied on your own Mac; this repository does not distribute OpenAI artwork.

## Windows: process-only and persistent proxy options

Windows uses the same mobile download and pairing steps, but its proxy setup differs.

Using port 7897 or another port? The scripts prompt for the actual port; enter `7897`, or pass `-Port 7897` to skip the prompt. Use the same actual HTTP/mixed proxy port in the `curl.exe` test below.

1. Find the local proxy port with `netstat -ano | findstr LISTENING`, and confirm the proxy process owns the PID. Test it with `curl.exe -I -x http://127.0.0.1:7890 https://chatgpt.com`. HTTP access does not prove Remote connectivity.
2. If you have a directly executable ChatGPT `.exe`, try [`windows/Start-ChatGPT-With-Proxy.ps1`](windows/Start-ChatGPT-With-Proxy.ps1) first. It gives that launch proxy variables without changing user settings. Microsoft Store shortcuts may launch through a shell broker and may not preserve them.
3. For persistent user variables, run [`windows/Set-UserProxy.ps1`](windows/Set-UserProxy.ps1), quit ChatGPT normally, sign out and back into Windows or restart, then open ChatGPT. It sets `HTTP_PROXY`, `HTTPS_PROXY`, `ALL_PROXY`, and `NO_PROXY` for future processes and can affect other apps that honor them. [`windows/Restore-UserProxy.ps1`](windows/Restore-UserProxy.ps1) removes only variables the setup script created, if their values have not changed.

From PowerShell at the repository root, after reviewing the scripts:

```powershell
.\windows\Set-UserProxy.ps1
# Enter the actual port at the prompt, for example 7897.
# Quit ChatGPT, sign out/in or restart, then test Remote.
.\windows\Restore-UserProxy.ps1
```

Optional direct-executable test (replace the path):

```powershell
.\windows\Start-ChatGPT-With-Proxy.ps1 -ChatGPTExe 'C:\Path\To\ChatGPT.exe'
# Enter the actual port at the prompt.
```

User-level variables do not update already-running apps. Quit ChatGPT normally. See Microsoft's [environment variable guide](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_Environment_Variables) and [`setx` documentation](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/setx). If script execution is restricted, follow your computer's PowerShell or organization policy instead of changing system-wide policy for this guide.

## Troubleshooting

| Symptom | Next step |
| --- | --- |
| `Timed out waiting for remote control to connect` before QR (observed on the tested Mac) | The desktop Host was not ready before phone scanning. Check the proxy port and host connectivity, quit ChatGPT, and retry with the relevant launcher. The message alone does not identify the failed connection. |
| `Unable to enable remote control, please try again` | Update and restart the desktop app. Check account, Workspace, administrator policy, and [official setup](https://learn.chatgpt.com/docs/remote-connections). |
| QR appears but phone cannot find or pair with host | Confirm the same account and Workspace, update mobile ChatGPT, rescan, and keep the computer awake. |
| Host connects then goes offline | Check sleep, network, ChatGPT, proxy software, and the selected node. |
| HTTP proxy works but Remote fails | HTTP access is not proof of a stable WebSocket. Check rules against [OpenAI network guidance](https://help.openai.com/en/articles/9247338-network-recommendations-for-chatgpt-errors-on-web-and-apps). Match log timestamps and component names before attributing generic WebSocket errors to Remote. |
| Launcher reports ChatGPT already running | Fully quit ChatGPT before launching it with new variables. |
| Some Local Projects are missing on mobile | Pairing and project selection are separate. Choose the correct host and Workspace, confirm the project exists on desktop, then check the mobile host/project controls. The mobile landing page may not mirror every desktop view. See [Remote](https://learn.chatgpt.com/docs/remote-connections) and [local environment](https://learn.chatgpt.com/docs/environments/local-environment) docs. |

## Related projects

- [gemini-mac-no-tun](https://github.com/garybeyond/gemini-mac-no-tun) — No-TUN launcher for Gemini desktop (similar approach)

## Scope and contribution

Remote lets you continue and review Codex work on a connected host; it is not full desktop screen control. See the [OpenAI overview](https://developers.openai.com/blog/mastering-codex-remote-for-engineering). Never publish QR codes, pairing codes, account IDs, tokens, full logs, subscriptions, or private project names. This independent project is not affiliated with OpenAI or Clash Verge. The Mac case was tested on one machine; Windows needs real-world validation.

Reproducible reports, test results from other proxy apps, and documentation fixes are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).
