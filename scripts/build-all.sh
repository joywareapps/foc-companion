#!/bin/bash
# Build FOC Companion for all platforms supported on this host.
# Pass platform names as arguments to limit builds, e.g.:
#   ./build-all.sh android windows
# With no arguments, all host-supported platforms are attempted.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/../foc-companion"

REQUESTED=("$@")

build_if_requested() {
  local platform="$1"
  if [ ${#REQUESTED[@]} -eq 0 ] || [[ " ${REQUESTED[*]} " == *" $platform "* ]]; then
    return 0
  fi
  return 1
}

echo "==> FOC Companion – multi-platform build"
cd "$PROJECT_DIR"
flutter pub get

FAILED=()

# ── Android ──────────────────────────────────────────────────────────────────
if build_if_requested android; then
  echo ""
  echo "--- Android ---"
  flutter build apk --release && flutter build appbundle --release \
    && echo "    APK/AAB: build/app/outputs/" \
    || FAILED+=("android")
fi

# ── Windows ──────────────────────────────────────────────────────────────────
if build_if_requested windows; then
  if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OS" == "Windows_NT" ]]; then
    echo ""
    echo "--- Windows ---"
    flutter build windows --release \
      && echo "    EXE: build/windows/x64/runner/Release/" \
      || FAILED+=("windows")
  else
    echo "(skipping windows – not running on Windows)"
  fi
fi

# ── Linux ────────────────────────────────────────────────────────────────────
if build_if_requested linux; then
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo ""
    echo "--- Linux ---"
    flutter build linux --release \
      && echo "    Bundle: build/linux/x64/release/bundle/" \
      || FAILED+=("linux")
  else
    echo "(skipping linux – not running on Linux)"
  fi
fi

# ── macOS ────────────────────────────────────────────────────────────────────
if build_if_requested macos; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo ""
    echo "--- macOS ---"
    flutter build macos --release \
      && echo "    App: build/macos/Build/Products/Release/foc_companion.app" \
      || FAILED+=("macos")
  else
    echo "(skipping macos – not running on macOS)"
  fi
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
if [ ${#FAILED[@]} -eq 0 ]; then
  echo "==> All builds succeeded."
else
  echo "==> The following builds FAILED: ${FAILED[*]}"
  exit 1
fi
