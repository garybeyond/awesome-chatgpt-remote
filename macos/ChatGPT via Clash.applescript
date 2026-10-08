use scripting additions

property proxyHost : "127.0.0.1"

on run
    set chatgptBinary to "/Applications/ChatGPT.app/Contents/MacOS/ChatGPT"
    try
        set proxyPort to text returned of (display dialog "Enter your local HTTP/SOCKS mixed proxy port:" default answer "7890" buttons {"Cancel", "Continue"} default button "Continue")
    on error number -128
        return
    end try
    try
        do shell script "/bin/echo " & quoted form of proxyPort & " | /usr/bin/grep -Eq '^[0-9]{1,5}$'"
        if (proxyPort as integer) < 1 or (proxyPort as integer) > 65535 then error "Invalid port"
    on error
        display alert "Invalid proxy port" message "Enter a number from 1 to 65535."
        return
    end try
    set proxyHttp to "http://" & proxyHost & ":" & proxyPort
    set proxySocks to "socks5h://" & proxyHost & ":" & proxyPort

    try
        do shell script "/usr/bin/test -x " & quoted form of chatgptBinary
    on error
        display alert "ChatGPT.app not found" message "Install the official ChatGPT app in /Applications first."
        return
    end try

    try
        do shell script "/usr/bin/pgrep -x ChatGPT"
        display alert "ChatGPT is already running" message "Quit ChatGPT with Command-Q, then open this launcher again."
        return
    end try

    try
        do shell script "/usr/bin/nc -z " & proxyHost & " " & proxyPort
    on error
        display alert "Local proxy is unavailable" message (proxyHost & ":" & proxyPort & " is not responding. Start your proxy app first.")
        return
    end try

    set noProxy to "localhost,127.0.0.1,::1"
    set launchCommand to "/usr/bin/nohup /usr/bin/env " & ¬
        "HTTP_PROXY=" & quoted form of proxyHttp & " " & ¬
        "HTTPS_PROXY=" & quoted form of proxyHttp & " " & ¬
        "ALL_PROXY=" & quoted form of proxySocks & " " & ¬
        "http_proxy=" & quoted form of proxyHttp & " " & ¬
        "https_proxy=" & quoted form of proxyHttp & " " & ¬
        "all_proxy=" & quoted form of proxySocks & " " & ¬
        "NO_PROXY=" & quoted form of noProxy & " " & ¬
        "no_proxy=" & quoted form of noProxy & " " & ¬
        quoted form of chatgptBinary & " >/dev/null 2>&1 </dev/null &"

    do shell script launchCommand
end run
