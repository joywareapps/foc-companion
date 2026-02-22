# Migration Issues & Guideline Mismatches

## 1. Dependency & Version Mismatches (RESOLVED)
*   **~~React Native Version~~**: ✅ FIXED - Upgraded from `0.81.5` to **`0.83.1`** (compliant with guidelines).
*   **~~React Version~~**: ✅ FIXED - Upgraded from `19.1.0` to **`19.2.3`** (includes CVE-2025-55182 fix).
*   **~~@types/react~~**: ✅ FIXED - Upgraded to `19.2.7` for React 19.2.3 compatibility.
*   **~~Missing Serial Support~~**: ✅ FIXED - Moved to TODO.md Phase 4 (lower priority). TCP is implemented, Serial/USB is planned but not started.
*   **Worklets Library**: Guidelines mention `react-native-worklets-core` (likely for Reanimated 4 integration). Current: `react-native-worklets` (0.7.1).

## 2. Technical Implementation Issues
*   **Command Loop Performance**:
    *   The loop in `CommandLoop.ts` calls `runOnJS(this.tick)()` every 16ms, which negates the performance benefits of using a dedicated Worklet runtime by jumping back to the main JS thread for every update.
    *   `sendRequest` is awaited at 60Hz. Under high latency or slow network conditions, this will lead to a massive backlog of pending promises, potentially causing memory exhaustion and UI lag.
*   **Protocol Handling**:
    *   `FocStimApiService.ts` cleanup method clears `pendingRequests` but does not reject the promises. This causes all awaiting callers to hang until they hit a 5-second timeout, even if the connection is known to be closed.
*   **HDLC implementation**: Uses CommonJS `require` for `js-crc` in a TypeScript environment, which is inconsistent with the rest of the ES module-based codebase.

## 3. Discrepancies in Project Status
*   **~~Incomplete MVP~~**: ✅ FIXED - Documentation now accurate. TCP layer complete (untested), Serial/USB moved to Phase 4 as lower priority.
*   **Telemetry/Notifications**: `FocStimApiService` identifies notifications but `deviceStore.ts` does not yet subscribe to or utilize them for UI feedback (e.g., current/power metrics).
