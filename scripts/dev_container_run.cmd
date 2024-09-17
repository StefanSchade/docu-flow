@echo off
REM Script to run the Docker container for development

REM Load shared environment variables
call "%~dp0dev_container_env.cmd"

REM Default run command
set "RUN_CMD=/bin/bash"

REM Check for additional command-line arguments
if not "%~1"=="" (
    set "RUN_CMD=%*"
)

echo Debug: CONTAINER_NAME=%CONTAINER_NAME%
echo Debug: Checking if container "%CONTAINER_NAME%" exists...

REM Initialize CONTAINER_EXISTS variable
set "CONTAINER_EXISTS="

REM Use a for /f loop to check if the container exists
for /f "usebackq tokens=*" %%C in (`docker ps -a --filter "name=^%CONTAINER_NAME%$" --format "{{.Names}}"`) do (
    echo Found container: "%%C"
    if /I "%%C"=="%CONTAINER_NAME%" (
        set "CONTAINER_EXISTS=1"
    )
)

if defined CONTAINER_EXISTS (
    echo Debug: Container "%CONTAINER_NAME%" exists.
    REM Check if it's running
    set "CONTAINER_STATUS=stopped"
    for /f "usebackq tokens=*" %%C in (`docker ps --filter "name=^%CONTAINER_NAME%$" --format "{{.Names}}"`) do (
        if /I "%%C"=="%CONTAINER_NAME%" (
            set "CONTAINER_STATUS=running"
        )
    )
    echo.
    powershell -Command "Write-Host 'WARNING: A container named \"%CONTAINER_NAME%\" is %CONTAINER_STATUS%.' -ForegroundColor Red"
    powershell -Command "Write-Host 'Do you want to stop and remove it? (Y/N)' -ForegroundColor Red"

    REM Prompt the user
    set /p "USER_INPUT=> "
    if /I "%USER_INPUT%"=="Y" (
        echo Stopping and removing the existing container "%CONTAINER_NAME%"...
        docker stop %CONTAINER_NAME%
        REM Attempt to remove the container, but ignore errors if it doesn't exist
        docker rm %CONTAINER_NAME% >nul 2>&1
    ) else (
        echo Cannot start a new container with the same name. Exiting.
        exit /b 1
    )
) else (
    echo Debug: No existing container named "%CONTAINER_NAME%" found.
)

echo Starting the container...
REM Start the development container
docker run -it --rm ^
    --name %CONTAINER_NAME% ^
    -v %VOLUME_NAME%:/venv ^
    -v %PROJECT_ROOT%\data:/data ^
    -v %PROJECT_ROOT%:/workspace:ro ^
    -v %PROJECT_ROOT%\target:/target ^
    -v //var/run/docker.sock:/var/run/docker.sock ^
    -w /workspace ^
    %IMAGE_NAME% ^
    %RUN_CMD%

