🔨 Common Expo Rebuild Commands
1. Clean Rebuild (Most Common)

# Clear Metro bundler cache and restart
npx expo start --clear

# Or shorter version
npx expo start -c
2. Regenerate Native Projects (Prebuild)

# Generate fresh /android and /ios directories
npx expo prebuild --clean

# Platform-specific
npx expo prebuild --platform android --clean
npx expo prebuild --platform ios --clean
3. Full Native Build

# Build and run on Android (generates native code + runs)
npx expo run:android

# With cache clearing
npx expo run:android --no-build-cache

# Clean build
rm -rf android && npx expo run:android
4. Complete Clean Slate

# Nuclear option - removes everything and rebuilds
rm -rf node_modules
rm -rf android ios
npm install
npx expo prebuild --clean
npx expo run:android
📱 For Your Current Project
Since you just upgraded React Native to 0.83.1, I recommend:

# Step 1: Clear Metro cache and test
cd src
npx expo start --clear

# Step 2: If needed, regenerate native code
npx expo prebuild --clean --platform android

# Step 3: Build and run on device/emulator
npx expo run:android
🎯 Quick Reference
Command	Purpose	When to Use
expo start -c	Clear Metro cache	After package updates
expo prebuild --clean	Regenerate native dirs	After native dependency changes
expo run:android	Build + run native	Testing on device/emulator
rm -rf android && expo run:android	Nuclear rebuild	When prebuild doesn't help
