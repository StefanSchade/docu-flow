Param(
    [string[]]$RunCmd = "/bin/bash"
)

# Load shared environment variables
. "$PSScriptRoot\dev_container_env.ps1"

# Function to convert Windows paths to Docker-compatible paths
function Convert-PathToDocker($path) {
    # Replace backslashes with forward slashes and remove any trailing slash
    return ($path -replace '\\', '/') -replace '/$', ''
}

$ProjectRootDocker = Convert-PathToDocker($PROJECT_ROOT)

# Check if a container with the same name exists
$container = docker ps -a --filter "name=^$CONTAINER_NAME$" --format "{{.Names}}"

if ($container -eq $CONTAINER_NAME) {
    # Container exists
    # Check if it's running
    $runningContainer = docker ps --filter "name=^$CONTAINER_NAME$" --format "{{.Names}}"
    if ($runningContainer -eq $CONTAINER_NAME) {
        $CONTAINER_STATUS = "running"
    } else {
        $CONTAINER_STATUS = "stopped"
    }

    Write-Host "WARNING: A container named `"$CONTAINER_NAME`" is $CONTAINER_STATUS." -ForegroundColor Red
    $userInput = Read-Host "Do you want to stop and remove it? (Y/N)"
    if ($userInput -match '^(Y|y)$') {
        Write-Host "Stopping and removing the existing container `"$CONTAINER_NAME`"..."
        docker stop $CONTAINER_NAME
        docker rm $CONTAINER_NAME 2>$null
    } else {
        Write-Host "Cannot start a new container with the same name. Exiting."
        exit 1
    }
}

Write-Host "Starting the container..."

# Build the docker run arguments as an array
$dockerRunArgs = @(
    "run", "-it", "--rm",
    "--name", $CONTAINER_NAME,
    "-v", "${VOLUME_NAME}:/venv",
    "-v", "${ProjectRootDocker}/data:/data",
    "-v", "${ProjectRootDocker}:/workspace:ro",
    "-v", "${ProjectRootDocker}/target:/target",
    "-v", "//var/run/docker.sock:/var/run/docker.sock",
    "-w", "/workspace",
    $IMAGE_NAME
)

# Add the run command if specified
if ($RunCmd) {
    $dockerRunArgs += $RunCmd
}

# Run the docker command
& docker @dockerRunArgs

