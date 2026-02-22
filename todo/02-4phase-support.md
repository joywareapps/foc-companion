# Task 02: 4-Phase Support Implementation

## Priority
**MEDIUM** - Feature enhancement

## Background
The FOC-Stim device supports two operating modes:
- **3-Phase**: Uses alpha/beta coordinates, 3 outputs (A, B, C)
- **4-Phase**: Uses individual electrode power control, 4 outputs (A, B, C, D)

The desktop app supports both modes. The mobile app currently only supports 3-phase mode. We need to add 4-phase support.

## Key Constraints
1. **Mode can only be changed when device is NOT playing**
2. **Available patterns depend on the mode** (3-phase patterns vs 4-phase patterns)
3. **Device must be re-initialized when switching modes**

## Technical Analysis Required

### 1. How 3-Phase Works (Current Implementation)
Study the existing mobile app implementation:
- Location: `src/services/CommandLoop.ts`, `src/services/FocStimApiService.ts`
- Uses `OutputMode.OUTPUT_THREEPHASE` when starting signal
- Uses `AXIS_POSITION_ALPHA` and `AXIS_POSITION_BETA` for position control
- Pattern: Circle pattern using alpha/beta coordinates

### 2. How 4-Phase Works (Desktop Reference)
Study the desktop implementation:
- Algorithm: `~/code/restim-desktop/device/focstim/fourphase_algorithm.py`
- Uses `OutputMode.OUTPUT_FOURPHASE_INDIVIDUAL_ELECTRODES` when starting signal
- Uses individual electrode power axes:
  - `AXIS_ELECTRODE_1_POWER`
  - `AXIS_ELECTRODE_2_POWER`
  - `AXIS_ELECTRODE_3_POWER`
  - `AXIS_ELECTRODE_4_POWER`
- Additional calibration axes:
  - `AXIS_CALIBRATION_4_CENTER`
  - `AXIS_CALIBRATION_4_A`, `_B`, `_C`, `_D`

### 3. Patterns Available for Each Mode
Research the desktop pattern implementations:
- 3-Phase patterns: `~/code/restim-desktop/qt_ui/patterns/threephase_patterns.py`
- 4-Phase patterns: `~/code/restim-desktop/qt_ui/patterns/fourphase_patterns.py`
- 4-Phase specific patterns: `~/code/restim-desktop/qt_ui/patterns/fourphase/`

### 4. Device Communication Differences
Compare how each mode initializes:
- Review `~/code/restim-desktop/device/focstim/proto_device.py` (start_signal_generation method)
- Check if any protobuf messages differ between modes
- Check constants: `~/code/restim-desktop/device/focstim/constants_pb2.py`

## Implementation Plan

### Phase 1: Core Infrastructure
- [ ] Add mode state to deviceStore (`deviceMode: '3phase' | '4phase' | 'disconnected'`)
- [ ] Create mode selection logic
- [ ] Update FocStimApiService to support both OutputMode values
- [ ] Create 4-phase algorithm class (similar to CommandLoop but for 4 electrodes)

### Phase 2: 4-Phase Command Loop
- [ ] Port `FourPhaseIntensity` class from desktop (`stim_math/audio_gen/various.py`)
- [ ] Implement 4-phase pattern(s) - at minimum, a simple test pattern
- [ ] Create `FourPhaseCommandLoop` class using electrode power axes

### Phase 3: UI Design (SEE UX OPTIONS BELOW)
- [ ] Design mode selection UI
- [ ] Update pattern selection based on current mode
- [ ] Handle mode switching (disconnect → select mode → reconnect flow)

## UX Options to Evaluate

### Option A: Two Connect Buttons (Initial Idea)
```
┌─────────────────────────────┐
│   [Connect 3-Phase]         │  ← Blue button
│   [Connect 4-Phase]         │  ← Blue button
└─────────────────────────────┘

When connected (e.g., 4-Phase):
┌─────────────────────────────┐
│   Connected: 4-Phase        │
│   [Disconnect]              │  ← Red button
└─────────────────────────────┘
```

**Pros:**
- Clear which mode you're connecting as
- Simple to implement
- No extra screens/toggles

**Cons:**
- Two buttons might look cluttered
- Less obvious that modes are mutually exclusive

### Option B: Mode Toggle + Single Connect
```
┌─────────────────────────────┐
│   Mode: [3-Phase] [4-Phase] │  ← Segmented control / toggle
│                             │
│   [Connect]                 │  ← Single button
└─────────────────────────────┘
```

**Pros:**
- Cleaner UI with single connect button
- Mode selection is explicit but not intrusive
- Familiar pattern (like settings toggles)

**Cons:**
- Requires extra tap to change mode
- Might not be obvious that mode affects patterns

### Option C: Mode Selection in Settings
```
Settings Screen:
┌─────────────────────────────┐
│   Device Mode:              │
│   ○ 3-Phase (default)       │
│   ○ 4-Phase                 │
│                             │
│   Note: Patterns available  │
│   depend on selected mode.  │
└─────────────────────────────┘

Main Screen:
┌─────────────────────────────┐
│   [Connect] / [Disconnect]  │
│                             │
│   Current Mode: 3-Phase     │
└─────────────────────────────┘
```

**Pros:**
- Main screen stays clean
- Can add helpful explanations in settings
- Good for a setting that doesn't change often

**Cons:**
- Mode is hidden away
- Requires navigation to change

### Option D: Mode-Aware Pattern Selection
```
Before Connect:
┌─────────────────────────────┐
│   [Select Mode & Connect ▼] │  ← Dropdown/split button
│   ─────────────────────     │
│   ├ Connect 3-Phase         │
│   └ Connect 4-Phase         │
└─────────────────────────────┘

Pattern Selection (after connect):
┌─────────────────────────────┐
│   Patterns (3-Phase):       │
│   ○ Circle                  │
│   ○ Figure Eight            │
│   ○ Custom                  │
└─────────────────────────────┘
```

**Pros:**
- Combines mode selection with connect action
- Pattern list automatically filters by mode
- Professional dropdown UI

**Cons:**
- Dropdown might be overkill for just 2 options
- More complex to implement

### UX Recommendation Task
Evaluate the above options considering:
1. **Frequency of mode switching** - How often will users need to switch?
2. **User mental model** - Do users understand 3-phase vs 4-phase?
3. **Mobile UI constraints** - Thumb-friendly, not too much on one screen
4. **Error prevention** - Make it hard to accidentally switch modes while playing

**Consider hybrid approach:** Option B for simplicity, but with a lock icon or warning when trying to change while connected.

## Reference Files to Study
- Desktop 4-phase algorithm: `~/code/restim-desktop/device/focstim/fourphase_algorithm.py`
- Desktop 3-phase algorithm: `~/code/restim-desktop/device/focstim/threephase_algorithm.py`
- Desktop mode handling: `~/code/restim-desktop/device/focstim/proto_device.py` (start_signal_generation)
- Desktop 4-phase patterns: `~/code/restim-desktop/qt_ui/patterns/fourphase_patterns.py`
- Desktop UI for mode: `~/code/restim-desktop/qt_ui/four_phase_settings_widget_ui.py`
- Mobile current implementation: `src/services/CommandLoop.ts`
- Mobile protobuf constants: `src/generated/protobuf/constants_pb.ts`

## Deliverables
1. Research summary document with findings
2. Recommended UX approach with rationale
3. Implementation plan with estimated effort
4. Wireframes/mockups if needed

## Acceptance Criteria
- [ ] Clear understanding of 3-phase vs 4-phase technical differences
- [ ] Documented list of patterns for each mode
- [ ] UX design decision made with rationale
- [ ] Implementation plan ready for execution
