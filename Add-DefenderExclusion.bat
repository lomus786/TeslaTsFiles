@echo off
REM ============================================================
REM  Gadar - Add Windows Defender exclusion for this folder
REM  Fixes antivirus deleting driver.dll (false positive).
REM
REM  Place this file INSIDE the Gadar install folder and
REM  double-click it. It excludes the folder it sits in.
REM ============================================================

REM ---- Self-elevate to Administrator if not already ----
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    echo Requesting administrator privileges...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -ArgumentList '%*' -Verb RunAs"
    exit /b
)

set "TARGET=%~dp0"
REM Strip the trailing backslash so Defender stores a clean path
if "%TARGET:~-1%"=="\" set "TARGET=%TARGET:~0,-1%"

echo.
echo Adding Windows Defender exclusion for:
echo     %TARGET%
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "try { Add-MpPreference -ExclusionPath '%TARGET%' -ErrorAction Stop; Write-Host 'Folder exclusion added.' -ForegroundColor Green } catch { Write-Host ('FAILED: ' + $_.Exception.Message) -ForegroundColor Red; exit 1 }"

REM ---- Optional: also exclude the driver.dll file explicitly ----
if exist "%TARGET%\driver.dll" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "try { Add-MpPreference -ExclusionPath '%TARGET%\driver.dll' -ErrorAction Stop; Write-Host 'driver.dll file exclusion added.' -ForegroundColor Green } catch { Write-Host ('driver.dll exclusion FAILED: ' + $_.Exception.Message) -ForegroundColor Yellow }"
)

echo.
echo Done. Current Defender folder exclusions:
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "(Get-MpPreference).ExclusionPath"

echo.
echo If driver.dll was already removed, restore it from your
echo installer/backup AFTER running this file.
echo.

REM ---- Close automatically ----
REM   Run with /silent  -> no message, close immediately
REM   Otherwise         -> show a 5 second countdown then close
if /I "%~1"=="/silent" exit /b 0
echo This window will close in 5 seconds...
REM  ping is used instead of timeout/pause because it never waits
REM  for a keypress and works even when stdin is redirected.
ping -n 6 127.0.0.1 >nul
exit /b 0
