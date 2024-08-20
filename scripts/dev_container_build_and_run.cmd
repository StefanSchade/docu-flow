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

REM Initialize rebuild flag
set REBUILD=0

REM Check if the image exists locally and get the creation date
for /f "tokens=2 delims=," %%t in ('docker inspect --format="Created,{{.Created}}" %IMAGE_NAME% 2^>nul') do set IMAGE_TIMESTAMP=%%t

REM If the image doesn't exist, trigger a rebuild
if "%IMAGE_TIMESTAMP%"=="" (
    echo Docker image not found locally, triggering rebuild...
    set REBUILD=1
) else (
    REM Convert image timestamp to a comparable format (YYYYMMDD)
    for /f "tokens=1 delims=T" %%d in ("%IMAGE_TIMESTAMP%") do set IMAGE_TIMESTAMP=%%d
    set IMAGE_TIMESTAMP=%IMAGE_TIMESTAMP:~0,10%
)

REM Check if any relevant file has a newer timestamp than the image
for %%f in (%PROJECT_ROOT%\docker\Dockerfile.dev %PROJECT_ROOT%\scripts\dev_container*.cmd) do (
    if exist %%f (
        REM Get the file's timestamp in YYYYMMDD format
        for /f "tokens=1" %%t in ('powershell -command "(Get-Item %%f).LastWriteTime.ToString(\'yyyyMMdd\')"') do set FILE_TIMESTAMP=%%t
        REM Compare the file timestamp with the image timestamp
        if "%FILE_TIMESTAMP%" GTR "%IMAGE_TIMESTAMP%" (
            echo %%f has been modified after the image was built, triggering rebuild...
            set REBUILD=1
        )
    )
)

REM Rebuild the image if necessary
if "%REBUILD%"=="1" (
    echo Rebuilding Docker image...
    call dev_container_build.cmd %IMAGE_NAME%
)

REM Run the container
call dev_container_run.cmd %IMAGE_NAME% %DATA_DIR%

