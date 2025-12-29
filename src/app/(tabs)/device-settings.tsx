import { StyleSheet, ScrollView, Pressable, Alert } from 'react-native';
import { useState, useEffect } from 'react';
import Slider from '@react-native-community/slider';
import { View, Text } from '@/components/Themed';
import { useDeviceStore } from '@/store/deviceStore';
import { validateDeviceSettings, ampsToMilliamps, milliampsToAmps } from '@/services/SettingsValidator';
import { SettingsLimits } from '@/types/settings';
import type { DeviceSettings } from '@/types/settings';

export default function DeviceSettingsScreen() {
  const { deviceSettings, saveDeviceSettings, resetToDefaults } = useDeviceStore();

  // Local state for editing (until save)
  const [minFrequency, setMinFrequency] = useState(deviceSettings.minFrequency);
  const [maxFrequency, setMaxFrequency] = useState(deviceSettings.maxFrequency);
  const [amplitudeMilliamps, setAmplitudeMilliamps] = useState(
    ampsToMilliamps(deviceSettings.waveformAmplitude)
  );
  const [calibration3Center, setCalibration3Center] = useState(deviceSettings.calibration3Center);
  const [calibration3Up, setCalibration3Up] = useState(deviceSettings.calibration3Up);
  const [calibration3Left, setCalibration3Left] = useState(deviceSettings.calibration3Left);
  const [hasChanges, setHasChanges] = useState(false);
  const [validationErrors, setValidationErrors] = useState<string[]>([]);

  // Update local state when store settings change
  useEffect(() => {
    setMinFrequency(deviceSettings.minFrequency);
    setMaxFrequency(deviceSettings.maxFrequency);
    setAmplitudeMilliamps(ampsToMilliamps(deviceSettings.waveformAmplitude));
    setCalibration3Center(deviceSettings.calibration3Center);
    setCalibration3Up(deviceSettings.calibration3Up);
    setCalibration3Left(deviceSettings.calibration3Left);
    setHasChanges(false);
  }, [deviceSettings]);

  // Validate settings on change
  useEffect(() => {
    const testSettings: DeviceSettings = {
      ...deviceSettings,
      minFrequency,
      maxFrequency,
      waveformAmplitude: milliampsToAmps(amplitudeMilliamps),
      calibration3Center,
      calibration3Up,
      calibration3Left,
    };

    const validation = validateDeviceSettings(testSettings);
    setValidationErrors(validation.errors);

    // Check if there are actual changes
    const changed =
      minFrequency !== deviceSettings.minFrequency ||
      maxFrequency !== deviceSettings.maxFrequency ||
      amplitudeMilliamps !== ampsToMilliamps(deviceSettings.waveformAmplitude) ||
      calibration3Center !== deviceSettings.calibration3Center ||
      calibration3Up !== deviceSettings.calibration3Up ||
      calibration3Left !== deviceSettings.calibration3Left;

    setHasChanges(changed);
  }, [minFrequency, maxFrequency, amplitudeMilliamps, calibration3Center, calibration3Up, calibration3Left, deviceSettings]);

  const handleSave = async () => {
    if (validationErrors.length > 0) {
      Alert.alert('Validation Error', validationErrors.join('\n'));
      return;
    }

    const newSettings: DeviceSettings = {
      ...deviceSettings,
      minFrequency,
      maxFrequency,
      waveformAmplitude: milliampsToAmps(amplitudeMilliamps),
      calibration3Center,
      calibration3Up,
      calibration3Left,
    };

    try {
      await saveDeviceSettings(newSettings);
      Alert.alert('Success', 'Device settings saved successfully');
    } catch (error: any) {
      Alert.alert('Error', `Failed to save settings: ${error.message}`);
    }
  };

  const handleReset = () => {
    Alert.alert(
      'Reset to Defaults',
      'Are you sure you want to reset all settings to defaults?\n\n' +
        'Min Frequency: 500 Hz\n' +
        'Max Frequency: 1500 Hz\n' +
        'Amplitude: 120 mA\n' +
        'Calibration Center: -0.5\n' +
        'Calibration Up: 0\n' +
        'Calibration Left: 0',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Reset',
          style: 'destructive',
          onPress: async () => {
            try {
              await resetToDefaults();
              Alert.alert('Success', 'Settings reset to defaults');
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
      <Text style={styles.title}>Device Settings</Text>
      <View style={styles.separator} lightColor="#eee" darkColor="rgba(255,255,255,0.1)" />

      {/* Safety Limits Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Safety Limits</Text>
        <Text style={styles.sectionDescription}>
          Configure safe operating ranges for carrier frequency and output amplitude
        </Text>

        {/* Min Carrier Frequency */}
        <View style={styles.settingContainer}>
          <View style={styles.settingHeader}>
            <Text style={styles.settingLabel}>Min Carrier Frequency</Text>
            <Text style={styles.settingValue}>{minFrequency.toFixed(0)} Hz</Text>
          </View>
          <Slider
            style={styles.slider}
            minimumValue={SettingsLimits.CarrierFrequency.min}
            maximumValue={SettingsLimits.CarrierFrequency.max}
            step={10}
            value={minFrequency}
            onValueChange={setMinFrequency}
            minimumTrackTintColor="#3498db"
            maximumTrackTintColor="#bdc3c7"
          />
          <Text style={styles.rangeLabel}>
            Range: {SettingsLimits.CarrierFrequency.min}-{SettingsLimits.CarrierFrequency.max} Hz
          </Text>
        </View>

        {/* Max Carrier Frequency */}
        <View style={styles.settingContainer}>
          <View style={styles.settingHeader}>
            <Text style={styles.settingLabel}>Max Carrier Frequency</Text>
            <Text style={styles.settingValue}>{maxFrequency.toFixed(0)} Hz</Text>
          </View>
          <Slider
            style={styles.slider}
            minimumValue={SettingsLimits.CarrierFrequency.min}
            maximumValue={SettingsLimits.CarrierFrequency.max}
            step={10}
            value={maxFrequency}
            onValueChange={setMaxFrequency}
            minimumTrackTintColor="#3498db"
            maximumTrackTintColor="#bdc3c7"
          />
          <Text style={styles.rangeLabel}>
            Range: {SettingsLimits.CarrierFrequency.min}-{SettingsLimits.CarrierFrequency.max} Hz
          </Text>
        </View>

        {/* Waveform Amplitude */}
        <View style={styles.settingContainer}>
          <View style={styles.settingHeader}>
            <Text style={styles.settingLabel}>Waveform Amplitude</Text>
            <Text style={styles.settingValue}>{amplitudeMilliamps.toFixed(0)} mA</Text>
          </View>
          <Slider
            style={styles.slider}
            minimumValue={ampsToMilliamps(SettingsLimits.WaveformAmplitude.min)}
            maximumValue={ampsToMilliamps(SettingsLimits.WaveformAmplitude.max)}
            step={1}
            value={amplitudeMilliamps}
            onValueChange={setAmplitudeMilliamps}
            minimumTrackTintColor="#e74c3c"
            maximumTrackTintColor="#bdc3c7"
          />
          <Text style={styles.rangeLabel}>
            Range: {ampsToMilliamps(SettingsLimits.WaveformAmplitude.min)}-
            {ampsToMilliamps(SettingsLimits.WaveformAmplitude.max)} mA
          </Text>
        </View>
      </View>

      {/* Calibration Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Calibration</Text>
        <Text style={styles.sectionDescription}>
          3-phase output calibration parameters for fine-tuning device behavior
        </Text>

        {/* Calibration Center */}
        <View style={styles.settingContainer}>
          <View style={styles.settingHeader}>
            <Text style={styles.settingLabel}>Center Calibration</Text>
            <Text style={styles.settingValue}>{calibration3Center.toFixed(2)}</Text>
          </View>
          <Slider
            style={styles.slider}
            minimumValue={SettingsLimits.Calibration3Phase.min}
            maximumValue={SettingsLimits.Calibration3Phase.max}
            step={0.1}
            value={calibration3Center}
            onValueChange={setCalibration3Center}
            minimumTrackTintColor="#9b59b6"
            maximumTrackTintColor="#bdc3c7"
          />
          <Text style={styles.rangeLabel}>
            Range: {SettingsLimits.Calibration3Phase.min} to {SettingsLimits.Calibration3Phase.max}
          </Text>
        </View>

        {/* Calibration Up */}
        <View style={styles.settingContainer}>
          <View style={styles.settingHeader}>
            <Text style={styles.settingLabel}>Up Calibration</Text>
            <Text style={styles.settingValue}>{calibration3Up.toFixed(2)}</Text>
          </View>
          <Slider
            style={styles.slider}
            minimumValue={SettingsLimits.Calibration3Phase.min}
            maximumValue={SettingsLimits.Calibration3Phase.max}
            step={0.1}
            value={calibration3Up}
            onValueChange={setCalibration3Up}
            minimumTrackTintColor="#9b59b6"
            maximumTrackTintColor="#bdc3c7"
          />
          <Text style={styles.rangeLabel}>
            Range: {SettingsLimits.Calibration3Phase.min} to {SettingsLimits.Calibration3Phase.max}
          </Text>
        </View>

        {/* Calibration Left */}
        <View style={styles.settingContainer}>
          <View style={styles.settingHeader}>
            <Text style={styles.settingLabel}>Left Calibration</Text>
            <Text style={styles.settingValue}>{calibration3Left.toFixed(2)}</Text>
          </View>
          <Slider
            style={styles.slider}
            minimumValue={SettingsLimits.Calibration3Phase.min}
            maximumValue={SettingsLimits.Calibration3Phase.max}
            step={0.1}
            value={calibration3Left}
            onValueChange={setCalibration3Left}
            minimumTrackTintColor="#9b59b6"
            maximumTrackTintColor="#bdc3c7"
          />
          <Text style={styles.rangeLabel}>
            Range: {SettingsLimits.Calibration3Phase.min} to {SettingsLimits.Calibration3Phase.max}
          </Text>
        </View>
      </View>

      {/* Device Type Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Device Configuration</Text>

        <View style={styles.infoRow}>
          <Text style={styles.infoLabel}>Device Type:</Text>
          <Text style={styles.infoValue}>FOC-Stim V3 / 3-Phase</Text>
        </View>

        <Text style={styles.infoNote}>
          Note: FOC-Stim devices use electromagnetic field patterns controlled by pulse parameters.
          All pulse settings are configured in the Pulse Settings screen.
        </Text>
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
  infoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 15,
    paddingVertical: 8,
  },
  infoLabel: {
    fontSize: 14,
    color: '#666',
  },
  infoValue: {
    fontSize: 14,
    fontWeight: '600',
  },
  infoNote: {
    fontSize: 12,
    color: '#666',
    fontStyle: 'italic',
    marginTop: 10,
    lineHeight: 18,
  },
  buttonGroup: {
    flexDirection: 'row',
    gap: 10,
    marginTop: 8,
  },
  typeButton: {
    flex: 1,
    paddingVertical: 10,
    paddingHorizontal: 15,
    borderWidth: 1,
    borderColor: '#3498db',
    borderRadius: 6,
    backgroundColor: 'transparent',
  },
  typeButtonActive: {
    backgroundColor: '#3498db',
  },
  typeButtonText: {
    textAlign: 'center',
    fontSize: 14,
    color: '#3498db',
  },
  typeButtonTextActive: {
    color: '#fff',
    fontWeight: '600',
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
