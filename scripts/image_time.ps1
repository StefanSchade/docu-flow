# image_time.ps1

$IMAGE_NAME = "dev-docu-flow"  # Update this if necessary

Try {
    $image = docker image inspect $IMAGE_NAME 2>$null
    if ($image) {
        $imageData = $image | ConvertFrom-Json
        $imageCreated = [DateTime]::Parse($imageData.Created)
        Write-Host "Image creation time (UTC): $($imageCreated.ToUniversalTime())"
        Write-Host "Image creation time (Local): $($imageCreated.ToLocalTime())"
    } else {
        Write-Host "Docker image `"$IMAGE_NAME`" does not exist."
    }
} Catch {
    Write-Host "Failed to inspect Docker image `"$IMAGE_NAME`"."
}

