# Task 01: Fix Firmware Version Reporting (BREAKING CHANGE)

## Priority
**HIGH** - Breaking change in FOC-Stim firmware API

## Background
The FOC-Stim firmware has changed how it reports firmware version information. This is a breaking change that prevents the mobile app from connecting to devices with newer firmware.

## Current State (Mobile App - OUTDATED)
The mobile app uses the old protobuf definition:
```typescript
// src/generated/protobuf/messages_pb.ts
ResponseFirmwareVersion = {
  board: BoardIdentifier;
  stm32FirmwareVersion: string;  // field 2, string type
}
```

## New State (Desktop App - REFERENCE)
The desktop app now uses:
```python
# device/focstim/proto_device.py
got_version = response.response_firmware_version.stm32_firmware_version_2

# New FirmwareVersion message structure:
message FirmwareVersion {
  uint32 major = 1;
  uint32 minor = 2;
  uint32 revision = 3;
  string branch = 4;
  string comment = 5;
}

message ResponseFirmwareVersion {
  BoardIdentifier board = 1;
  FirmwareVersion stm32_firmware_version_2 = 3;  // NEW: field 3, message type
}
```

## Version Requirements (from desktop)
```python
FOCSTIM_VERSION_MAJOR = 1
FOCSTIM_VERSION_MINIMUM_MINOR = 1
FOCSTIM_VERSION_BRANCH = "main"
```

## Tasks

### 1. Update Protobuf Definitions
- [ ] Get latest `.proto` files from FOC-Stim firmware repository (or desktop app)
- [ ] Regenerate TypeScript protobuf files using `generate_protos.bat`
- [ ] Verify `ResponseFirmwareVersion` now has `stm32_firmware_version_2` field
- [ ] Verify `FirmwareVersion` message type is generated

### 2. Update FocStimApiService
- [ ] Update firmware version parsing in `src/services/FocStimApiService.ts`
- [ ] Parse the new structured version object (major, minor, revision, branch)
- [ ] Implement version validation logic:
  ```typescript
  const VERSION_MAJOR = 1;
  const VERSION_MINIMUM_MINOR = 1;
  const VERSION_BRANCH = "main";

  // Check branch matches
  if (version.branch !== VERSION_BRANCH) {
    throw new Error(`Incompatible firmware branch: ${version.branch}`);
  }

  // Check version is >= minimum
  if (version.major !== VERSION_MAJOR || version.minor < VERSION_MINIMUM_MINOR) {
    throw new Error(`Incompatible firmware version: ${version.major}.${version.minor}.${version.revision}`);
  }
  ```

### 3. Update UI
- [ ] Display firmware version in device info (e.g., "v1.54.0 (main)")
- [ ] Show clear error message when version mismatch occurs
- [ ] Consider showing "Firmware Update Required" prompt

### 4. Testing
- [ ] Test with device running old firmware (should fail with clear message)
- [ ] Test with device running new firmware (should connect successfully)
- [ ] Verify version numbers display correctly in UI

## Reference Files
- Desktop implementation: `~/code/restim-desktop/device/focstim/proto_device.py` (lines 145-165)
- Desktop protobuf: `~/code/restim-desktop/device/focstim/messages_pb2.py`
- Mobile service: `~/code/restim-mobile/src/services/FocStimApiService.ts`
- Mobile protobuf: `~/code/restim-mobile/src/generated/protobuf/messages_pb.ts`

## Acceptance Criteria
- [ ] Mobile app connects to devices with new firmware
- [ ] Clear error message shown for incompatible firmware
- [ ] Firmware version displayed in UI
- [ ] No crashes on version parsing
