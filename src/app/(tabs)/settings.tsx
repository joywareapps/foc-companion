import { StyleSheet, ScrollView, TextInput, Pressable, Alert } from 'react-native';
import { useState, useEffect } from 'react';
import { Text, View } from '@/components/Themed';
import { useDeviceStore } from '@/store/deviceStore';

export default function TabSettingsScreen() {
  const { focstimSettings, saveFocStimSettings } = useDeviceStore();

  const [wifiIp, setWifiIp] = useState(focstimSettings.wifiIp);
  const [hasChanges, setHasChanges] = useState(false);

  // Update local state when store settings change
  useEffect(() => {
    setWifiIp(focstimSettings.wifiIp);
    setHasChanges(false);
  }, [focstimSettings]);

  // Check for changes
  useEffect(() => {
    const changed = wifiIp !== focstimSettings.wifiIp;
    setHasChanges(changed);
  }, [wifiIp, focstimSettings]);

  const handleSave = async () => {
    // Basic IP validation
    const ipPattern = /^(\d{1,3}\.){3}\d{1,3}$/;
    if (wifiIp && !ipPattern.test(wifiIp)) {
      Alert.alert('Invalid IP Address', 'Please enter a valid IP address (e.g., 192.168.1.100)');
      return;
    }

    try {
      await saveFocStimSettings({
        ...focstimSettings,
        wifiIp,
      });
      Alert.alert('Success', 'WiFi IP address saved successfully');
    } catch (error: any) {
      Alert.alert('Error', `Failed to save settings: ${error.message}`);
    }
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Settings</Text>
      <View style={styles.separator} lightColor="#eee" darkColor="rgba(255,255,255,0.1)" />

      {/* WiFi Configuration Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>FOC-Stim WiFi Connection</Text>
        <Text style={styles.sectionDescription}>
          Configure the IP address of your FOC-Stim device on your local network.
        </Text>

        <View style={styles.settingContainer}>
          <Text style={styles.label}>Device IP Address</Text>
          <TextInput
            style={styles.input}
            value={wifiIp}
            onChangeText={setWifiIp}
            placeholder="192.168.1.100"
            keyboardType="numeric"
            autoCapitalize="none"
            autoCorrect={false}
          />
          <Text style={styles.hint}>
            Find your device's IP address in the FOC-Stim web interface or router settings.
          </Text>
        </View>

        {/* Save Button */}
        <Pressable
          onPress={handleSave}
          disabled={!hasChanges}
          style={({ pressed }) => [
            styles.saveButton,
            {
              opacity: pressed ? 0.8 : hasChanges ? 1 : 0.5,
            },
          ]}>
          <Text style={styles.saveButtonText}>Save Settings</Text>
        </Pressable>
      </View>

      {/* Info Section */}
      <View style={styles.infoSection}>
        <Text style={styles.infoTitle}>ℹ️ Connection Info</Text>
        <Text style={styles.infoText}>
          • Ensure your phone and FOC-Stim device are on the same WiFi network{'\n'}
          • The device must be powered on and connected to WiFi{'\n'}
          • Default port 8080 is used for communication
        </Text>
      </View>
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
    paddingBottom: 40,
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
  label: {
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 8,
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    backgroundColor: '#fff',
  },
  hint: {
    fontSize: 11,
    color: '#999',
    marginTop: 6,
    fontStyle: 'italic',
  },
  saveButton: {
    paddingVertical: 12,
    paddingHorizontal: 25,
    borderRadius: 8,
    backgroundColor: '#27ae60',
    alignItems: 'center',
  },
  saveButtonText: {
    color: '#fff',
    fontSize: 15,
    fontWeight: 'bold',
  },
  infoSection: {
    width: '100%',
    padding: 15,
    borderWidth: 1,
    borderColor: '#3498db',
    borderRadius: 8,
    backgroundColor: 'rgba(52, 152, 219, 0.05)',
  },
  infoTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  infoText: {
    fontSize: 12,
    color: '#666',
    lineHeight: 18,
  },
});
