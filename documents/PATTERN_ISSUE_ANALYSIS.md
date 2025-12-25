# Pattern Implementation Issue - Analysis & Fix

**Date**: 2025-12-25
**Issue**: Device doesn't respond to pattern commands despite successful connection

---

## 🔍 Root Cause Analysis

### Desktop App (Python) Architecture

**Pattern Output**: Returns **delta/incremental** values
```python
# circle.py - returns CHANGE in position
def update(self, dt: float):
    self.angle += dt * self.velocity
    x = np.cos(self.angle) * self.amplitude  # Returns position delta
    y = np.sin(self.angle) * self.amplitude
    return x, y
```

**Usage in Motion Generator**:
```python
# threephase_patterns.py:111-116
a, b = self.pattern.update(dt * self.velocity)  # Get delta
self.alpha.add(a)  # ADD to timeline (accumulates deltas → absolute positions)
self.beta.add(b)
a = self.alpha.interpolate(time.time() - self.latency)  # Get current absolute position
b = self.beta.interpolate(time.time() - self.latency)
self.position_updated.emit(a, b)  # Send absolute position to device
```

**Axis Timeline System**:
- `axis.add(value, interval)`: Adds target position to temporal timeline
- Timeline interpolates between positions over time
- Creates smooth movement with proper timing

---

### Our App (TypeScript) - INCORRECT Implementation

**Current Pattern**: Returns absolute positions (WRONG for this architecture)
```typescript
// patterns.ts - returns ABSOLUTE position
update(dt: number): PatternPosition {
    this.angle += dt * this.velocity;
    const x = Math.cos(this.angle) * this.amplitude;  // -0.5 to +0.5
    const y = Math.sin(this.angle) * this.amplitude;  // -0.5 to +0.5
    return { x, y };
}
```

**Current CommandLoop**: Sends absolute positions directly (WRONG)
```typescript
// CommandLoop.ts:41-46
const pos = this.pattern.update(dt);
// Sends values in range [-0.5, +0.5] every 16ms
this.sendUpdate(AxisType.AXIS_POSITION_ALPHA, pos.x, interval);
this.sendUpdate(AxisType.AXIS_POSITION_BETA, pos.y, interval);
```

---

## ❌ **Why This Fails**

1. **Pattern returns**: `x = 0.5, y = 0.0` (absolute cosine/sine)
2. **We send to device**: MoveTo(alpha=0.5, beta=0.0, interval=50ms)
3. **Device interprets**: Move to **absolute position** 0.5 on alpha axis
4. **Next tick (16ms later)**: x = 0.498, y = 0.062
5. **We send**: MoveTo(alpha=0.498, beta=0.062, interval=50ms)
6. **Result**: Tiny oscillation around same position, device appears "stuck"

The device is receiving **absolute target positions** that oscillate in a tiny range [-0.5, +0.5], not a circular motion pattern.

---

## ✅ **Solution Options**

### Option 1: Accumulate Positions (Match Desktop Pattern)

**Keep pattern as delta values**, add position tracking in CommandLoop:

```typescript
export class CommandLoop {
  private pattern = new CirclePattern(0.5, 2.0);
  private currentAlpha = 0.0;  // Track absolute position
  private currentBeta = 0.0;

  private tick = () => {
    const dt = (Date.now() - this.lastTimestamp) / 1000;
    this.lastTimestamp = Date.now();

    // Get DELTA from pattern
    const delta = this.pattern.update(dt);

    // ACCUMULATE to get absolute position
    this.currentAlpha += delta.x;
    this.currentBeta += delta.y;

    // Send absolute accumulated position
    this.sendUpdate(AxisType.AXIS_POSITION_ALPHA, this.currentAlpha, interval);
    this.sendUpdate(AxisType.AXIS_POSITION_BETA, this.currentBeta, interval);
  }
}
```

**Pros**: Matches desktop architecture exactly
**Cons**: Positions accumulate indefinitely (may exceed device range over time)

---

### Option 2: Make Pattern Return Absolute Positions

**Change pattern to return true absolute positions** in device's expected range:

```typescript
export class CirclePattern {
  private angle: number = 0;
  private amplitude: number;  // Should be in device's valid range (e.g., 0-1000)
  private velocity: number;
  private centerX: number;    // Center point for circular motion
  private centerY: number;

  constructor(
    amplitude: number = 500,   // Radius of circle
    velocity: number = 1.0,
    centerX: number = 500,     // Center of device range
    centerY: number = 500
  ) {
    this.amplitude = amplitude;
    this.velocity = velocity;
    this.centerX = centerX;
    this.centerY = centerY;
  }

  update(dt: number): PatternPosition {
    this.angle += dt * this.velocity;
    this.angle = this.angle % (2 * Math.PI);

    // Return ABSOLUTE position in device's coordinate space
    const x = this.centerX + Math.cos(this.angle) * this.amplitude;
    const y = this.centerY + Math.sin(this.angle) * this.amplitude;

    return { x, y };
  }
}
```

**Pros**: Simpler, no accumulation drift
**Cons**: Requires knowing device's coordinate range

---

### Option 3: Hybrid - Scale Pattern Output

**Keep current pattern**, scale output to device range:

```typescript
private tick = () => {
    const dt = (Date.now() - this.lastTimestamp) / 1000;
    this.lastTimestamp = Date.now();

    const pos = this.pattern.update(dt);  // Returns [-0.5, +0.5]

    // Scale to device range (assuming 0-1000)
    const DEVICE_MIN = 0;
    const DEVICE_MAX = 1000;
    const DEVICE_CENTER = 500;
    const RADIUS = 400;

    const alpha = DEVICE_CENTER + (pos.x * RADIUS);  // 500 + [-200, +200]
    const beta = DEVICE_CENTER + (pos.y * RADIUS);   // 500 + [-200, +200]

    this.sendUpdate(AxisType.AXIS_POSITION_ALPHA, alpha, interval);
    this.sendUpdate(AxisType.AXIS_POSITION_BETA, beta, interval);
}
```

**Pros**: Minimal code change, explicit scaling
**Cons**: Need to know device range

---

## 🎯 **Recommended Solution: Option 3 (Scaling)**

**Rationale**:
1. Simplest fix with minimal changes
2. Matches our current pattern architecture
3. Explicit about coordinate transformation
4. No accumulation drift issues
5. Works with protobuf `MoveTo` absolute positioning

**Next Step**: Determine correct device coordinate range from protobuf spec or testing

---

## 📊 **Device Coordinate Range - To Investigate**

Need to determine from protobuf/device spec:
- What is the valid range for `value` in `RequestAxisMoveTo`?
- Is it 0-1, 0-100, 0-1000, or something else?
- What does value=0 mean? What does value=max mean?

**Test**: Send fixed values to observe device response:
```typescript
// Test positions
sendUpdate(AXIS_POSITION_ALPHA, 0, 1000);     // Min position
sendUpdate(AXIS_POSITION_ALPHA, 500, 1000);   // Center
sendUpdate(AXIS_POSITION_ALPHA, 1000, 1000);  // Max position
```

---

## 🔬 **Comparison Table**

| Aspect | Desktop (Python) | Current App (TS) | Issue |
|--------|------------------|------------------|-------|
| **Pattern Output** | Delta values | Absolute cosine/sine | ❌ Range mismatch |
| **Range** | Arbitrary (scaled by amplitude) | [-amplitude, +amplitude] | ❌ Too small |
| **Accumulation** | Via axis.add() timeline | None | ❌ Missing |
| **Device Command** | Absolute position from timeline | Raw pattern output | ❌ Wrong scale |
| **Movement** | Smooth circular motion | Oscillation in tiny range | ❌ Appears stuck |

---

## 🛠️ **Action Items**

1. ✅ **Identify device coordinate range** (check protobuf spec or test)
2. ⏳ **Implement scaling** in CommandLoop.ts
3. ⏳ **Test with real device** to verify motion
4. ⏳ **Add configuration** for center point and radius
5. ⏳ **Document coordinate system** for future patterns
