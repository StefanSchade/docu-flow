@echo off 
REM Script to run the Docker container for development 

REM Check if image name and data directory arguments are provided
if "%~1"=="" (
    echo Usage: dev_container_run.cmd [image_name] [volume_name] [data_directory_path] [run_cmd]
    exit /b 1
)
if "%~2"=="" (
    echo Usage: dev_container_run.cmd [image_name] [volume_name] [data_directory_path] [run_cmd]
    exit /b 1
)
if "%~3"=="" (
    echo Usage: dev_container_run.cmd [image_name] [volume_name] [data_directory_path] [run_cmd]
    exit /b 1
)

if "%~4"=="" (
    echo Usage: dev_container_run.cmd [image_name] [volume_name] [data_directory_path] [run_cmd]
    exit /b 1
)

REM Define the image name
set IMAGE_NAME=%~1

REM Define the run command
set RUN_CMD=%~4

REM Get the absolute path of the data directory
for %%I in (%~2) do set "DATA_DIR=%%~fI"

REM Determine the project root directory based on the script's location
set "PROJECT_ROOT=%~dp0.."

REM Start the development container with line breaks using caret (^)
docker run -it --rm ^
    --name %IMAGE_NAME% ^
    -v %VOLUME_NAME%:/venv ^
    -v %DATA_DIR%:/data:ro ^
    -v %PROJECT_ROOT%:/workspace:ro ^
    -v %PROJECT_ROOT%/target:/target ^
    -v /var/run/docker.sock:/var/run/docker.sock ^
    -w /workspace ^
    %IMAGE_NAME% ^
    %RUN_CMD%

