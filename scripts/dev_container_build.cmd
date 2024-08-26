@echo off
REM Script to build the Docker image for development

REM Check if image name argument is provided
if "%~1"=="" (
    echo Usage: dev_container_build.cmd [image_name] [volume_name]
    exit /b 1
)
if "%~2"=="" (
    echo Usage: dev_container_build.cmd [image_name] [volume_name]
    exit /b 1
)

REM Define the image name and volume name
set IMAGE_NAME=%~1
set VOLUME_NAME=%~2

REM Remove volume if it exists
docker volume inspect %VOLUME_NAME% >nul 2>&1
if %ERRORLEVEL%==0 (
    echo Removing existing Docker volume "%VOLUME_NAME%"...
    docker volume rm %VOLUME_NAME%
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to remove Docker volume "%VOLUME_NAME%". Ensure no containers are using it.
        exit /b 1
    )
) else (
    echo Docker volume "%VOLUME_NAME%" does not exist. Skipping removal.
)

REM Create new volume
echo Creating new Docker volume "%VOLUME_NAME%"...
docker volume create %VOLUME_NAME%
if %ERRORLEVEL% NEQ 0 (
    echo Failed to create Docker volume "%VOLUME_NAME%".
    exit /b 1
)

REM Determine the project root directory based on the script's location
set "PROJECT_ROOT=%~dp0.."

REM Define the relative path to the Dockerfile
set DOCKERFILE_PATH=%PROJECT_ROOT%\docker\Dockerfile.dev

REM Build the Docker image
echo Building Docker image "%IMAGE_NAME%" using Dockerfile at "%DOCKERFILE_PATH%"...
docker build -f "%DOCKERFILE_PATH%" -t %IMAGE_NAME% "%PROJECT_ROOT%"
if %ERRORLEVEL% NEQ 0 (
    echo Failed to build Docker image "%IMAGE_NAME%".
    exit /b 1
)

echo Docker image "%IMAGE_NAME%" built successfully.

