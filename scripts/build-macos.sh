#!/bin/bash
# Build FOC Companion for macOS (must run on macOS with Xcode installed)
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/../foc-companion"

echo "==> Building FOC Companion for macOS..."
cd "$PROJECT_DIR"

flutter pub get
flutter build macos --release

echo ""
echo "==> Build complete."
echo "    App: $PROJECT_DIR/build/macos/Build/Products/Release/foc_companion.app"
