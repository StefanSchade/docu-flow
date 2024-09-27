@echo off 
REM Script to run the Docker container for development 

REM Check if expected number of arguments are provided
if "%~4"=="" (
    echo Usage: dev_container_run.cmd [image_name] [volume_name] [data_directory_path] [run_cmd]
    exit /b 1
)

REM Define the image name
set IMAGE_NAME=%~1
echo Image name: %IMAGE_NAME%

REM Define the volume name
set VOLUME_NAME=%~2
echo Volume name: %IMAGE_NAME%

REM Get the absolute path of the data directory
for %%I in (%~3) do set "DATA_DIR=%%~fI"
echo Data dir: %DATA_DIR%

REM Define the run command
set RUN_CMD=%~4
echo Run command: %IMAGE_NAME%

REM Determine the project root directory based on the script's location
set "PROJECT_ROOT=%~dp0.."
echo Project root: %IMAGE_NAME%

REM Start the development container with line breaks using caret (^)
docker run -it --rm ^
    --name %IMAGE_NAME% ^
    -v %VOLUME_NAME%:/venv ^
    -v %DATA_DIR%:/data ^
    -v %PROJECT_ROOT%:/workspace:ro ^
    -v %PROJECT_ROOT%/target:/target ^
    -v /var/run/docker.sock:/var/run/docker.sock ^
    -w /workspace ^
    %IMAGE_NAME% ^
    %RUN_CMD%

