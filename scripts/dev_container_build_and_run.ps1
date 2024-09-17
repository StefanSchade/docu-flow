Param(
    [switch]$ForceRebuild,
    [string[]]$RunCmd
)

# Load shared environment variables
. "$PSScriptRoot\dev_container_env.ps1"

# Build the container
& "$PSScriptRoot\dev_container_build.ps1" @PSBoundParameters
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

# Run the container
& "$PSScriptRoot\dev_container_run.ps1" @PSBoundParameters

