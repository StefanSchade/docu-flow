# Shared environment variables for Docker development container scripts

# Define the image and container name
$IMAGE_NAME = "dev-docu-flow"
$CONTAINER_NAME = "dev-docu-flow"
$VOLUME_NAME = "docu-flow-venv"

# Determine the project root directory based on the script's location
$PROJECT_ROOT = (Resolve-Path "$PSScriptRoot\..").Path

# Define the path to the Dockerfile
$DOCKERFILE_PATH = "$PROJECT_ROOT\docker\Dockerfile.dev"

# Define the scripts directory
$SCRIPTS_PATH = "$PROJECT_ROOT\scripts"

