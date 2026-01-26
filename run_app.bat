@echo off
setlocal

REM Always run from this BAT file's folder
cd /d "%~dp0"

REM Python folder inside same directory
set "PYDIR=%~dp0python"

REM Set Python environment
set "PYTHONHOME=%PYDIR%"
set "PYTHONPATH=%PYDIR%;%PYDIR%\Lib;%PYDIR%\DLLs;%PYDIR%\site-packages"
set "PATH=%PYDIR%;%PATH%"

REM Run the main app exe
start "" "%~dp0app.exe"
exit /b
