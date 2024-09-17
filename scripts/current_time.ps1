# current_time.ps1

$localTime = Get-Date
$utcTime = (Get-Date).ToUniversalTime()

Write-Host "Current Local Time: $localTime"
Write-Host "Current UTC Time:   $utcTime"

