# Quick Start - Media Sync Fix

## Issues Fixed

1. **Buffer polyfill added** - React Native doesn't have Node.js Buffer API (global polyfill + explicit import)
2. **Route cache issue** - Metro bundler needs cache cleared
3. **Module import order** - Buffer polyfill loads before services

## Steps to Fix

### 1. Clear Metro Cache and Restart

```bash
cd src

# Clear all caches
npx expo start --clear
```

**Or if that doesn't work:**

```bash
cd src

# Clear Metro cache
rm -rf .expo
rm -rf node_modules/.cache

# Restart
npx expo start
```

### 2. Rebuild the App (REQUIRED for network changes)

The `app.json` network security changes require a native rebuild:

```bash
cd src

# For Android
npx expo run:android

# For iOS
npx expo run:ios
```

**Important:** Just clearing cache and running `expo start` won't apply the network security changes. You MUST rebuild.

## Verification

After rebuilding, you should see:

1. **No route errors** - "media" route should load correctly
2. **No Buffer errors** - Buffer polyfill is working
3. **TCP connection available** - HereSphere service can create sockets

## Test the Fix

1. Open the app
2. Go to Media Sync tab (should not crash)
3. Configure HereSphere:
   - IP: `192.168.178.30` (or your HereSphere IP)
   - Port: `23554`
4. Click "Test HereSphere Connection"
5. Watch console logs:

**Expected output:**
```
[HereSphere] Configured: 192.168.178.30:23554
[HereSphere] Connecting to 192.168.178.30:23554...
[HereSphere] Connected to TCP socket
[HereSphere] Sent keep-alive
```

## If Still Having Issues

### Route Error Persists
```bash
# Nuclear option: delete all caches
cd src
rm -rf .expo
rm -rf node_modules/.cache
rm -rf node_modules
npm install
npx expo start --clear
```

### Buffer Error Persists
- Check that `app/_layout.tsx` has the Buffer polyfill at the top
- Restart Metro bundler completely

### Connection Error
- Verify you rebuilt the app (not just restarted Metro)
- Check HereSphere is running on the correct IP/port
- Use `telnet 192.168.178.30 23554` to test from computer

## What Was Changed

### Files Modified:
1. **`app/_layout.tsx`** - Added Buffer polyfill
2. **`package.json`** - Added `buffer` dependency
3. **`app.json`** - Network security settings (requires rebuild)

### No Code Changes Needed
The media.tsx file is correct, just needed cache clear.
