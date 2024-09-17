@echo off
REM Shared environment variables for Docker development container scripts

REM Define the image name and volume name
set "IMAGE_NAME=dev-docu-flow"
set "CONTAINER_NAME=dev-docu-flow"
set "VOLUME_NAME=docu-flow-venv"

REM Determine the project root directory based on the script's location
set "PROJECT_ROOT=%~dp0.."

REM Define the path to the Dockerfile
set "DOCKERFILE_PATH=%PROJECT_ROOT%\docker\Dockerfile.dev"

REM Define the scripts directory
set "SCRIPTS_PATH=%PROJECT_ROOT%\scripts"

