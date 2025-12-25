# Migration Issues & Guideline Mismatches

## 1. Dependency & Version Mismatches
*   **React Native Version**: Guidelines specify **0.83** (Stable, Dec 2025). Current: `0.81.5`.
*   **React Version**: Guidelines specify **19.2.x**. Current: `19.1.0`.
*   **~~Missing Serial Support~~**: ✅ FIXED - Moved to TODO.md Phase 4 (lower priority). TCP is implemented, Serial/USB is planned but not started.
*   **Worklets Library**: Guidelines mention `react-native-worklets-core` (likely for Reanimated 4 integration). Current: `react-native-worklets`.

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
