import React from 'react';
import { StyleSheet, Pressable, ActivityIndicator, TextInput } from 'react-native';
import { Text, View } from '@/components/Themed';
import FontAwesome from '@expo/vector-icons/FontAwesome';
import Colors from '@/constants/Colors';
import { useDeviceStore } from '@/store/deviceStore';

export default function DeviceConnection() {
  const { 
    status, 
    ipAddress,
    error,
    setIpAddress,
    connect, 
    disconnect 
  } = useDeviceStore();

  const isConnecting = status === 'CONNECTING';
  const isConnected = status === 'CONNECTED';

  const handleConnectPress = () => {
    if (isConnected) {
      disconnect();
    } else {
      connect();
    }
  };

  return (
    <View style={styles.container}>
      {/* Status Display */}
      <View style={styles.statusRow}>
        {isConnecting 
          ? <ActivityIndicator color={Colors.light.tint} />
          : <FontAwesome name={isConnected ? 'wifi' : 'warning'} size={20} color={isConnected ? Colors.light.tint : Colors.dark.tabIconDefault} />
        }
        <Text style={styles.statusText}>{isConnected ? `Connected to ${ipAddress}` : 'Disconnected'}</Text>
      </View>

      {/* Error Message */}
      {error && <Text style={styles.errorText}>{error}</Text>}

      {/* Connection Controls */}
      {!isConnected && (
        <View style={styles.tcpContainer}>
          <Text style={styles.label}>Device IP Address:</Text>
          <TextInput
            style={styles.input}
            value={ipAddress}
            onChangeText={setIpAddress}
            placeholder="192.168.1.xxx"
            keyboardType="numeric"
          />
        </View>
      )}

      {/* Connect/Disconnect Button */}
      <Pressable
        onPress={handleConnectPress}
        disabled={isConnecting}
        style={({ pressed }) => [
          styles.button,
          { 
            backgroundColor: isConnected ? '#e74c3c' : Colors.light.tint,
            opacity: (pressed || isConnecting) ? 0.7 : 1
          },
        ]}>
        <Text style={styles.buttonText}>
          {isConnected ? 'Disconnect' : 'Connect'}
        </Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    padding: 20,
    width: '90%',
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 10,
    backgroundColor: 'transparent',
    alignSelf: 'center',
    marginTop: 20,
  },
  statusRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 10,
  },
  statusText: {
    fontSize: 18,
    fontWeight: 'bold',
    marginLeft: 10,
  },
  errorText: {
    color: '#e74c3c',
    marginBottom: 10,
    textAlign: 'center'
  },
  tcpContainer: {
    width: '100%',
    marginBottom: 15,
  },
  label: {
    fontSize: 14,
    marginBottom: 5,
    color: '#666',
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 10,
    fontSize: 16,
    backgroundColor: '#fff',
  },
  button: {
    paddingVertical: 12,
    paddingHorizontal: 35,
    borderRadius: 8,
    marginTop: 10,
    width: '100%',
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
    textAlign: 'center'
  },
});
