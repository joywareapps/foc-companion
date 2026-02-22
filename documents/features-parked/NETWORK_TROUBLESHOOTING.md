# Network Troubleshooting Guide - HereSphere TCP Socket

## HereSphere Protocol

**Important:** HereSphere uses a **TCP socket connection**, NOT HTTP!

Based on the desktop implementation (restim-desktop), HereSphere uses:
- **Protocol**: TCP socket
- **Binary Format**: Length-prefixed JSON messages
- **Keep-alive**: 4 null bytes (`\0\0\0\0`) every 1 second
- **Default Port**: 23554

## Message Protocol

### Outgoing (Client → HereSphere):
- **Keep-alive**: 4 bytes `[0x00, 0x00, 0x00, 0x00]` sent every 1 second

### Incoming (HereSphere → Client):
- **4-byte header**: Message length (little-endian unsigned 32-bit integer)
- **JSON payload**: Status data

#### Message Types:

1. **Keep-alive** (length = 0):
   ```
   [0x00, 0x00, 0x00, 0x00]
   ```
   State: CONNECTED_BUT_NO_FILE_LOADED

2. **Status Update** (length > 0):
   ```
   [length_bytes(4)] + JSON_payload
   ```
   JSON format:
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
   - `playbackSpeed`: Speed multiplier
   - `path`: Current video file path

## Verification Steps

1. **Verify HereSphere is running**
   - Open HereSphere player
   - Check the TCP port (default: 23554)
   - Ensure it's listening for connections

2. **Test network connectivity**
   - Ensure phone and HereSphere device are on same WiFi network
   - Both devices should be able to ping each other
   - No firewall blocking port 23554

3. **Check the connection**
   - Go to Media Sync tab
   - Configure IP and port
   - Click "Test HereSphere Connection"
   - Watch console logs for detailed output

## Console Logs

Enable detailed logging by watching Flutter output:

```bash
cd restim-flutter
flutter run
```

Look for these log messages:

**Successful Connection:**
```
[HereSphere] Configured: 192.168.x.x:23554
[HereSphere] Connecting to 192.168.x.x:23554...
[HereSphere] Connected to TCP socket
[HereSphere] Sent keep-alive
[HereSphere] Received keep-alive
[HereSphere] Received status: {path: "...", currentTime: 123.45, ...}
```

**Failed Connection:**
```
[HereSphere] Configured: 192.168.x.x:23554
[HereSphere] Connecting to 192.168.x.x:23554...
[HereSphere] Socket error: [error details]
[HereSphere] Scheduling reconnect in 1 second...
```

## Testing the Connection

### Method 1: Using the App
1. Build and run the app
2. Go to Media Sync tab
3. Configure HereSphere IP and port (default: 23554)
4. Click "Test HereSphere Connection"
5. Check logs for detailed error messages

### Method 2: Using netcat (from computer)
```bash
# Test if HereSphere TCP server is running
nc -zv 192.168.x.x 23554

# Or connect and see raw protocol
nc 192.168.x.x 23554
# (You should receive binary data - keep-alive or status messages)
```

### Method 3: Using telnet
```bash
telnet 192.168.x.x 23554
# Connection successful means server is listening
```

## Common Issues

### 1. "Connection timeout"
- **Cause**: Cannot connect to HereSphere TCP server
- **Solutions**:
  - Verify HereSphere is running
  - Check IP address is correct
  - Ensure port 23554 is not blocked by firewall
  - Try from another device to verify server is accessible

### 2. "Socket error: Connection refused"
- **Cause**: No server listening on that port
- **Solutions**:
  - Verify HereSphere is running
  - Check HereSphere settings for correct port
  - Ensure no other app is using port 23554

### 3. Connection succeeds but no data received
- **Cause**: Protocol mismatch or HereSphere not sending data
- **Solutions**:
  - Load a video in HereSphere to trigger status messages
  - Check logs for "Received keep-alive" messages
  - Verify JSON parsing isn't failing

## Network Requirements

### Same Network
- Phone and HereSphere device must be on same WiFi network
- Some routers isolate 2.4GHz and 5GHz networks
- Guest networks may block device-to-device communication

### Firewall
- **Windows**: Allow HereSphere through Windows Firewall
- **Mac**: Check System Preferences → Security & Privacy → Firewall
- **Port**: Ensure TCP port 23554 is allowed

### IP Addressing
- Use static IP or DHCP reservation for HereSphere device
- IP addresses can change after router restart
- Check HereSphere settings or router DHCP table for current IP

## Support

If issues persist:
1. Verify HereSphere is using TCP protocol (not HTTP)
2. Check HereSphere documentation for protocol details
3. Test with desktop restim application first
4. Share logs for debugging
5. Use network tools (netcat, telnet) to verify server is accessible
