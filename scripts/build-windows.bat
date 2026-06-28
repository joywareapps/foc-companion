@echo off
REM Build FOC Companion for Windows (native cmd / PowerShell)
setlocal

set SCRIPT_DIR=%~dp0
set PROJECT_DIR=%SCRIPT_DIR%..\foc-companion

echo =^> Building FOC Companion for Windows...
cd /d "%PROJECT_DIR%"

call flutter pub get
call flutter build windows --release

echo.
echo =^> Build complete.
echo     EXE: %PROJECT_DIR%\build\windows\x64\runner\Release\
