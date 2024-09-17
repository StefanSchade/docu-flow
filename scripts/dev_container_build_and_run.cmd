@echo off
REM Script to build and run the Docker container for development

REM Load shared environment variables
call "%~dp0dev_container_env.cmd"

REM Initialize variables
set "FORCE_REBUILD=0"
set "RUN_CMD="

REM Parse command-line arguments
:parse_args
if "%~1"=="" goto end_parse
if /I "%~1"=="--force-rebuild" (
    set "FORCE_REBUILD=1"
) else (
    if "%RUN_CMD%"=="" (
        set "RUN_CMD=%~1"
    ) else (
        set "RUN_CMD=%RUN_CMD% %~1"
    )
)
shift
goto parse_args

:end_parse

REM Build the container
call "%~dp0dev_container_build.cmd" %* --force-rebuild %FORCE_REBUILD%

REM Run the container
if "%RUN_CMD%"=="" (
    call "%~dp0dev_container_run.cmd"
) else (
    call "%~dp0dev_container_run.cmd" %RUN_CMD%
)

