# Media Sync Usage Guide

Complete implementation for synchronized playback between HereSphere video player and FOC-Stim device using funscript files.

## Overview

The Media Sync feature allows you to:
1. Connect to HereSphere video player via HTTP API
2. Load funscript files (haptic scripts)
3. Synchronize FOC-Stim device control with video playback
4. (Future) Access funscript files from SMB network shares

## IMPORTANT: First-Time Setup

**After adding Media Sync feature, you MUST rebuild the app:**

The app configuration was updated to allow HTTP traffic (required for local network communication with HereSphere). This requires a native rebuild:

```bash
cd src

# For Android
npx expo run:android

# For iOS
npx expo run:ios
```

**Simply running `expo start` is NOT enough - you must rebuild the native app.**

## Setup

### 1. Configure HereSphere Player

1. Navigate to **Media Sync** tab
2. Enable **HereSphere Player** toggle
3. Enter the IP address of the device running HereSphere
   - Example: `192.168.1.100`
4. Enter the port (default: `23554`)
5. Click **Save Settings**
6. Click **Test HereSphere Connection** to verify

### 2. Configure SMB Network Share (Optional - for future use)

1. Enable **SMB Network Share** toggle
2. Enter your network share path:
   - Windows format: `\\192.168.1.10\media`
   - SMB format: `smb://192.168.1.10/media`
3. Enter username and password for network authentication
4. Click **Save Settings**

## Using Synced Playback

### Prerequisites
- FOC-Stim device must be connected (use Control tab)
- HereSphere player must be running and configured
- Funscript file must be loaded

### Step-by-Step

1. **Connect FOC-Stim Device**
   - Go to Control tab
   - Enter device IP address
   - Click Connect

2. **Load Funscript**
   - Go to Media Sync tab
   - Paste funscript JSON into the text area
   - Example funscript format:
     ```json
     {
       "version": "1.0",
       "actions": [
         {"at": 0, "pos": 50},
         {"at": 1000, "pos": 80},
         {"at": 2000, "pos": 20}
       ]
     }
     ```
   - Click **Load Funscript**

3. **Start Synced Playback**
   - Ensure HereSphere has a video loaded
   - Click **Start Synced Playback**
   - The FOC-Stim device will sync with video playback
   - Status will show "Playing"

4. **Stop Synced Playback**
   - Click **Stop Synced Playback**
   - Device will ramp down safely

## How It Works

### Architecture

```
HereSphere Player (TCP Server)
        ↓ (TCP socket connection)
HereSphere Service
        ↓ (binary protocol: length-prefixed JSON)
SyncedPlayback Controller
        ↓ (reads position from funscript)
Funscript Parser
        ↓ (converts to device coordinates)
FOC-Stim Device (position commands)
```

### Protocol Details

HereSphere uses a **TCP socket connection** with a binary protocol:

**Outgoing (App → HereSphere):**
- Keep-alive: 4 null bytes `[0x00, 0x00, 0x00, 0x00]` every 1 second

**Incoming (HereSphere → App):**
- 4-byte header: Message length (little-endian)
- JSON payload with status data

**Status Message Format:**
```json
{
  "path": "/path/to/video.mp4",
  "currentTime": 123.45,
  "playbackSpeed": 1.0,
  "playerState": 0,
  "duration": 600.0
}
```
- `playerState`: 0 = playing, other = paused
- `currentTime`: Position in seconds

### Synchronization

1. **TCP Connection**: Establishes socket connection to HereSphere (port 23554)
2. **Keep-alive**: Sends heartbeat every 1 second to maintain connection
3. **Real-time Updates**: Receives status updates as video plays
4. **Time Mapping**: Current video timestamp is used to look up funscript position
5. **Interpolation**: Linear interpolation between funscript action points
6. **Position Updates**: Device receives position updates only when significant change (>1%)
7. **Auto-reconnect**: Automatically reconnects if connection is lost

### Funscript Format

Funscript files use JSON format:
- `actions`: Array of timestamp/position pairs
  - `at`: Timestamp in milliseconds
  - `pos`: Position value (0-100)
- `inverted`: Optional boolean (default: false)
- `range`: Optional range value (default: 100)

Position mapping:
- Funscript: 0-100 (bottom to top)
- Device: -1.0 to 1.0 (normalized coordinates)
- Conversion: `devicePos = (funscriptPos / 50.0) - 1.0`

## Troubleshooting

### "Cannot connect to HereSphere player" / "Connection timeout"
- Check IP address and port configuration (default port: 23554)
- Ensure HereSphere is running and TCP server is active
- Verify both devices are on same network (same WiFi)
- Check firewall isn't blocking TCP port 23554
- Test with **Test HereSphere Connection** button
- Use `telnet 192.168.178.30 23554` or `nc -zv 192.168.178.30 23554` from computer
- **IMPORTANT**: App must be rebuilt after initial setup (see below)

### "Device not connected"
- Go to Control tab
- Connect to FOC-Stim device first
- Return to Media Sync tab

### "No funscript loaded"
- Paste valid funscript JSON
- Click **Load Funscript** button
- Check for JSON parse errors

### Playback not syncing
- Ensure video is playing in HereSphere (not paused)
- Check funscript timestamps match video duration
- Verify device settings (amplitude, frequency)

## Future Enhancements

### SMB File Loading (Planned)
Currently, funscripts must be pasted as JSON. Future version will support:
- Browse SMB network shares
- Select .funscript files directly
- Auto-load matching funscripts based on video filename
- Funscript library management

### Multi-Axis Support (Planned)
- Support for additional funscript axes (roll, pitch, twist)
- Multi-channel haptic scripts
- Advanced pattern combinations

## Technical Details

### Files Modified/Created
- `src/types/heresphere.ts` - Type definitions and connection states
- `src/types/settings.ts` - MediaSync settings types
- `src/services/HereSphereService.ts` - TCP socket client
- `src/services/FunscriptService.ts` - Funscript parser
- `src/services/SettingsService.ts` - Storage integration
- `src/core/SyncedPlayback.ts` - Playback controller
- `src/store/deviceStore.ts` - State management
- `src/app/(tabs)/media.tsx` - UI implementation
- `src/app.json` - Network security configuration

### TCP Protocol Implementation

Based on `restim-desktop/net/media_source/heresphere.py`:

**Connection:**
- Uses `react-native-tcp-socket` library
- Connects to `{ip}:{port}` (default 23554)
- Maintains keep-alive with 1-second heartbeat
- Auto-reconnects on disconnection

**Message Format:**
- Incoming: 4-byte length header + JSON payload
- Outgoing: 4 null bytes for keep-alive
- Little-endian byte order for length

**States:**
- `NOT_CONNECTED`: No TCP connection
- `CONNECTED_BUT_NO_FILE`: Connected, no video loaded
- `CONNECTED_AND_PAUSED`: Video loaded but paused
- `CONNECTED_AND_PLAYING`: Actively playing

### Network Configuration

The app requires local network access which is configured in `app.json`:

**Android (`usesCleartextTraffic`):**
- Allows non-HTTPS (TCP) connections
- Required for local network communication

**iOS (`NSAppTransportSecurity`):**
- Allows arbitrary loads for local networking
- Required for TCP socket connections

## Safety Notes

- Synced playback uses device safety settings (amplitude, frequency limits)
- Automatic amplitude ramp-up (500ms) and ramp-down on stop
- Position updates throttled to prevent excessive device commands
- Device automatically stops if HereSphere connection lost
