import { StyleSheet, Pressable } from 'react-native';
import DeviceConnection from '@/components/DeviceConnection';
import { View, Text } from '@/components/Themed';
import { useDeviceStore } from '@/store/deviceStore';
import Colors from '@/constants/Colors';

export default function TabControlScreen() {
  const { status, loopRunning, toggleLoop } = useDeviceStore();
  const isConnected = status === 'CONNECTED';

  return (
    <View style={styles.container}>
      <Text style={styles.title}>FOC Companion</Text>
      <View style={styles.separator} lightColor="#eee" darkColor="rgba(255,255,255,0.1)" />
      
      <DeviceConnection />

      {isConnected && (
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
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    paddingTop: 40,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
  },
  subtitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 15,
    textAlign: 'center',
  },
  separator: {
    marginVertical: 20,
    height: 1,
    width: '80%',
  },
  patternContainer: {
    marginTop: 30,
    width: '90%',
    padding: 20,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 10,
  },
  loopButton: {
    paddingVertical: 15,
    paddingHorizontal: 30,
    borderRadius: 8,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
    textAlign: 'center',
  },
});
