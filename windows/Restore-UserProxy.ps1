# Removes only variables created by Set-UserProxy.ps1, if their values are unchanged.
$stateFile = Join-Path (Join-Path $env:LOCALAPPDATA 'AwesomeChatGPTRemote') 'created-user-variables.json'
if (-not (Test-Path -LiteralPath $stateFile)) {
    throw 'No launcher state file found. Nothing was changed.'
}

$saved = Get-Content -LiteralPath $stateFile -Raw | ConvertFrom-Json
$allRestored = $true
foreach ($name in @($saved.created)) {
    $expected = $saved.expected.PSObject.Properties[$name].Value
    $current = [Environment]::GetEnvironmentVariable($name, 'User')
    if ($current -eq $expected) {
        [Environment]::SetEnvironmentVariable($name, '', 'User')
        Write-Host "Removed user variable: $name"
    } else {
        Write-Warning "Kept $name because its value changed after setup."
        $allRestored = $false
    }
}

if ($allRestored) { Remove-Item -LiteralPath $stateFile }
Write-Host 'Sign out and back into Windows (or restart) to refresh future apps.'
