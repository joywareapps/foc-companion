import React from 'react';
import { StyleSheet, Pressable, ActivityIndicator } from 'react-native';
import { Text, View } from '@/components/Themed';
import FontAwesome from '@expo/vector-icons/FontAwesome';
import Colors from '@/constants/Colors';
import { useDeviceStore } from '@/store/deviceStore';
import { useRouter } from 'expo-router';

export default function DeviceConnection() {
  const {
    status,
    ipAddress,
    error,
    connect,
    disconnect
  } = useDeviceStore();

  const router = useRouter();

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

      {/* IP Address Display (when not connected) */}
      {!isConnected && (
        <Text style={styles.ipText}>
          IP: {ipAddress || 'Not configured'}
          {!ipAddress && (
            <Text style={styles.settingsHint}> (Set in Settings tab)</Text>
          )}
        </Text>
      )}

      {/* Connect/Disconnect Button */}
      <Pressable
        onPress={handleConnectPress}
        disabled={isConnecting || (!isConnected && !ipAddress)}
        style={({ pressed }) => [
          styles.button,
          {
            backgroundColor: isConnected ? '#e74c3c' : Colors.light.tint,
            opacity: (pressed || isConnecting || (!isConnected && !ipAddress)) ? 0.7 : 1
          },
        ]}>
        <Text style={styles.buttonText}>
          {isConnected ? 'Disconnect' : 'Connect'}
        </Text>
      </Pressable>

      {/* Settings Link (when not connected and no IP) */}
      {!isConnected && !ipAddress && (
        <Pressable
          onPress={() => router.push('/settings')}
          style={styles.settingsLink}>
          <FontAwesome name="cog" size={14} color={Colors.light.tint} />
          <Text style={styles.settingsLinkText}>Configure IP in Settings</Text>
        </Pressable>
      )}
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
  ipText: {
    fontSize: 14,
    color: '#666',
    marginBottom: 10,
    textAlign: 'center',
  },
  settingsHint: {
    fontSize: 12,
    color: '#999',
    fontStyle: 'italic',
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
  settingsLink: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 10,
    gap: 6,
  },
  settingsLinkText: {
    fontSize: 13,
    color: Colors.light.tint,
    textDecorationLine: 'underline',
  },
});
