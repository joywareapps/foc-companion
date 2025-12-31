// Settings type definitions for FOC Companion mobile app
// Based on desktop app settings structure from restim-desktop

/**
 * Device type enumeration
 * Mobile app supports FOC-Stim threephase only
 */
export enum DeviceType {
  NONE = 0,
  AUDIO_THREE_PHASE = 1,
  FOCSTIM_THREE_PHASE = 5,  // Primary for mobile
  NEOSTIM_THREE_PHASE = 6,
  FOCSTIM_FOUR_PHASE = 7,
}

/**
 * Waveform type enumeration
 */
export enum WaveformType {
  CONTINUOUS = 1,      // Continuous carrier signal
  PULSE_BASED = 2,     // Pulse-based modulation
  A_B_TESTING = 3,     // A/B testing mode
}

/**
 * Device configuration settings
 * Controls safety limits and device-specific parameters
 */
export interface DeviceSettings {
  deviceType: DeviceType;
  waveformType: WaveformType;
  minFrequency: number;      // Hz, range: 500-2000, default: 500
  maxFrequency: number;      // Hz, range: 500-2000, default: 1500
  waveformAmplitude: number; // Amps, range: 0.01-0.15, default: 0.120
  calibration3Center: number; // 3-phase center calibration, range: -2.0 to 2.0, default: -0.5
  calibration3Up: number;     // 3-phase up calibration, range: -2.0 to 2.0, default: 0
  calibration3Left: number;   // 3-phase left calibration, range: -2.0 to 2.0, default: 0
}

/**
 * Pulse generation settings
 * Controls pulse-based waveform parameters
 */
export interface PulseSettings {
  carrierFrequency: number;  // Hz, uses device min-max range, default: 700
  pulseFrequency: number;    // Hz, range: 1-300, default: 50
  pulseWidth: number;        // cycles, range: 3-100, default: 5
  pulseRiseTime: number;     // cycles, range: 2-100, default: 10
  pulseIntervalRandom: number; // %, range: 0-100, default: 10
}

/**
 * FOC-Stim connection settings
 */
export interface FocStimSettings {
  communicationSerial: boolean;  // default: false (mobile)
  communicationWifi: boolean;    // default: true (mobile)
  wifiSsid: string;             // default: ''
  wifiPassword: string;         // default: ''
  wifiIp: string;               // default: ''
}

/**
 * Funscript location type (WebDAV share or local directory)
 */
export type FunscriptLocationType = 'webdav' | 'local';

/**
 * Individual funscript location configuration
 * Can be either WebDAV network share or local directory
 */
export interface FunscriptLocation {
  id: string;                      // Unique identifier (UUID)
  name: string;                    // User-friendly name (e.g., "NAS Movies", "Phone Downloads")
  type: FunscriptLocationType;     // 'webdav' or 'local'
  enabled: boolean;                // Whether to search this location

  // WebDAV-specific fields (when type === 'webdav')
  webdavUrl?: string;              // WebDAV server URL (e.g., http://192.168.1.10/webdav/movies)
  webdavUsername?: string;         // WebDAV username for authentication
  webdavPassword?: string;         // WebDAV password for authentication

  // Local-specific fields (when type === 'local')
  localPath?: string;              // Local directory path (e.g., /storage/emulated/0/Download)
}

/**
 * Media Sync settings for HereSphere integration
 */
export interface MediaSyncSettings {
  // HereSphere player configuration
  hereSphereEnabled: boolean;      // default: false
  hereSphereIp: string;            // default: ''
  hereSpherePort: number;          // default: 23554

  // Funscript location configuration
  // Multiple locations (SMB shares and/or local directories)
  funscriptLocations: FunscriptLocation[];  // default: []
}

/**
 * Complete application settings
 * Combines all settings categories
 */
export interface AppSettings {
  device: DeviceSettings;
  pulse: PulseSettings;
  focstim: FocStimSettings;
  mediaSync: MediaSyncSettings;
}

/**
 * Validation limits for FOC-Stim hardware
 * Updated based on actual device capabilities
 */
export const SettingsLimits = {
  CarrierFrequency: {
    min: 500,   // Hz
    max: 2000,  // Hz
  },
  WaveformAmplitude: {
    min: 0.01,  // Amperes (10 mA)
    max: 0.15,  // Amperes (150 mA)
  },
  PulseFrequency: {
    min: 1,     // Hz
    max: 100,   // Hz - FOC-Stim hardware limit
  },
  PulseWidth: {
    min: 3,     // cycles
    max: 15,    // cycles - FOC-Stim hardware limit
  },
  PulseRiseTime: {
    min: 2,     // cycles
    max: 5,     // cycles - FOC-Stim hardware limit
  },
  PulseIntervalRandom: {
    min: 0,     // %
    max: 100,   // %
  },
  Calibration3Phase: {
    min: -2.0,  // normalized float
    max: 2.0,   // normalized float
  },
} as const;

/**
 * Default settings matching desktop app
 */
export const DefaultSettings: AppSettings = {
  device: {
    deviceType: DeviceType.FOCSTIM_THREE_PHASE,
    waveformType: WaveformType.CONTINUOUS,
    minFrequency: 500,      // Hz
    maxFrequency: 1500,     // Hz (user requested default)
    waveformAmplitude: 0.120, // 120 mA (desktop default, not 10 mA!)
    calibration3Center: -0.5, // 3-phase center calibration
    calibration3Up: 0,        // 3-phase up calibration
    calibration3Left: 0,      // 3-phase left calibration
  },
  pulse: {
    carrierFrequency: 700,  // Hz (within min-max range)
    pulseFrequency: 50,     // Hz
    pulseWidth: 5,          // cycles
    pulseRiseTime: 3,       // cycles (within 2-5 range)
    pulseIntervalRandom: 10, // %
  },
  focstim: {
    communicationSerial: false, // Mobile uses WiFi by default
    communicationWifi: true,
    wifiSsid: '',
    wifiPassword: '',
    wifiIp: '',
  },
  mediaSync: {
    hereSphereEnabled: false,
    hereSphereIp: '',
    hereSpherePort: 23554,           // Default HereSphere port
    funscriptLocations: [],          // Empty by default, user must configure locations
  },
};

/**
 * Validation result type
 */
export interface ValidationResult {
  valid: boolean;
  errors: string[];
}

/**
 * Settings validation error types
 */
export enum ValidationErrorType {
  FREQUENCY_RANGE = 'FREQUENCY_RANGE',
  FREQUENCY_ORDER = 'FREQUENCY_ORDER',
  AMPLITUDE_RANGE = 'AMPLITUDE_RANGE',
  PULSE_FREQUENCY_RANGE = 'PULSE_FREQUENCY_RANGE',
  PULSE_WIDTH_RANGE = 'PULSE_WIDTH_RANGE',
  PULSE_RISE_TIME_RANGE = 'PULSE_RISE_TIME_RANGE',
  DUTY_CYCLE_EXCEEDED = 'DUTY_CYCLE_EXCEEDED',
}
