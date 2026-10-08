# Optional per-process launcher. Requires a real, directly executable ChatGPT .exe path.
# Store-app shell shortcuts may NOT preserve these environment variables.
param(
    [Parameter(Mandatory = $true)]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
    [string]$ChatGPTExe,

    [ValidateRange(1, 65535)]
    [int]$Port
)

if (-not $PSBoundParameters.ContainsKey('Port')) {
    $inputPort = Read-Host 'Enter your local HTTP/mixed proxy port (1-65535)'
    $parsedPort = 0
    if (-not [int]::TryParse($inputPort, [ref]$parsedPort) -or $parsedPort -lt 1 -or $parsedPort -gt 65535) {
        throw 'Invalid port. Enter a number from 1 to 65535.'
    }
    $Port = $parsedPort
}

if (Get-Process -Name ChatGPT -ErrorAction SilentlyContinue) {
    throw 'ChatGPT is already running. Fully quit it before using this launcher.'
}

$proxy = "http://127.0.0.1:$Port"
$desired = [ordered]@{
    HTTP_PROXY  = $proxy
    HTTPS_PROXY = $proxy
    ALL_PROXY   = $proxy
    NO_PROXY    = 'localhost,127.0.0.1,::1'
}
$previous = @{}

try {
    foreach ($name in $desired.Keys) {
        $previous[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
        [Environment]::SetEnvironmentVariable($name, $desired[$name], 'Process')
    }
    Start-Process -FilePath $ChatGPTExe
    Write-Host 'Started ChatGPT with process-only proxy variables. Other apps were not changed.'
} finally {
    foreach ($name in $desired.Keys) {
        [Environment]::SetEnvironmentVariable($name, $previous[$name], 'Process')
    }
}
