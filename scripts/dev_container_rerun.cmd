@echo off
REM Script to rerun a container without rebuilding it

REM Check if data directory argument is provided
if "%~1"=="" (
    echo Usage: dev_container_build_and_run.cmd [data_directory_path] [start_comand]
    exit /b 1
)

REM Check if data directory argument is provided
if "%~2"=="" (
    echo Usage: dev_container_build_and_run.cmd [data_directory_path] [start_command]
    exit /b 1
)

REM Define image and volume names centrally
set IMAGE_NAME=dev-docu-flow
set VOLUME_NAME=docu-flow-venv

REM Get the absolute path of the data directory
for %%I in (%~1) do set "DATA_DIR=%%~fI"

REM Determine the project root directory based on the script's location
set "PROJECT_ROOT=%~dp0.."

echo Starting interactive shell
REM Run the container:
call dev_container_run.cmd %image_name% %volume_name% %data_dir% "%~2"  

