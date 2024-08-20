@echo off
REM Central script to manage the build and run process for the Docker container

REM Check if data directory argument is provided
if "%~1"=="" (
    echo Usage: dev_container_build_and_run.cmd [data_directory_path]
    exit /b 1
)

REM Define the image name centrally
set IMAGE_NAME=dev-docu-flow

REM Get the absolute path of the data directory
for %%I in (%~1) do set "DATA_DIR=%%~fI"

REM Determine the project root directory based on the script's location
set "PROJECT_ROOT=%~dp0.."

REM Build the container
call dev_container_build.cmd %IMAGE_NAME%

REM Run the container
call dev_container_run.cmd %IMAGE_NAME% %DATA_DIR%

