// Settings validation utilities
// Validates settings against limits from desktop app

import {
  DeviceSettings,
  PulseSettings,
  AppSettings,
  SettingsLimits,
  ValidationResult,
  ValidationErrorType,
} from '@/types/settings';

/**
 * Validate device settings
 */
export function validateDeviceSettings(settings: DeviceSettings): ValidationResult {
  const errors: string[] = [];

  // Validate min frequency range
  if (settings.minFrequency < SettingsLimits.CarrierFrequency.min ||
      settings.minFrequency > SettingsLimits.CarrierFrequency.max) {
    errors.push(
      `Min frequency must be between ${SettingsLimits.CarrierFrequency.min} and ${SettingsLimits.CarrierFrequency.max} Hz`
    );
  }

  // Validate max frequency range
  if (settings.maxFrequency < SettingsLimits.CarrierFrequency.min ||
      settings.maxFrequency > SettingsLimits.CarrierFrequency.max) {
    errors.push(
      `Max frequency must be between ${SettingsLimits.CarrierFrequency.min} and ${SettingsLimits.CarrierFrequency.max} Hz`
    );
  }

  // Validate min < max
  if (settings.minFrequency >= settings.maxFrequency) {
    errors.push('Min frequency must be less than max frequency');
  }

  // Validate amplitude range
  if (settings.waveformAmplitude < SettingsLimits.WaveformAmplitude.min ||
      settings.waveformAmplitude > SettingsLimits.WaveformAmplitude.max) {
    errors.push(
      `Waveform amplitude must be between ${SettingsLimits.WaveformAmplitude.min * 1000} and ${SettingsLimits.WaveformAmplitude.max * 1000} mA`
    );
  }

  return {
    valid: errors.length === 0,
    errors,
  };
}

/**
 * Validate pulse settings
 */
export function validatePulseSettings(
  settings: PulseSettings,
  deviceSettings: DeviceSettings
): ValidationResult {
  const errors: string[] = [];

  // Validate carrier frequency within device limits
  if (settings.carrierFrequency < deviceSettings.minFrequency ||
      settings.carrierFrequency > deviceSettings.maxFrequency) {
    errors.push(
      `Carrier frequency must be between ${deviceSettings.minFrequency} and ${deviceSettings.maxFrequency} Hz (device limits)`
    );
  }

  // Validate pulse frequency range
  if (settings.pulseFrequency < SettingsLimits.PulseFrequency.min ||
      settings.pulseFrequency > SettingsLimits.PulseFrequency.max) {
    errors.push(
      `Pulse frequency must be between ${SettingsLimits.PulseFrequency.min} and ${SettingsLimits.PulseFrequency.max} Hz`
    );
  }

  // Validate pulse width range
  if (settings.pulseWidth < SettingsLimits.PulseWidth.min ||
      settings.pulseWidth > SettingsLimits.PulseWidth.max) {
    errors.push(
      `Pulse width must be between ${SettingsLimits.PulseWidth.min} and ${SettingsLimits.PulseWidth.max} cycles`
    );
  }

  // Validate pulse rise time range
  if (settings.pulseRiseTime < SettingsLimits.PulseRiseTime.min ||
      settings.pulseRiseTime > SettingsLimits.PulseRiseTime.max) {
    errors.push(
      `Pulse rise time must be between ${SettingsLimits.PulseRiseTime.min} and ${SettingsLimits.PulseRiseTime.max} cycles`
    );
  }

  // Validate pulse interval random range
  if (settings.pulseIntervalRandom < SettingsLimits.PulseIntervalRandom.min ||
      settings.pulseIntervalRandom > SettingsLimits.PulseIntervalRandom.max) {
    errors.push(
      `Pulse interval random must be between ${SettingsLimits.PulseIntervalRandom.min} and ${SettingsLimits.PulseIntervalRandom.max}%`
    );
  }

  return {
    valid: errors.length === 0,
    errors,
  };
}

/**
 * Calculate duty cycle
 * Formula from desktop app: (pulseFreq * pulseWidth) / carrierFreq
 */
export function calculateDutyCycle(
  pulseFrequency: number,
  pulseWidth: number,
  carrierFrequency: number
): number {
  if (carrierFrequency === 0) return 0;
  return (pulseFrequency * pulseWidth) / carrierFrequency;
}

/**
 * Check if duty cycle exceeds 100%
 * Returns warning message if exceeded, null otherwise
 */
export function checkDutyCycle(
  pulseFrequency: number,
  pulseWidth: number,
  carrierFrequency: number
): string | null {
  const dutyCycle = calculateDutyCycle(pulseFrequency, pulseWidth, carrierFrequency);

  if (dutyCycle > 1.0) {
    return `Duty cycle (${(dutyCycle * 100).toFixed(1)}%) exceeds 100% - reduce pulse width or frequency`;
  }

  return null;
}

/**
 * Validate complete app settings
 */
export function validateAppSettings(settings: AppSettings): ValidationResult {
  const errors: string[] = [];

  // Validate device settings
  const deviceValidation = validateDeviceSettings(settings.device);
  errors.push(...deviceValidation.errors);

  // Validate pulse settings
  const pulseValidation = validatePulseSettings(settings.pulse, settings.device);
  errors.push(...pulseValidation.errors);

  // Check duty cycle (warning, not error)
  const dutyCycleWarning = checkDutyCycle(
    settings.pulse.pulseFrequency,
    settings.pulse.pulseWidth,
    settings.pulse.carrierFrequency
  );
  if (dutyCycleWarning) {
    errors.push(dutyCycleWarning);
  }

  return {
    valid: errors.length === 0,
    errors,
  };
}

/**
 * Convert amplitude from Amperes to milliamperes for display
 */
export function ampsToMilliamps(amps: number): number {
  return amps * 1000;
}

/**
 * Convert amplitude from milliamperes to Amperes for storage
 */
export function milliampsToAmps(milliamps: number): number {
  return milliamps / 1000;
}
