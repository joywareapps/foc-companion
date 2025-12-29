import { StyleSheet, Pressable, ScrollView } from 'react-native';
import Slider from '@react-native-community/slider';
import DeviceConnection from '@/components/DeviceConnection';
import { View, Text } from '@/components/Themed';
import { useDeviceStore } from '@/store/deviceStore';
import Colors from '@/constants/Colors';

export default function TabControlScreen() {
  const { status, loopRunning, toggleLoop, deviceStatus, patternSpeed, setPatternSpeed } = useDeviceStore();
  const isConnected = status === 'CONNECTED';

  return (
    <ScrollView style={styles.scrollContainer} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>FOC Companion</Text>
      <View style={styles.separator} lightColor="#eee" darkColor="rgba(255,255,255,0.1)" />

      <DeviceConnection />

      {isConnected && (
        <>
          {/* Device Status Display - Compact */}
          {Object.keys(deviceStatus).length > 0 && (
            <View style={styles.statusContainer}>
              <Text style={styles.statusLine}>
                {deviceStatus.temperature !== undefined && `Temp: ${deviceStatus.temperature.toFixed(1)}°C`}
                {deviceStatus.temperature !== undefined && (deviceStatus.batteryVoltage !== undefined || deviceStatus.wallPowerPresent !== undefined) && ' | '}
                {deviceStatus.wallPowerPresent !== undefined && (deviceStatus.wallPowerPresent ? '🔌 ' : '🔋 ')}
                {deviceStatus.batteryVoltage !== undefined && `${deviceStatus.batteryVoltage.toFixed(2)}V`}
                {deviceStatus.batterySoc !== undefined && ` - ${(deviceStatus.batterySoc * 100).toFixed(0)}%`}
              </Text>
            </View>
          )}

          {/* Pattern Control */}
          <View style={styles.patternContainer}>
            <Text style={styles.subtitle}>Pattern Control</Text>
            <Pressable
              onPress={toggleLoop}
              style={({ pressed }) => [
                styles.loopButton,
                {
                  backgroundColor: loopRunning ? '#e67e22' : '#27ae60',
                  opacity: pressed ? 0.8 : 1
                },
              ]}>
              <Text style={styles.buttonText}>
                {loopRunning ? 'Stop Circle Pattern' : 'Start Circle Pattern'}
              </Text>
            </Pressable>

            {/* Pattern Speed Slider */}
            <View style={styles.speedContainer}>
              <View style={styles.speedHeader}>
                <Text style={styles.speedLabel}>Pattern Speed</Text>
                <Text style={styles.speedValue}>{patternSpeed.toFixed(1)} rad/s</Text>
              </View>
              <Slider
                style={styles.slider}
                minimumValue={0.1}
                maximumValue={5.0}
                step={0.1}
                value={patternSpeed}
                onValueChange={setPatternSpeed}
                minimumTrackTintColor="#3498db"
                maximumTrackTintColor="#bdc3c7"
              />
              <Text style={styles.rangeLabel}>Range: 0.1 to 5.0 rad/s</Text>
            </View>
          </View>
        </>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  scrollContainer: {
    flex: 1,
  },
  contentContainer: {
    alignItems: 'center',
    paddingTop: 20,
    paddingBottom: 40,
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
  },
  subtitle: {
    fontSize: 16,
    fontWeight: 'bold',
    marginBottom: 10,
    textAlign: 'center',
  },
  separator: {
    marginVertical: 15,
    height: 1,
    width: '80%',
  },
  statusContainer: {
    marginTop: 15,
    width: '90%',
    padding: 12,
    borderWidth: 1,
    borderColor: '#3498db',
    borderRadius: 8,
    backgroundColor: 'rgba(52, 152, 219, 0.05)',
  },
  statusLine: {
    fontSize: 14,
    fontWeight: '600',
    color: '#2c3e50',
    textAlign: 'center',
  },
  patternContainer: {
    marginTop: 20,
    marginBottom: 20,
    width: '90%',
    padding: 15,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
  },
  loopButton: {
    paddingVertical: 12,
    paddingHorizontal: 25,
    borderRadius: 8,
  },
  buttonText: {
    color: '#fff',
    fontSize: 15,
    fontWeight: 'bold',
    textAlign: 'center',
  },
  speedContainer: {
    marginTop: 20,
  },
  speedHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  speedLabel: {
    fontSize: 14,
    fontWeight: '600',
    color: '#2c3e50',
  },
  speedValue: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#3498db',
  },
  slider: {
    width: '100%',
    height: 40,
  },
  rangeLabel: {
    fontSize: 12,
    color: '#7f8c8d',
    textAlign: 'center',
    marginTop: 4,
  },
});
