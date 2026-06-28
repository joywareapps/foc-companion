#!/bin/bash
# Build FOC Companion for Windows (run from Git Bash or WSL on Windows)
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
