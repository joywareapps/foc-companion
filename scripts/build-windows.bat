@echo off
REM Build FOC Companion for Windows (native cmd / PowerShell)
REM
REM Prerequisite -- serialport.dll (libserialport C library):
REM   MSYS2:  pacman -S mingw-w64-x86_64-libserialport
REM           copy C:\msys64\mingw64\bin\libserialport-0.dll foc-companion\windows\serialport.dll
REM   vcpkg:  vcpkg install libserialport:x64-windows
REM           copy <vcpkg>\installed\x64-windows\bin\serialport.dll foc-companion\windows\
REM Without it the app builds but USB serial shows no ports at runtime.
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
