# Centralized Playback State Management

## Overview

Implemented centralized playback state management to ensure mutual exclusion between pattern playback and media sync playback. Only one playback source can be active at a time, preventing conflicting device commands and ensuring proper state tracking.

## Implementation Date

2026-01-01

## Problem

Previously, pattern playback and media sync playback had independent state management:
- **Pattern playback**: Used `loopRunning` in deviceStore
- **Media sync playback**: Used local `isPlaying` state in media.tsx

This caused several issues:
1. Both could start simultaneously, causing conflicting device commands
2. When device stopped (error/timeout/disconnect), local state wasn't updated
3. No way to prevent one from starting while the other was active
4. State inconsistencies when errors occurred

## Solution

Created centralized playback state in deviceStore that tracks:
- **isPlaybackActive**: Boolean indicating if any playback is active
- **playbackSource**: Which source is playing ('pattern' | 'mediaSync' | null)

All playback operations now check and update this centralized state, ensuring mutual exclusion and consistent state management.

## Files Modified

### src/store/deviceStore.ts

**New State:**
```typescript
export type PlaybackSource = 'pattern' | 'mediaSync' | null;

interface DeviceState {
  // Centralized playback state
  isPlaybackActive: boolean;
  playbackSource: PlaybackSource;

  // ... existing state
}
```

**New Actions:**
```typescript
// Set playback active for a specific source
setPlaybackActive: (source: PlaybackSource) => void;

// Clear playback active state
clearPlaybackActive: () => void;

// Check if playback can start for requested source
canStartPlayback: (requestedSource: PlaybackSource) => boolean;
```

**Updated Behaviors:**
- `toggleLoop()`: Checks if media sync is playing before starting pattern
- `connect/disconnect/error handlers`: Clear playback state on disconnect or error
- Pattern start: Sets playbackSource to 'pattern'
- Pattern stop: Clears playback state

### src/core/SyncedPlayback.ts

**Start Method:**
- Checks `canStartPlayback('mediaSync')` before starting
- Calls `setPlaybackActive('mediaSync')` on successful start
- Calls `clearPlaybackActive()` on error

**Stop Method:**
- Always calls `clearPlaybackActive()` when stopping (success or error)

### src/app/(tabs)/media.tsx

**Removed:**
- Local `isPlaying` state (useState)
- All `setIsPlaying()` calls

**Changed:**
- Now derives `isPlaying` from deviceStore: `isPlaybackActive && playbackSource === 'mediaSync'`
- Playback state automatically updated when SyncedPlayback starts/stops

## Behavior

### Starting Pattern Playback

1. User clicks "Start Circle Pattern"
2. `toggleLoop()` checks `canStartPlayback('pattern')`
3. If media sync is playing, shows error: "Cannot start pattern: mediaSync is currently playing"
4. If allowed, sets `playbackSource = 'pattern'` and starts pattern
5. On error, clears playback state

### Starting Media Sync

1. User clicks "Start Synced Playback"
2. `syncedPlayback.start()` checks `canStartPlayback('mediaSync')`
3. If pattern is playing, throws error: "Cannot start media sync: pattern is currently playing"
4. If allowed, sets `playbackSource = 'mediaSync'` and starts sync
5. On error, clears playback state

### Device Errors/Disconnect

When device errors or disconnects:
1. Error handlers call `clearPlaybackActive()`
2. Both pattern and media sync states are reset
3. UI reflects stopped state
4. User can retry after reconnecting

### State Synchronization

The centralized state ensures:
- **Pattern UI** (`loopRunning`) reflects actual device state
- **Media sync UI** (`isPlaying`) reflects actual device state
- Both UIs stay in sync via deviceStore
- No race conditions or state conflicts

## Benefits

1. **Mutual Exclusion**: Only one playback source can be active at a time
2. **Consistent State**: Device errors update both pattern and media sync states
3. **Clear Errors**: User sees clear message if trying to start while other is playing
4. **Automatic Cleanup**: State always cleared on stop/error/disconnect
5. **Simpler Code**: Removed duplicate state management from media.tsx

## Testing

To test mutual exclusion:

**Test 1: Pattern → Media Sync**
1. Start pattern playback (should work)
2. Try to start media sync (should fail with error message)
3. Stop pattern
4. Start media sync (should work now)

**Test 2: Media Sync → Pattern**
1. Start media sync (should work)
2. Try to start pattern (should fail with error message)
3. Stop media sync
4. Start pattern (should work now)

**Test 3: Error Recovery**
1. Start pattern playback
2. Disconnect device or cause timeout
3. Verify both pattern UI and media sync UI show stopped state
4. Reconnect and verify can start either playback

**Test 4: Boot Notification**
1. Start playback (pattern or media sync)
2. If device sends boot notification (reset), verify:
   - Playback state cleared
   - Error shown to user
   - UI reflects stopped state

## State Flow Diagrams

### Pattern Playback Flow
```
[IDLE] --toggleLoop()--> canStartPlayback('pattern')?
  ├─ Yes --> setPlaybackActive('pattern') --> [PATTERN_PLAYING]
  └─ No --> Show error "mediaSync is playing"

[PATTERN_PLAYING] --toggleLoop()--> clearPlaybackActive() --> [IDLE]
[PATTERN_PLAYING] --error/disconnect--> clearPlaybackActive() --> [IDLE]
```

### Media Sync Playback Flow
```
[IDLE] --start()--> canStartPlayback('mediaSync')?
  ├─ Yes --> setPlaybackActive('mediaSync') --> [MEDIASYNC_PLAYING]
  └─ No --> Throw error "pattern is playing"

[MEDIASYNC_PLAYING] --stop()--> clearPlaybackActive() --> [IDLE]
[MEDIASYNC_PLAYING] --error/disconnect--> clearPlaybackActive() --> [IDLE]
```

## Implementation Details

### canStartPlayback() Logic

```typescript
canStartPlayback(requestedSource) {
  // If nothing is playing, allow
  if (!isPlaybackActive) return true;

  // If same source, allow (restart)
  if (playbackSource === requestedSource) return true;

  // Different source is playing, deny
  return false;
}
```

### Error Handling

All error paths clear playback state:
- Connection errors
- Request timeouts
- Boot notifications (device reset)
- Disconnect events
- Start/stop failures

This ensures state never gets stuck even if errors occur.

## Future Enhancements

Potential improvements:
1. **Queue System**: Allow queuing one playback while other is active
2. **Transition Support**: Automatic fade between pattern and media sync
3. **State History**: Track playback history for debugging
4. **Auto-Resume**: Remember what was playing and auto-resume on reconnect
5. **Playback Priorities**: Allow certain sources to override others

## Related Documentation

- [Device Notification Logging](./device-notification-logging.md) - Helps debug state issues
- [Media Sync Usage](../MEDIA_SYNC_USAGE.md) - User guide for media sync
- [Quick Start](../QUICK_START.md) - Basic usage guide
