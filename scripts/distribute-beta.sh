#!/bin/bash

# Local Distribution Script for FOC Companion Beta
# Requirement: Install Firebase CLI (npm install -g firebase-tools)
# Requirement: Authenticate (firebase login)

set -e

# Configuration
PROJECT_DIR="foc-companion"
APP_ID_DEFAULT="1:803111218509:android:1e0a70a53276d669a6db04"
GROUPS="beta-testers"

echo "🚀 Starting Beta Distribution for FOC Companion..."

# 1. Ask for Firebase App ID if not set
if [ -z "$FIREBASE_APP_ID" ]; then
    read -p "Enter Firebase App ID: " FIREBASE_APP_ID
fi

if [ -z "$FIREBASE_APP_ID" ]; then
    echo "❌ Error: FIREBASE_APP_ID is required."
    exit 1
fi

# 2. Navigate and Build
echo "📦 Building APK..."
cd "$PROJECT_DIR"
flutter pub get
./../generate_protos.sh
flutter build apk --release

# 3. Release Notes
RELEASE_NOTES="Local build - $(date +'%Y-%m-%d %H:%M:%S')"

# 4. Upload to Firebase
echo "📤 Uploading to Firebase App Distribution..."
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk 
    --app "$FIREBASE_APP_ID" 
    --groups "$GROUPS" 
    --release-notes "$RELEASE_NOTES"

echo "✅ Beta successfully distributed to group: $GROUPS"
