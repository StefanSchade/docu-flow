@echo off
REM Script to run the Docker container for development

REM Check if image name and data directory arguments are provided
if "%~1"=="" (
    echo Usage: dev_container_run.cmd [image_name] [data_directory_path]
    exit /b 1
)
if "%~2"=="" (
    echo Usage: dev_container_run.cmd [image_name] [data_directory_path]
    exit /b 1
)

REM Define the image name
set IMAGE_NAME=%~1

REM Get the absolute path of the data directory
for %%I in (%~2) do set "DATA_DIR=%%~fI"

REM Determine the project root directory based on the script's location
set "PROJECT_ROOT=%~dp0.."

REM Start the development container with line breaks using caret (^)
docker run -it --rm ^
    -v %DATA_DIR%:/workspace/data ^
    -v %PROJECT_ROOT%\src:/workspace/src ^
    -v %PROJECT_ROOT%\tests:/workspace/tests ^
    -v %PROJECT_ROOT%\scripts:/workspace/scripts ^
    -w /workspace ^
    %IMAGE_NAME% ^
    /bin/bash ^
    -c "bash /workspace/scripts/post_create.sh && /bin/bash"
