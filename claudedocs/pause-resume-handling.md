# Pause/Resume Handling for Media Sync

## Overview

Implemented intelligent pause/resume handling for HereSphere media sync playback. When video is paused, amplitude ramps down to 0 while position tracking continues. When resumed, amplitude smoothly ramps back up.

## Implementation Date

2026-01-01

## Problem

Previously, when HereSphere video was paused:
- Position commands stopped being sent (state check prevented it)
- Device would remain at whatever amplitude/position it was at when paused
- No smooth transition when pausing or resuming
- Resuming would instantly jump to full amplitude

## Solution

### Pause Behavior (Playing → Paused)

1. **Detect Pause**: Monitor HereSphere state for CONNECTED_AND_PAUSED
2. **Ramp Down**: Amplitude smoothly ramps to 0 over 500ms
3. **Continue Position**: Position commands continue being sent (with 0 amplitude)
4. **State Tracking**: isPaused flag tracks pause state

**Why continue position commands?**
- Keeps device in sync with video position
- Position immediately accurate when resumed
- Prevents position jumps on resume

### Resume Behavior (Paused → Playing)

1. **Detect Resume**: Monitor state transition from PAUSED to PLAYING
2. **Start Ramp Timer**: Record resume start time
3. **Gradual Ramp Up**: Amplitude increases from 0 to target over 2 seconds
4. **Clear Timer**: Once ramp complete, clear resume timer

**Ramp Duration:** 2000ms (2 seconds) - similar to startup ramp

## Implementation Details

### State Variables

```typescript
private isPaused = false;                           // Current pause state
private resumeStartTime: number = 0;                // When resume started
private readonly RESUME_RAMP_DURATION_MS = 2000;    // Resume ramp duration
```

### Pause Transition Detection

```typescript
// Detect pause/resume transitions
const wasPaused = this.isPaused;
this.isPaused = (state === ConnectionState.CONNECTED_AND_PAUSED);

// Handle pause transition (playing → paused)
if (!wasPaused && this.isPaused) {
  console.log('[SyncedPlayback] Video paused - ramping amplitude down');
  await this.handlePause();
}

// Handle resume transition (paused → playing)
if (wasPaused && !this.isPaused && state === ConnectionState.CONNECTED_AND_PLAYING) {
  console.log('[SyncedPlayback] Video resumed - ramping amplitude up');
  this.resumeStartTime = Date.now();
}
```

### Amplitude Calculation

```typescript
const targetAmplitude = deviceSettings.waveformAmplitude;
let currentAmplitude = targetAmplitude;

if (this.isPaused) {
  // While paused, amplitude is 0
  currentAmplitude = 0;
} else if (isPlaying && this.resumeStartTime > 0) {
  // Resume ramp (0 to target over RESUME_RAMP_DURATION_MS)
  const elapsedMs = Date.now() - this.resumeStartTime;
  const rampProgress = Math.min(elapsedMs / this.RESUME_RAMP_DURATION_MS, 1.0);
  currentAmplitude = targetAmplitude * rampProgress;

  // Clear resume start time once ramp is complete
  if (rampProgress >= 1.0) {
    this.resumeStartTime = 0;
  }
}
```

### Pause Handler

```typescript
private async handlePause() {
  try {
    // Ramp amplitude down to 0 over 500ms
    await focStimApi.sendRequest({
      case: 'requestAxisMoveTo',
      value: {
        axis: AxisType.AXIS_WAVEFORM_AMPLITUDE_AMPS,
        value: 0,
        interval: 500
      } as any
    });
  } catch (error) {
    console.error('[SyncedPlayback] Failed to ramp down amplitude on pause:', error);
  }
}
```

## User Experience

### Pausing Video

1. User pauses video in HereSphere
2. Stimulation smoothly fades out over 0.5 seconds
3. Position tracking continues (invisible to user)
4. Device ready for instant resume

### Resuming Video

1. User resumes video in HereSphere
2. Stimulation smoothly ramps up over 2 seconds
3. Position matches video exactly (no jump)
4. Normal playback continues

### Benefits

- **Smooth Transitions**: No sudden starts/stops
- **Comfort**: User can pause safely without jarring sensation
- **Accuracy**: Position stays synced even while paused
- **Responsiveness**: Resume is immediate and smooth

## Technical Details

### HereSphere States

```typescript
export enum HereSphereConnectionState {
  NOT_CONNECTED = 0,
  CONNECTED_BUT_NO_FILE = 1,
  CONNECTED_AND_PAUSED = 2,      // Video loaded but paused
  CONNECTED_AND_PLAYING = 3,     // Video playing
}
```

### Command Updates While Paused

Even while paused, we send:
- **Position commands**: Keep device position in sync with video
- **Amplitude commands**: Set to 0, but still sent for state consistency

We continue sending commands at ~60Hz (16ms intervals) to maintain smooth tracking.

### State Cleanup

Pause state is reset when:
- Playback is stopped completely (`stop()` method)
- Error occurs during playback
- New video is loaded

```typescript
this.isPaused = false;
this.resumeStartTime = 0;
```

## Testing

### Test 1: Pause During Playback
1. Start media sync with HereSphere
2. Play a video with funscript
3. Pause video
4. **Expected**: Amplitude smoothly fades to 0 over 0.5s
5. **Expected**: Position commands continue

### Test 2: Resume After Pause
1. With video paused (from Test 1)
2. Resume video
3. **Expected**: Amplitude smoothly ramps up over 2s
4. **Expected**: Position immediately matches video
5. **Expected**: No position jump

### Test 3: Multiple Pause/Resume Cycles
1. Start playback
2. Pause → Resume → Pause → Resume
3. **Expected**: Each transition smooth
4. **Expected**: No state corruption

### Test 4: Pause Near Video End
1. Play video near end
2. Pause
3. Resume and let video end
4. **Expected**: Smooth pause/resume
5. **Expected**: Clean stop when video ends

### Test 5: Seek While Paused
1. Pause video
2. Seek to different position
3. Resume
4. **Expected**: Position tracks seek
5. **Expected**: Smooth resume ramp

## Performance Considerations

### Command Rate
- Position commands: ~60Hz (16ms interval)
- Amplitude commands: ~60Hz (16ms interval)
- No performance impact from pause/resume logic

### Memory
- Minimal state: 2 variables (isPaused, resumeStartTime)
- No additional buffers or queues

### CPU
- Simple arithmetic for ramp calculation
- Negligible CPU overhead

## Future Enhancements

Potential improvements:
1. **Configurable Ramp Duration**: Let user adjust ramp up/down speed
2. **Pause Hold Pattern**: Optional subtle pattern while paused
3. **Smart Resume**: Different ramp based on pause duration
4. **Pause Notification**: Visual indicator when paused
5. **Resume Preview**: Brief vibration before full ramp

## Related Files

- `src/core/SyncedPlayback.ts` - Main implementation
- `src/types/heresphere.ts` - HereSphere state definitions
- `src/services/HereSphereService.ts` - Connection handling

## Related Documentation

- [Media Sync Usage](../MEDIA_SYNC_USAGE.md) - User guide
- [Centralized Playback State](./centralized-playback-state.md) - Playback state management
- [Device Notification Logging](./device-notification-logging.md) - Debugging tool
