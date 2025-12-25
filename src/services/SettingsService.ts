// Settings persistence service using AsyncStorage
// Handles load/save operations for all app settings

import AsyncStorage from '@react-native-async-storage/async-storage';
import {
  AppSettings,
  DeviceSettings,
  PulseSettings,
  FocStimSettings,
  DefaultSettings,
} from '@/types/settings';
import { validateAppSettings } from './SettingsValidator';

/**
 * AsyncStorage keys for settings persistence
 */
export const STORAGE_KEYS = {
  DEVICE_SETTINGS: '@foccompanion/device_settings',
  PULSE_SETTINGS: '@foccompanion/pulse_settings',
  FOCSTIM_SETTINGS: '@foccompanion/focstim_settings',
} as const;

/**
 * Settings Service
 * Provides load/save operations for application settings
 */
export class SettingsService {
  /**
   * Load device settings from storage
   * Returns default settings if not found or invalid
   */
  static async loadDeviceSettings(): Promise<DeviceSettings> {
    try {
      const stored = await AsyncStorage.getItem(STORAGE_KEYS.DEVICE_SETTINGS);
      if (!stored) {
        return DefaultSettings.device;
      }

      const settings: DeviceSettings = JSON.parse(stored);
      return settings;
    } catch (error) {
      console.error('[SettingsService] Error loading device settings:', error);
      return DefaultSettings.device;
    }
  }

  /**
   * Save device settings to storage
   */
  static async saveDeviceSettings(settings: DeviceSettings): Promise<void> {
    try {
      await AsyncStorage.setItem(
        STORAGE_KEYS.DEVICE_SETTINGS,
        JSON.stringify(settings)
      );
    } catch (error) {
      console.error('[SettingsService] Error saving device settings:', error);
      throw error;
    }
  }

  /**
   * Load pulse settings from storage
   * Returns default settings if not found or invalid
   */
  static async loadPulseSettings(): Promise<PulseSettings> {
    try {
      const stored = await AsyncStorage.getItem(STORAGE_KEYS.PULSE_SETTINGS);
      if (!stored) {
        return DefaultSettings.pulse;
      }

      const settings: PulseSettings = JSON.parse(stored);
      return settings;
    } catch (error) {
      console.error('[SettingsService] Error loading pulse settings:', error);
      return DefaultSettings.pulse;
    }
  }

  /**
   * Save pulse settings to storage
   */
  static async savePulseSettings(settings: PulseSettings): Promise<void> {
    try {
      await AsyncStorage.setItem(
        STORAGE_KEYS.PULSE_SETTINGS,
        JSON.stringify(settings)
      );
    } catch (error) {
      console.error('[SettingsService] Error saving pulse settings:', error);
      throw error;
    }
  }

  /**
   * Load FOC-Stim settings from storage
   * Returns default settings if not found or invalid
   */
  static async loadFocStimSettings(): Promise<FocStimSettings> {
    try {
      const stored = await AsyncStorage.getItem(STORAGE_KEYS.FOCSTIM_SETTINGS);
      if (!stored) {
        return DefaultSettings.focstim;
      }

      const settings: FocStimSettings = JSON.parse(stored);
      return settings;
    } catch (error) {
      console.error('[SettingsService] Error loading FOC-Stim settings:', error);
      return DefaultSettings.focstim;
    }
  }

  /**
   * Save FOC-Stim settings to storage
   */
  static async saveFocStimSettings(settings: FocStimSettings): Promise<void> {
    try {
      await AsyncStorage.setItem(
        STORAGE_KEYS.FOCSTIM_SETTINGS,
        JSON.stringify(settings)
      );
    } catch (error) {
      console.error('[SettingsService] Error saving FOC-Stim settings:', error);
      throw error;
    }
  }

  /**
   * Load all settings from storage
   * Returns default settings for any missing components
   */
  static async loadAllSettings(): Promise<AppSettings> {
    const [device, pulse, focstim] = await Promise.all([
      this.loadDeviceSettings(),
      this.loadPulseSettings(),
      this.loadFocStimSettings(),
    ]);

    return { device, pulse, focstim };
  }

  /**
   * Save all settings to storage
   */
  static async saveAllSettings(settings: AppSettings): Promise<void> {
    // Validate settings before saving
    const validation = validateAppSettings(settings);
    if (!validation.valid) {
      throw new Error(`Invalid settings: ${validation.errors.join(', ')}`);
    }

    await Promise.all([
      this.saveDeviceSettings(settings.device),
      this.savePulseSettings(settings.pulse),
      this.saveFocStimSettings(settings.focstim),
    ]);
  }

  /**
   * Reset all settings to defaults
   */
  static async resetToDefaults(): Promise<void> {
    await this.saveAllSettings(DefaultSettings);
  }

  /**
   * Clear all settings from storage
   */
  static async clearAllSettings(): Promise<void> {
    await AsyncStorage.multiRemove([
      STORAGE_KEYS.DEVICE_SETTINGS,
      STORAGE_KEYS.PULSE_SETTINGS,
      STORAGE_KEYS.FOCSTIM_SETTINGS,
    ]);
  }

  /**
   * Migrate WiFi IP from old settings screen storage
   * This ensures backwards compatibility with existing installations
   */
  static async migrateWifiIpFromOldStorage(): Promise<void> {
    try {
      // Check if we have the old IP address stored under a different key
      // (Assuming old settings screen used a different key)
      const OLD_IP_KEY = '@foccompanion/wifi_ip';
      const oldIp = await AsyncStorage.getItem(OLD_IP_KEY);

      if (oldIp) {
        // Load current FOC-Stim settings
        const focstimSettings = await this.loadFocStimSettings();

        // Only migrate if new settings don't have an IP yet
        if (!focstimSettings.wifiIp) {
          focstimSettings.wifiIp = oldIp;
          await this.saveFocStimSettings(focstimSettings);
          console.log('[SettingsService] Migrated WiFi IP from old storage');
        }

        // Remove old key
        await AsyncStorage.removeItem(OLD_IP_KEY);
      }
    } catch (error) {
      console.error('[SettingsService] Error migrating WiFi IP:', error);
      // Don't throw - migration failures shouldn't break the app
    }
  }
}
