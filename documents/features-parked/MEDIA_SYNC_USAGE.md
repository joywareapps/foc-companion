# Media Sync Usage Guide - HereSphere Integration

## Overview

FOC Companion supports real-time media synchronization with the **HereSphere** video player (Android, Quest, and PC). This allows the application to automatically synchronize device patterns with the video playback position.

## Features
- Automatic funscript loading from WebDAV network shares or local storage
- Multi-channel support (alpha, beta, volume)
- Real-time video position tracking
- Playback status synchronization

## Setup Guide

### 1. Configure HereSphere
Ensure HereSphere is running and has the **TCP server** enabled.
- **Protocol**: TCP
- **Port**: 23554 (default)

### 2. Configure FOC Companion
1. Open the app and go to the **Media Sync** tab.
2. Enter the **IP Address** of your HereSphere device.
3. Verify the **Port** is set to `23554`.
4. Click **Connect** (or it may connect automatically).

### 3. Add Funscript Locations
You can add multiple locations where the app will search for funscripts:
1. Go to **Media Sync Settings**.
2. Click **Add Location**.
3. Choose **Local** (for files on your phone) or **WebDAV** (for network shares).
4. For WebDAV, enter the URL, username, and password.
5. Save the location.

### 4. Automatic Loading
When a video starts playing in HereSphere:
1. The app receives the video filename/path.
2. It searches all enabled locations for a matching `.funscript` file.
3. If found, it loads and starts synchronizing with playback.

## Troubleshooting

- **Connection Error**: Ensure both devices are on the same WiFi network and no firewall is blocking port `23554`.
- **Funscript Not Loading**: Verify the funscript filename matches the video filename (e.g., `video1.mp4` and `video1.funscript`).
- **Sync Issues**: Check for high network latency or jitter. Use a stable 5GHz WiFi connection for best results.

For more details on network issues, see [NETWORK_TROUBLESHOOTING.md](./NETWORK_TROUBLESHOOTING.md).
