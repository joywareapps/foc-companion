// HereSphere API type definitions
// Based on HereSphere TCP socket protocol (restim-desktop implementation)

/**
 * HereSphere player status response (from JSON over TCP socket)
 */
export interface HereSphereStatus {
  identifier: string;      // Video filename (e.g., "video.mp4")
  path: string;            // Current video file path
  currentTime: number;     // Current playback position in seconds
  playbackSpeed: number;   // Playback speed multiplier
  playerState: number;     // 0 = playing, other = paused
  duration?: number;       // Video duration in seconds (optional)
}

/**
 * Connection state
 */
export enum HereSphereConnectionState {
  NOT_CONNECTED = 0,
  CONNECTED_BUT_NO_FILE = 1,
  CONNECTED_AND_PAUSED = 2,
  CONNECTED_AND_PLAYING = 3,
}

/**
 * Funscript action point (timestamp and position)
 */
export interface FunscriptAction {
  at: number;   // Timestamp in milliseconds
  pos: number;  // Position value (0-100)
}

/**
 * Funscript file format
 */
export interface Funscript {
  version?: string;
  inverted?: boolean;
  range?: number;
  actions: FunscriptAction[];
  metadata?: Record<string, any>;
}

/**
 * Parsed funscript with normalized data
 */
export interface ParsedFunscript {
  actions: FunscriptAction[];
  inverted: boolean;
  range: number;
  duration: number; // Total duration in milliseconds
}

/**
 * Funscript file resource
 */
export interface FunscriptResource {
  filename: string;      // Full filename (e.g., "video.alpha.funscript")
  channel: string;       // Channel/type extracted from filename (e.g., "alpha", "beta", "volume")
  path: string;          // Full file path
  funscript?: ParsedFunscript;  // Loaded funscript data (lazy loaded)
}

/**
 * Collection of funscripts for a video file
 * Multiple channels (alpha, beta, volume, etc.)
 */
export interface FunscriptCollection {
  videoFilename: string;           // Base video filename (without extension)
  funscripts: FunscriptResource[];  // Array of funscript resources
  primaryFunscript?: ParsedFunscript;  // Primary funscript (alpha or first available)
}
