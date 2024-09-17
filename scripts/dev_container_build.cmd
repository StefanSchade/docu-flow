@echo off
REM Script to build the Docker image for development

REM Load shared environment variables
call "%~dp0dev_container_env.cmd"

REM Parse command-line arguments
set "FORCE_REBUILD=0"
for %%I in (%*) do (
    if /I "%%I"=="--force-rebuild" (
        set "FORCE_REBUILD=1"
    )
)

REM Check if the image exists
docker image inspect %IMAGE_NAME% >nul 2>&1
if %ERRORLEVEL%==0 (
    set "IMAGE_EXISTS=1"
) else (
    set "IMAGE_EXISTS=0"
)

REM Determine if rebuild is needed
if %FORCE_REBUILD%==1 (
    echo Force rebuild requested.
    set "REBUILD_NEEDED=1"
) else if %IMAGE_EXISTS%==0 (
    echo Docker image "%IMAGE_NAME%" does not exist. Build required.
    set "REBUILD_NEEDED=1"
) else (
    REM Get image creation time
    for /f "tokens=1 delims=T" %%i in ('docker image inspect -f "{{.Created}}" %IMAGE_NAME%') do set "IMAGE_CREATED=%%i"
    REM Convert to timestamp
    for /f "tokens=1,2 delims=-" %%a in ("%IMAGE_CREATED%") do set "IMAGE_DATE=%%a%%b%%c"

    REM Get the latest modification time of Dockerfile and scripts
    for %%F in ("%DOCKERFILE_PATH%") do set "DOCKERFILE_MODIFIED=%%~tF"
    for /f "delims=" %%F in ('dir "%SCRIPTS_PATH%\*.sh" /b /od') do set "LATEST_SCRIPT=%%F"
    for %%F in ("%SCRIPTS_PATH%\%LATEST_SCRIPT%") do set "SCRIPT_MODIFIED=%%~tF"

    REM Compare times
    if "%DOCKERFILE_MODIFIED%" GTR "%IMAGE_CREATED%" (
        echo Dockerfile modified after image was created. Rebuild required.
        set "REBUILD_NEEDED=1"
    ) else if "%SCRIPT_MODIFIED%" GTR "%IMAGE_CREATED%" (
        echo Scripts modified after image was created. Rebuild required.
        set "REBUILD_NEEDED=1"
    ) else (
        echo No rebuild needed. Image is up-to-date.
        set "REBUILD_NEEDED=0"
    )

)

if %REBUILD_NEEDED%==1 (
    echo Building Docker image "%IMAGE_NAME%"...
    docker build -f "%DOCKERFILE_PATH%" -t %IMAGE_NAME% "%PROJECT_ROOT%"
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to build Docker image "%IMAGE_NAME%".
        exit /b 1
    )
    echo Docker image "%IMAGE_NAME%" built successfully.
) else (
    echo Skipping Docker image build.
)

REM Check if volume exists, create if it doesn't
docker volume inspect %VOLUME_NAME% >nul 2>&1
if %ERRORLEVEL%==0 (
    echo Docker volume "%VOLUME_NAME%" already exists.
) else (
    echo Creating Docker volume "%VOLUME_NAME%"...
    docker volume create %VOLUME_NAME%
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to create Docker volume "%VOLUME_NAME%".
        exit /b 1
    )
)

