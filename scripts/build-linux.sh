#!/bin/bash
# Build FOC Companion for Linux
# Requires: clang, cmake, ninja-build, libgtk-3-dev, pkg-config
#   sudo apt install clang cmake ninja-build libgtk-3-dev pkg-config
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/../foc-companion"

echo "==> Building FOC Companion for Linux..."
cd "$PROJECT_DIR"

flutter pub get
flutter build linux --release

echo ""
echo "==> Build complete."
echo "    Bundle: $PROJECT_DIR/build/linux/x64/release/bundle/"
