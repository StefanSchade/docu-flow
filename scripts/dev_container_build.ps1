Param(
    [switch]$ForceRebuild
)

# Load shared environment variables
. "$PSScriptRoot\dev_container_env.ps1"

# Function to check if rebuild is needed
function Check-RebuildNeeded {
    param (
        [string]$ImageName,
        [string]$DockerfilePath,
        [string]$ScriptsPath
    )

    # Attempt to inspect the image
    Try {
        $image = docker image inspect $ImageName 2>$null
        if (-not $image) {
            Write-Host "Docker image `"$ImageName`" does not exist. Build required."
            return $true
        }
    } Catch {
        Write-Host "Docker image `"$ImageName`" does not exist. Build required."
        return $true
    }

    $imageCreated = [DateTime]::Parse(($image | ConvertFrom-Json).Created).ToUniversalTime()
    Write-Host "Image creation time (UTC): $imageCreated"

    $dockerfileModified = (Get-Item $DockerfilePath).LastWriteTimeUtc
    Write-Host "Dockerfile modification time (UTC): $dockerfileModified"

    $scriptFiles = Get-ChildItem "$ScriptsPath\*.sh" -File -ErrorAction SilentlyContinue
    if ($scriptFiles) {
        $latestScriptModified = ($scriptFiles | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1).LastWriteTimeUtc
        Write-Host "Latest script modification time (UTC): $latestScriptModified"
    } else {
        $latestScriptModified = $dockerfileModified
        Write-Host "No scripts found. Using Dockerfile modification time."
    }

    if ($dockerfileModified -gt $imageCreated -or $latestScriptModified -gt $imageCreated) {
        Write-Host "Dockerfile or scripts modified after image was created. Rebuild required."
        return $true
    } else {
        Write-Host "No rebuild needed. Image is up-to-date."
        return $false
    }
}

$rebuildNeeded = $ForceRebuild.IsPresent

if (-not $rebuildNeeded) {
    $rebuildNeeded = Check-RebuildNeeded -ImageName $IMAGE_NAME -DockerfilePath $DOCKERFILE_PATH -ScriptsPath $SCRIPTS_PATH
}

if ($rebuildNeeded) {
    Write-Host "Building Docker image `"$IMAGE_NAME`"..."
    docker build -f "$DOCKERFILE_PATH" -t $IMAGE_NAME "$PROJECT_ROOT"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to build Docker image `"$IMAGE_NAME`"."
        exit 1
    }
    Write-Host "Docker image `"$IMAGE_NAME`" built successfully."
} else {
    Write-Host "Skipping Docker image build."
}

# Check if volume exists, create if it doesn't
Try {
    $volume = docker volume inspect $VOLUME_NAME 2>$null
    if ($volume) {
        Write-Host "Docker volume `"$VOLUME_NAME`" already exists."
    } else {
        Write-Host "Creating Docker volume `"$VOLUME_NAME`"..."
        docker volume create $VOLUME_NAME
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to create Docker volume `"$VOLUME_NAME`"."
            exit 1
        }
    }
} Catch {
    Write-Host "Creating Docker volume `"$VOLUME_NAME`"..."
    docker volume create $VOLUME_NAME
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to create Docker volume `"$VOLUME_NAME`"."
        exit 1
    }
}

