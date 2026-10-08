# Sets user-level proxy variables for future Windows processes.
# This affects other apps that honor these variables. No admin rights required.
param(
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

$proxy = "http://127.0.0.1:$Port"
$desired = [ordered]@{
    HTTP_PROXY  = $proxy
    HTTPS_PROXY = $proxy
    ALL_PROXY   = $proxy
    NO_PROXY    = 'localhost,127.0.0.1,::1'
}

$stateDir = Join-Path $env:LOCALAPPDATA 'AwesomeChatGPTRemote'
$stateFile = Join-Path $stateDir 'created-user-variables.json'
$created = @()
if (Test-Path -LiteralPath $stateFile) {
    $saved = Get-Content -LiteralPath $stateFile -Raw | ConvertFrom-Json
    $created = @($saved.created)
}

foreach ($name in $desired.Keys) {
    $current = [Environment]::GetEnvironmentVariable($name, 'User')
    if (-not [string]::IsNullOrEmpty($current) -and $current -ne $desired[$name]) {
        throw "User variable $name already has a different value. Nothing was changed. Review it manually before retrying."
    }
}

foreach ($name in $desired.Keys) {
    $current = [Environment]::GetEnvironmentVariable($name, 'User')
    if ([string]::IsNullOrEmpty($current)) { $created += $name }
}
New-Item -ItemType Directory -Force -Path $stateDir | Out-Null
@{ created = @($created | Select-Object -Unique); expected = $desired } |
    ConvertTo-Json -Depth 4 |
    Set-Content -LiteralPath $stateFile -Encoding UTF8
foreach ($name in $desired.Keys) {
    [Environment]::SetEnvironmentVariable($name, $desired[$name], 'User')
}

Write-Host "Saved user proxy variables for future processes: $proxy"
Write-Host 'Fully quit ChatGPT, then sign out and back into Windows (or restart) before testing Remote.'
Write-Host 'Rollback: run Restore-UserProxy.ps1 from this folder.'
