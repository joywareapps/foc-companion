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
 * Complete application settings
 * Combines all settings categories
 */
export interface AppSettings {
  device: DeviceSettings;
  pulse: PulseSettings;
  focstim: FocStimSettings;
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
