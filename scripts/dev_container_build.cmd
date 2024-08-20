@echo off
REM Script to build the Docker image for development

REM Check if image name argument is provided
if "%~1"=="" (
    echo Usage: dev_container_build.cmd [image_name]
    exit /b 1
)

REM Define the image name
set IMAGE_NAME=%~1

REM Determine the project root directory based on the script's location
set "PROJECT_ROOT=%~dp0.."

REM Define the relative path to the Dockerfile
set DOCKERFILE_PATH=%PROJECT_ROOT%\docker\Dockerfile.dev

docker build -f %DOCKERFILE_PATH% -t %IMAGE_NAME% %PROJECT_ROOT%
