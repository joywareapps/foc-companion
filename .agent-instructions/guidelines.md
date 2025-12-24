This document is designed to be provided to an AI coding agent (e.g., Cursor, Windsurf, or Gemini) to provide high-context instructions for building a modern, high-performance Android application in late 2025.

# 2025 AI-Native Android Development Guidelines: React Native & Expo

## 1. Core Tech Stack & Versioning

To ensure stability and performance, the agent must adhere to the following version targets:

* **Framework:** React Native 0.83 (Stable, released Dec 10, 2025) .
* **Core UI Library:** React 19.2.x (with support for `<Activity>` and `useEffectEvent`) .
* **Infrastructure:** Expo SDK 53/54 (Managed Workflow recommended for AI-driven projects).
* **Navigation:** Expo Router (File-based navigation).


* **JavaScript Engine:** Hermes V1 (Experimental opt-in for maximum performance) .

## 2. Architectural Standards

### New Architecture (Mandatory)

React Native 0.83 operates exclusively on the **New Architecture**. The agent must not generate code that relies on the legacy asynchronous bridge .

* **JSI (JavaScript Interface):** Use for high-performance, synchronous communication between JS and Native C++ .
* **TurboModules:** All native modules must follow the TurboModule specification for lazy loading and type safety .
* **Fabric Renderer:** Use for optimized, concurrent UI rendering .
* **Bridgeless Mode:** Ensure `bridgelessEnabled=true` is set in the native entry point; avoid all legacy bridge APIs .

### Modern Rendering Primitives

* **`<Activity>` Component:** Use for screen lifecycle management. Utilize `mode="hidden"` to preserve component state while backgrounded without consuming rendering resources .
* **`useEffectEvent`:** Use to extract non-reactive logic from effects, preventing unnecessary re-executions when props or state change .

## 3. Build Pipeline & Ecosystem Management

### Solving "Gradle Fragility"

Gradle remains the engine for Android, but direct manual edits should be minimized to avoid environment desynchronization.

* **Expo Prebuild:** Use `npx expo prebuild` to treat the `/android` directory as a build artifact rather than source code. This allows the agent to regenerate clean native files whenever configuration changes.


* **EAS (Expo Application Services):** Offload all binary compilation to EAS Build. This ensures a consistent cloud environment and bypasses local Android Studio/Gradle versioning conflicts.


* **RNGP (React Native Gradle Plugin):** Ensure the project uses the RNGP to automatically align versions of `react-android` and `hermes-android`.



### Security Compliance

* **React 19.2.1+:** If the project is part of a monorepo, strictly use React 19.2.1 to mitigate CVE-2025-55182 (React Server Components vulnerability) .

## 4. Hardware Integration: USB-C & Serial

If connecting to external devices via USB-C (Serial COM):

* **Native Module:** Use `react-native-serial-transport` (recommended for Expo) or `@fugood/react-native-usb-serialport` for high-performance JSI-based gateway passthrough .
* **Zero-Copy Transfers:** Leverage JSI to move in-memory buffers directly between native hardware drivers and JS without serialization .
* **Permissions:** Ensure `android.permission.USB_PERMISSION` and `android.hardware.usb.host` are declared via Expo Config Plugins .

## 5. Coding Style & AI Interaction

### Coding Standards

* **Strict TypeScript:** Enable `strict: true` in `tsconfig.json`. Avoid `any` to provide the LLM with clear type-inference boundaries.
* **Functional Patterns:** Exclusively use functional components and hooks. Avoid Class components.
* **Feature-Based Folder Structure:** Organize by feature (e.g., `src/features/auth/...`) rather than by technical type (e.g., `src/components/...`).



### AI Agent Rules (`.cursorrules` / `AGENTS.md`)

To improve agent precision, include these constraints:

* **Context Management:** Use the **Model Context Protocol (MCP)** to fetch relevant documentation dynamically rather than dumping full PDFs into the chat.
* **"Vibe Coding" Workflow:** For rapid prototyping, use **Bolt.new** for UI logic and sync to **GitHub**, then use **Natively** or **Cursor** to wrap and build the final native binaries .
* **Validation:** Use `npx expo-doctor` and `npx expo install --fix` to resolve dependency peer conflicts automatically.

## 6. Performance Benchmarks

* **Cold Startup Target:** .


* **Frame Stability:** 60/120 FPS via Fabric and Reanimated 4.
* **Memory Usage:**  on low-end devices.



---

**Instruction to Agent:** "Please build the requested feature following these 2025 standards. Prioritize Expo SDK 53+ managed workflows and avoid legacy bridge patterns. Use TypeScript for all generated code."
