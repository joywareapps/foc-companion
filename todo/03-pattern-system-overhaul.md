# Task 03: Pattern System Overhaul

## Priority
**MEDIUM** - Feature enhancement

## Overview
Refactor the pattern system to:
1. Hide media sync tabs (focus on patterns first)
2. Port patterns from restim-desktop
3. Create a "Driver Cockpit" UI for real-time pattern customization
4. Add parameter modulation system

## Background
The mobile app currently has a single hardcoded Circle pattern. The desktop app has 17+ patterns with a flexible system. We need to:
- Port the most useful patterns
- Allow users to customize patterns in real-time
- Add modulation for pulse parameters (frequency, width)

---

## Part 1: Hide Media Sync Tabs

### Current State
- `media.tsx` tab contains HereSphere integration, WebDAV, funscript sync
- This is advanced functionality that distracts from core pattern usage

### Task
- [ ] Hide the "Media" tab from navigation
- [ ] Keep the code but don't show in UI
- [ ] Document how to re-enable later

### Files to Modify
- `src/app/(tabs)/_layout.tsx` - Remove media tab from navigation

---

## Part 2: Analyze Desktop Patterns

### Available 3-Phase Patterns (from `restim-desktop/qt_ui/patterns/threephase/`)

| Pattern | Category | Description | Complexity |
|---------|----------|-------------|------------|
| Circle | mathematical | Simple circle motion | Simple |
| Figure Eight | mathematical | Figure-8 shape | Simple |
| Rose Curve | mathematical | Mathematical rose curve | Medium |
| Spirograph | mathematical | Spirograph-like patterns | Medium |
| Butterfly | mathematical | Butterfly curve | Medium |
| W Shape | mathematical | W-shaped motion | Simple |
| Vertical Oscillation | basic | Up-down motion | Simple |
| Panning1 | basic | Horizontal pan | Simple |
| Panning2 | basic | Diagonal pan | Simple |
| Tremor Circle | experimental | Circle with tremor | Medium |
| Micro Circles | experimental | Small rapid circles | Medium |
| Orbiting Circles | experimental | Nested circles | Medium |
| Jerky Stroke | experimental | Irregular stroke | Medium |
| Random Walk | experimental | Random movement | Medium |
| Lightning Strike | experimental | Fast random strikes | Medium |
| Deep Throb | experimental | Slow throbbing | Medium |
| Mouse | interactive | Follows mouse cursor | Interactive |

### Pattern Base Class (Desktop)
```python
class ThreephasePattern(ABC):
    display_name = "Abstract Pattern"
    description = "Base pattern class"
    category = "base"
    
    def __init__(self, amplitude: float = 1.0, velocity: float = 1.0):
        self.amplitude = amplitude
        self.velocity = velocity
    
    @abstractmethod
    def update(self, dt: float) -> tuple[float, float]:
        pass
```

### Tasks - Pattern Analysis
- [ ] Read all 17 pattern implementations from `restim-desktop`
- [ ] Categorize by: Simple (port first), Medium, Complex (skip for now)
- [ ] Document which patterns are most useful for typical users
- [ ] Identify patterns with configurable parameters beyond amplitude/velocity

---

## Part 3: Pattern Implementation

### Current Mobile Pattern System
Location: `src/core/patterns.ts`
```typescript
export interface ThreephasePattern {
  name(): string;
  update(dt: number): PatternPosition;
}

export class CirclePattern implements ThreephasePattern {
  private angle: number = 0;
  private amplitude: number;
  private velocity: number;
  // ... simple circle implementation
}
```

### Tasks - Core Pattern System
- [ ] Create pattern registry system (like desktop's decorator registration)
- [ ] Create base `ThreephasePattern` class with:
  - `name()` - Display name
  - `description()` - Short description
  - `category` - For grouping
  - `update(dt)` - Returns alpha, beta position
  - `reset()` - Reset internal state
  - `setAmplitude(value)` - Dynamic amplitude
  - `setVelocity(value)` - Dynamic speed
- [ ] Create pattern factory/manager

### Priority Patterns to Port (Start Simple)
1. **Circle** - Already done ✅
2. **Figure Eight** - Simple, very useful
3. **Vertical Oscillation** - Simple, good for beginners
4. **Panning1/Panning2** - Simple motion
5. **Rose Curve** - Medium, very customizable
6. **Tremor Circle** - Medium, introduces modulation concept

### Pattern Files to Create
```
src/core/patterns/
├── base.ts           # Base class + registry
├── circle.ts         # Circle pattern
├── figureEight.ts    # Figure 8 pattern
├── verticalOscillation.ts
├── panning.ts
├── roseCurve.ts
├── tremorCircle.ts
└── index.ts          # Exports all patterns
```

---

## Part 4: Driver Cockpit UI

### Concept
When user selects a pattern, they enter a "cockpit" with real-time controls:
- Pattern speed
- Parameter modulation
- Visual feedback

### UI Wireframe

```
┌─────────────────────────────────────────────────┐
│  ← Back        Pattern: Circle                  │
├─────────────────────────────────────────────────┤
│                                                 │
│         [Visual: Pattern Preview SVG]           │
│                                                 │
├─────────────────────────────────────────────────┤
│  PATTERN SPEED                                  │
│  ├───────────────●──────────────────┤ 1.0x      │
│  [0.25] [0.5] [1.0] [2.0] [3.0] [4.0]          │
│                                                 │
├─────────────────────────────────────────────────┤
│  MODULATION                                     │
│  ┌─────────────────────────────────────────┐   │
│  │ [✓] Pulse Frequency Modulation          │   │
│  │     Function: [Sin ▼]                    │   │
│  │     Speed:   ├────●────────────────┤ 1x  │   │
│  │     Depth:   ├───────●─────────────┤ 50% │   │
│  │     Range:   20Hz - 200Hz              │   │
│  └─────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────┐   │
│  │ [ ] Pulse Width Modulation              │   │
│  │     (inverse of frequency)               │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│    [▶ START]              [■ STOP]             │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Speed Multiplier Buttons
Quick-access buttons for common speed multipliers:
- **1/4** (0.25x) - Very slow
- **1/3** (0.33x)
- **1/2** (0.5x) - Half speed
- **2/3** (0.67x)
- **3/4** (0.75x)
- **1** (1.0x) - Normal (default)
- **2** (2.0x) - Double
- **3** (3.0x)
- **4** (4.0x) - Very fast

### Modulation Functions

| Function | Description | Parameters |
|----------|-------------|------------|
| **Sine** | Smooth sine wave | - |
| **Triangle** | Linear up/down | - |
| **Saw** | Rising sawtooth | Center position (0-100%) |
| **Square** | On/off | Duty cycle (10-90%) |

### Modulation Speed
Linked to pattern speed with multiplier options:
- **Locked to pattern** (default) - Same speed as pattern
- **1/4, 1/3, 1/2, 2/3, 3/4** - Slower than pattern
- **1** - Same speed
- **4/3, 3/2, 2, 3, 4** - Faster than pattern

### Tasks - Driver Cockpit
- [ ] Create new screen: `src/app/pattern-cockpit.tsx`
- [ ] Implement pattern preview visualization (SVG/Canvas)
- [ ] Implement speed control with slider + preset buttons
- [ ] Implement modulation toggle cards
- [ ] Implement function selector (sin/triangle/saw/square)
- [ ] Implement modulation speed with pattern sync
- [ ] Implement depth/range controls

---

## Part 5: Modulation System

### Architecture

```typescript
// src/core/modulation/Modulator.ts

type ModulationFunction = 'sine' | 'triangle' | 'saw' | 'square';

interface ModulationConfig {
  enabled: boolean;
  function: ModulationFunction;
  speedMultiplier: number;  // Relative to pattern speed
  depth: number;            // 0.0 to 1.0
  center?: number;          // For saw (0-1)
  dutyCycle?: number;       // For square (0.1-0.9)
}

class Modulator {
  private config: ModulationConfig;
  private time: number = 0;
  
  update(dt: number, patternSpeed: number): number {
    if (!this.config.enabled) return 0;
    
    const modSpeed = patternSpeed * this.config.speedMultiplier;
    this.time += dt * modSpeed;
    
    const phase = this.time % (2 * Math.PI);
    let value = this.calculateFunction(phase);
    
    return value * this.config.depth;
  }
  
  private calculateFunction(phase: number): number {
    switch (this.config.function) {
      case 'sine':
        return Math.sin(phase);
      case 'triangle':
        return 2 * Math.abs(phase / Math.PI - 1) - 1;
      case 'saw':
        const center = this.config.center || 0.5;
        // Variable center sawtooth
        if (phase < center * 2 * Math.PI) {
          return phase / (center * Math.PI) - 1;
        } else {
          return 1 - (phase - center * 2 * Math.PI) / ((1 - center) * Math.PI);
        }
      case 'square':
        const duty = this.config.dutyCycle || 0.5;
        return phase < duty * 2 * Math.PI ? 1 : -1;
    }
  }
}
```

### Modulation Targets

1. **Pulse Frequency**
   - Base value from settings (e.g., 50Hz)
   - Modulation offset (e.g., ±30Hz)
   - Range: min-max from device settings

2. **Pulse Width (Inverse)**
   - When frequency increases, width decreases
   - Maintains consistent energy delivery
   - Optional: link to frequency modulation

3. **Carrier Frequency** (Future)
   - More advanced
   - Requires careful safety limits

### Tasks - Modulation System
- [ ] Create `Modulator` class with function implementations
- [ ] Create `ModulationManager` to handle multiple modulation targets
- [ ] Integrate with `CommandLoop` to apply modulation values
- [ ] Add modulation state to `deviceStore`
- [ ] Ensure modulation respects device safety limits

---

## Part 6: CommandLoop Integration

### Current CommandLoop
Location: `src/core/CommandLoop.ts`

### Modifications Needed
- [ ] Accept pattern as parameter (not hardcoded CirclePattern)
- [ ] Integrate modulation system
- [ ] Apply modulation to pulse parameters each tick
- [ ] Support dynamic speed changes

### Updated tick() Logic
```typescript
private tick = () => {
  const dt = (now - this.lastTimestamp) / 1000;
  
  // 1. Update pattern position
  const pos = this.pattern.update(dt);
  
  // 2. Calculate modulation values
  const pulseFreqMod = this.pulseFreqModulator.update(dt, this.patternSpeed);
  const pulseWidthMod = this.pulseWidthModulator.update(dt, this.patternSpeed);
  
  // 3. Apply to base values with safety limits
  const basePulseFreq = this.settings.pulseFrequency;
  const modulatedPulseFreq = Math.max(
    this.limits.minPulseFreq,
    Math.min(this.limits.maxPulseFreq, basePulseFreq + pulseFreqMod)
  );
  
  // 4. Send updates to device
  this.sendUpdate(AxisType.AXIS_POSITION_ALPHA, pos.x, interval);
  this.sendUpdate(AxisType.AXIS_POSITION_BETA, pos.y, interval);
  this.sendUpdate(AxisType.AXIS_PULSE_FREQUENCY_HZ, modulatedPulseFreq, interval);
  // ... etc
}
```

---

## Reference Files

### Desktop (to study)
- Patterns: `~/code/restim-desktop/qt_ui/patterns/threephase/*.py`
- Base class: `~/code/restim-desktop/qt_ui/patterns/threephase/base.py`
- Modulation: `~/code/restim-desktop/stim_math/amplitude_modulation.py`
- Algorithm: `~/code/restim-desktop/device/focstim/threephase_algorithm.py`

### Mobile (to modify)
- Patterns: `src/core/patterns.ts` → `src/core/patterns/`
- CommandLoop: `src/core/CommandLoop.ts`
- Tab layout: `src/app/(tabs)/_layout.tsx`
- Store: `src/store/deviceStore.ts`

---

## Deliverables

1. **Pattern Analysis Document**
   - List of all patterns with complexity ratings
   - Priority order for implementation
   - Recommended default patterns

2. **Driver Cockpit Wireframes**
   - Finalized UI design
   - User flow diagram

3. **Implementation Plan**
   - Phased approach
   - Effort estimates
   - Dependencies

---

## Acceptance Criteria

- [ ] Media sync tab hidden
- [ ] At least 5 patterns ported and working
- [ ] Driver Cockpit UI functional
- [ ] Speed control working with presets
- [ ] At least pulse frequency modulation working
- [ ] All 4 modulation functions implemented
- [ ] Safety limits respected
- [ ] Smooth transitions when changing parameters
