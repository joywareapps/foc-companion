import { StyleSheet, ScrollView, Pressable, Alert } from 'react-native';
import { useState, useEffect } from 'react';
import Slider from '@react-native-community/slider';
import { View, Text } from '@/components/Themed';
import { useDeviceStore } from '@/store/deviceStore';
import { validatePulseSettings } from '@/services/SettingsValidator';
import { SettingsLimits } from '@/types/settings';
import type { PulseSettings } from '@/types/settings';

export default function PulseSettingsScreen() {
  const { pulseSettings, deviceSettings, savePulseSettings, resetToDefaults } = useDeviceStore();

  // Local state for editing (until save)
  const [carrierFrequency, setCarrierFrequency] = useState(pulseSettings.carrierFrequency);
  const [pulseFrequency, setPulseFrequency] = useState(pulseSettings.pulseFrequency);
  const [pulseWidth, setPulseWidth] = useState(pulseSettings.pulseWidth);
  const [pulseRiseTime, setPulseRiseTime] = useState(pulseSettings.pulseRiseTime);
  const [pulseIntervalRandom, setPulseIntervalRandom] = useState(pulseSettings.pulseIntervalRandom);
  const [hasChanges, setHasChanges] = useState(false);
  const [validationErrors, setValidationErrors] = useState<string[]>([]);

  // Calculate duty cycle
  const dutyCycle = (pulseFrequency * pulseWidth) / carrierFrequency;
  const dutyCyclePercent = (dutyCycle * 100).toFixed(1);
  const dutyCycleExceeded = dutyCycle > 1.0;

  // Update local state when store settings change
  useEffect(() => {
    setCarrierFrequency(pulseSettings.carrierFrequency);
    setPulseFrequency(pulseSettings.pulseFrequency);
    setPulseWidth(pulseSettings.pulseWidth);
    setPulseRiseTime(pulseSettings.pulseRiseTime);
    setPulseIntervalRandom(pulseSettings.pulseIntervalRandom);
    setHasChanges(false);
  }, [pulseSettings]);

  // Validate settings on change
  useEffect(() => {
    const testSettings: PulseSettings = {
      carrierFrequency,
      pulseFrequency,
      pulseWidth,
      pulseRiseTime,
      pulseIntervalRandom,
    };

    const validation = validatePulseSettings(testSettings, deviceSettings);
    setValidationErrors(validation.errors);

    // Check if there are actual changes
    const changed =
      carrierFrequency !== pulseSettings.carrierFrequency ||
      pulseFrequency !== pulseSettings.pulseFrequency ||
      pulseWidth !== pulseSettings.pulseWidth ||
      pulseRiseTime !== pulseSettings.pulseRiseTime ||
      pulseIntervalRandom !== pulseSettings.pulseIntervalRandom;

    setHasChanges(changed);
  }, [carrierFrequency, pulseFrequency, pulseWidth, pulseRiseTime, pulseIntervalRandom, pulseSettings, deviceSettings]);

  const handleSave = async () => {
    if (validationErrors.length > 0) {
      Alert.alert('Validation Error', validationErrors.join('\n'));
      return;
    }

    const newSettings: PulseSettings = {
      carrierFrequency,
      pulseFrequency,
      pulseWidth,
      pulseRiseTime,
      pulseIntervalRandom,
    };

    try {
      await savePulseSettings(newSettings);
      Alert.alert('Success', 'Pulse settings saved successfully');
    } catch (error: any) {
      Alert.alert('Error', `Failed to save settings: ${error.message}`);
    }
  };

  const handleReset = () => {
    Alert.alert(
      'Reset to Defaults',
      'Are you sure you want to reset pulse settings to defaults?\n\n' +
        'Carrier Frequency: 700 Hz\n' +
        'Pulse Frequency: 50 Hz\n' +
        'Pulse Width: 5 cycles\n' +
        'Pulse Rise Time: 3 cycles\n' +
        'Pulse Interval Random: 10%',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Reset',
          style: 'destructive',
          onPress: async () => {
            try {
              await resetToDefaults();
              Alert.alert('Success', 'Pulse settings reset to defaults');
            } catch (error: any) {
              Alert.alert('Error', `Failed to reset settings: ${error.message}`);
            }
          },
        },
      ]
    );
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Pulse Settings</Text>
      <View style={styles.separator} lightColor="#eee" darkColor="rgba(255,255,255,0.1)" />

      {/* Carrier Settings Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Carrier Settings</Text>
        <Text style={styles.sectionDescription}>
          Carrier frequency must be within device safety limits
        </Text>

        {/* Carrier Frequency */}
        <View style={styles.settingContainer}>
          <View style={styles.settingHeader}>
            <Text style={styles.settingLabel}>Carrier Frequency</Text>
            <Text style={styles.settingValue}>{carrierFrequency.toFixed(0)} Hz</Text>
          </View>
          <Slider
            style={styles.slider}
            minimumValue={deviceSettings.minFrequency}
            maximumValue={deviceSettings.maxFrequency}
            step={10}
            value={carrierFrequency}
            onValueChange={setCarrierFrequency}
            minimumTrackTintColor="#3498db"
            maximumTrackTintColor="#bdc3c7"
          />
          <Text style={styles.rangeLabel}>
            Range: {deviceSettings.minFrequency}-{deviceSettings.maxFrequency} Hz (from Device Settings)
          </Text>
        </View>
      </View>

      {/* Pulse Parameters Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Pulse Parameters</Text>
        <Text style={styles.sectionDescription}>
          Configure pulse-based waveform characteristics
        </Text>

        {/* Pulse Frequency */}
        <View style={styles.settingContainer}>
          <View style={styles.settingHeader}>
            <Text style={styles.settingLabel}>Pulse Frequency</Text>
            <Text style={styles.settingValue}>{pulseFrequency.toFixed(0)} Hz</Text>
          </View>
          <Slider
            style={styles.slider}
            minimumValue={SettingsLimits.PulseFrequency.min}
            maximumValue={SettingsLimits.PulseFrequency.max}
            step={1}
            value={pulseFrequency}
            onValueChange={setPulseFrequency}
            minimumTrackTintColor="#9b59b6"
            maximumTrackTintColor="#bdc3c7"
          />
          <Text style={styles.rangeLabel}>
            Range: {SettingsLimits.PulseFrequency.min}-{SettingsLimits.PulseFrequency.max} Hz
          </Text>
        </View>

        {/* Pulse Width */}
        <View style={styles.settingContainer}>
          <View style={styles.settingHeader}>
            <Text style={styles.settingLabel}>Pulse Width</Text>
            <Text style={styles.settingValue}>{pulseWidth.toFixed(0)} cycles</Text>
          </View>
          <Slider
            style={styles.slider}
            minimumValue={SettingsLimits.PulseWidth.min}
            maximumValue={SettingsLimits.PulseWidth.max}
            step={1}
            value={pulseWidth}
            onValueChange={setPulseWidth}
            minimumTrackTintColor="#e67e22"
            maximumTrackTintColor="#bdc3c7"
          />
          <Text style={styles.rangeLabel}>
            Range: {SettingsLimits.PulseWidth.min}-{SettingsLimits.PulseWidth.max} cycles
          </Text>
        </View>

        {/* Pulse Rise Time */}
        <View style={styles.settingContainer}>
          <View style={styles.settingHeader}>
            <Text style={styles.settingLabel}>Pulse Rise Time</Text>
            <Text style={styles.settingValue}>{pulseRiseTime.toFixed(0)} cycles</Text>
          </View>
          <Slider
            style={styles.slider}
            minimumValue={SettingsLimits.PulseRiseTime.min}
            maximumValue={SettingsLimits.PulseRiseTime.max}
            step={1}
            value={pulseRiseTime}
            onValueChange={setPulseRiseTime}
            minimumTrackTintColor="#16a085"
            maximumTrackTintColor="#bdc3c7"
          />
          <Text style={styles.rangeLabel}>
            Range: {SettingsLimits.PulseRiseTime.min}-{SettingsLimits.PulseRiseTime.max} cycles
          </Text>
          <Text style={styles.helpText}>
            Controls how quickly the pulse reaches full amplitude
          </Text>
        </View>

        {/* Pulse Interval Random */}
        <View style={styles.settingContainer}>
          <View style={styles.settingHeader}>
            <Text style={styles.settingLabel}>Pulse Interval Randomization</Text>
            <Text style={styles.settingValue}>{pulseIntervalRandom.toFixed(0)}%</Text>
          </View>
          <Slider
            style={styles.slider}
            minimumValue={SettingsLimits.PulseIntervalRandom.min}
            maximumValue={SettingsLimits.PulseIntervalRandom.max}
            step={1}
            value={pulseIntervalRandom}
            onValueChange={setPulseIntervalRandom}
            minimumTrackTintColor="#f39c12"
            maximumTrackTintColor="#bdc3c7"
          />
          <Text style={styles.rangeLabel}>
            Range: {SettingsLimits.PulseIntervalRandom.min}-{SettingsLimits.PulseIntervalRandom.max}%
          </Text>
          <Text style={styles.helpText}>
            Randomizes pulse timing to prevent habituation (0% = regular intervals)
          </Text>
        </View>
      </View>

      {/* Duty Cycle Display */}
      <View style={[styles.section, dutyCycleExceeded && styles.warningSection]}>
        <Text style={styles.sectionTitle}>Duty Cycle Analysis</Text>
        <View style={styles.dutyCycleContainer}>
          <Text style={styles.dutyCycleLabel}>Current Duty Cycle:</Text>
          <Text style={[styles.dutyCycleValue, dutyCycleExceeded && styles.dutyCycleWarning]}>
            {dutyCyclePercent}%
          </Text>
        </View>
        <Text style={styles.dutyCycleFormula}>
          Formula: (Pulse Freq × Pulse Width) / Carrier Freq
        </Text>
        {dutyCycleExceeded && (
          <View style={styles.warningBox}>
            <Text style={styles.warningIcon}>⚠️</Text>
            <Text style={styles.warningText}>
              Duty cycle exceeds 100%! This may cause issues.{'\n'}
              Reduce pulse width or pulse frequency.
            </Text>
          </View>
        )}
      </View>

      {/* Validation Errors */}
      {validationErrors.length > 0 && (
        <View style={styles.errorContainer}>
          <Text style={styles.errorTitle}>⚠️ Validation Errors:</Text>
          {validationErrors.map((error, index) => (
            <Text key={index} style={styles.errorText}>
              • {error}
            </Text>
          ))}
        </View>
      )}

      {/* Action Buttons */}
      <View style={styles.actionsContainer}>
        <Pressable
          style={[styles.button, styles.resetButton]}
          onPress={handleReset}>
          <Text style={styles.buttonText}>Reset to Defaults</Text>
        </Pressable>

        <Pressable
          style={[
            styles.button,
            styles.saveButton,
            (!hasChanges || validationErrors.length > 0) && styles.buttonDisabled,
          ]}
          onPress={handleSave}
          disabled={!hasChanges || validationErrors.length > 0}>
          <Text style={styles.buttonText}>
            {!hasChanges ? 'No Changes' : 'Save Settings'}
          </Text>
        </Pressable>
      </View>

      <View style={styles.bottomPadding} />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  contentContainer: {
    alignItems: 'center',
    paddingTop: 20,
    paddingHorizontal: 20,
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
  },
  separator: {
    marginVertical: 15,
    height: 1,
    width: '100%',
  },
  section: {
    width: '100%',
    marginBottom: 20,
    padding: 15,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    backgroundColor: 'rgba(255, 255, 255, 0.05)',
  },
  warningSection: {
    borderColor: '#f39c12',
    backgroundColor: 'rgba(243, 156, 18, 0.1)',
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 5,
  },
  sectionDescription: {
    fontSize: 12,
    color: '#666',
    marginBottom: 15,
  },
  settingContainer: {
    marginBottom: 20,
  },
  settingHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  settingLabel: {
    fontSize: 14,
    fontWeight: '600',
  },
  settingValue: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#3498db',
  },
  slider: {
    width: '100%',
    height: 40,
  },
  rangeLabel: {
    fontSize: 11,
    color: '#999',
    textAlign: 'center',
    marginTop: 4,
  },
  helpText: {
    fontSize: 11,
    color: '#7f8c8d',
    fontStyle: 'italic',
    marginTop: 8,
    lineHeight: 16,
  },
  dutyCycleContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
    paddingVertical: 10,
  },
  dutyCycleLabel: {
    fontSize: 14,
    fontWeight: '600',
  },
  dutyCycleValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#27ae60',
  },
  dutyCycleWarning: {
    color: '#e74c3c',
  },
  dutyCycleFormula: {
    fontSize: 11,
    color: '#7f8c8d',
    fontStyle: 'italic',
    marginBottom: 10,
  },
  warningBox: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 12,
    backgroundColor: 'rgba(231, 76, 60, 0.15)',
    borderRadius: 6,
    borderWidth: 1,
    borderColor: '#e74c3c',
    marginTop: 10,
  },
  warningIcon: {
    fontSize: 20,
    marginRight: 10,
  },
  warningText: {
    flex: 1,
    fontSize: 12,
    color: '#c0392b',
    fontWeight: '600',
    lineHeight: 18,
  },
  errorContainer: {
    width: '100%',
    padding: 15,
    backgroundColor: 'rgba(231, 76, 60, 0.1)',
    borderWidth: 1,
    borderColor: '#e74c3c',
    borderRadius: 8,
    marginBottom: 20,
  },
  errorTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#e74c3c',
    marginBottom: 8,
  },
  errorText: {
    fontSize: 12,
    color: '#e74c3c',
    marginBottom: 4,
  },
  actionsContainer: {
    width: '100%',
    gap: 10,
  },
  button: {
    paddingVertical: 14,
    paddingHorizontal: 25,
    borderRadius: 8,
    alignItems: 'center',
  },
  resetButton: {
    backgroundColor: '#95a5a6',
  },
  saveButton: {
    backgroundColor: '#27ae60',
  },
  buttonDisabled: {
    backgroundColor: '#bdc3c7',
    opacity: 0.6,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  bottomPadding: {
    height: 40,
  },
});
