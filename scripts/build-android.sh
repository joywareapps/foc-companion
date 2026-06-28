#!/bin/bash
# Build FOC Companion for Android (APK + AAB)
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/../foc-companion"

echo "==> Building FOC Companion for Android..."
cd "$PROJECT_DIR"

flutter pub get
flutter build apk --release
flutter build appbundle --release

echo ""
echo "==> Build complete."
echo "    APK: $PROJECT_DIR/build/app/outputs/flutter-apk/app-release.apk"
echo "    AAB: $PROJECT_DIR/build/app/outputs/bundle/release/app-release.aab"
