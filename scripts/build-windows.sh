#!/bin/bash
# Build FOC Companion for Windows (run from Git Bash or WSL on Windows)
#
# Prerequisite — serialport.dll (libserialport C library):
#   MSYS2:  pacman -S mingw-w64-x86_64-libserialport
#           cp /mingw64/bin/libserialport-0.dll foc-companion/windows/serialport.dll
#   vcpkg:  vcpkg install libserialport:x64-windows
#           cp <vcpkg>/installed/x64-windows/bin/serialport.dll foc-companion/windows/
# Without it the app builds but USB serial shows no ports at runtime.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/../foc-companion"

echo "==> Building FOC Companion for Windows..."
cd "$PROJECT_DIR"

flutter pub get
flutter build windows --release

echo ""
echo "==> Build complete."
echo "    EXE: $PROJECT_DIR/build/windows/x64/runner/Release/"
