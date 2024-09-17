# file_times.ps1

$DockerfilePath = "..\docker\Dockerfile.dev"  # Update this path
$ScriptsPath = ".\"

# Get Dockerfile modification times
$dockerfileItem = Get-Item $DockerfilePath
Write-Host "Dockerfile modification time (Local): $($dockerfileItem.LastWriteTime)"
Write-Host "Dockerfile modification time (UTC):   $($dockerfileItem.LastWriteTimeUtc)"

# Get latest script modification time
$scriptFiles = Get-ChildItem "$ScriptsPath\*.sh" -File -ErrorAction SilentlyContinue
if ($scriptFiles) {
    $latestScript = $scriptFiles | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1
    Write-Host "Latest script modification time (Local): $($latestScript.LastWriteTime)"
    Write-Host "Latest script modification time (UTC):   $($latestScript.LastWriteTimeUtc)"
} else {
    Write-Host "No scripts found."
}

