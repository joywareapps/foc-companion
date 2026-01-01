import { StyleSheet, ScrollView, TextInput, Pressable, Alert, Switch, Modal } from 'react-native';
import { useState, useEffect } from 'react';
import { Text, View } from '@/components/Themed';
import { useDeviceStore } from '@/store/deviceStore';
import { syncedPlayback } from '@/core/SyncedPlayback';
import { hereSphereService } from '@/services/HereSphereService';
import { webdavService } from '@/services/WebDAVService';
import type { FunscriptLocation } from '@/types/settings';

export default function TabMediaSyncScreen() {
  const { mediaSyncSettings, saveMediaSyncSettings, status: deviceStatus } = useDeviceStore();
  const isDeviceConnected = deviceStatus === 'CONNECTED';

  // HereSphere settings
  const [hereSphereEnabled, setHereSphereEnabled] = useState(mediaSyncSettings.hereSphereEnabled);
  const [hereSphereIp, setHereSphereIp] = useState(mediaSyncSettings.hereSphereIp);
  const [hereSpherePort, setHereSpherePort] = useState(mediaSyncSettings.hereSpherePort.toString());

  // Funscript locations settings
  const [funscriptLocations, setFunscriptLocations] = useState(
    mediaSyncSettings.funscriptLocations || []
  );

  const [hasChanges, setHasChanges] = useState(false);

  // Location editor state
  const [showLocationEditor, setShowLocationEditor] = useState(false);
  const [editingLocation, setEditingLocation] = useState<FunscriptLocation | null>(null);
  const [locationName, setLocationName] = useState('');
  const [locationType, setLocationType] = useState<'webdav' | 'local'>('webdav');
  const [locationEnabled, setLocationEnabled] = useState(true);
  const [webdavUrl, setWebdavUrl] = useState('');
  const [webdavUsername, setWebdavUsername] = useState('');
  const [webdavPassword, setWebdavPassword] = useState('');
  const [localPath, setLocalPath] = useState('');

  // Playback state
  const [isPlaying, setIsPlaying] = useState(false);
  const [playbackStatus, setPlaybackStatus] = useState('');
  const [detailedStatus, setDetailedStatus] = useState<any>(null);

  // Update local state when store settings change
  useEffect(() => {
    setHereSphereEnabled(mediaSyncSettings.hereSphereEnabled);
    setHereSphereIp(mediaSyncSettings.hereSphereIp);
    setHereSpherePort(mediaSyncSettings.hereSpherePort.toString());
    setFunscriptLocations(mediaSyncSettings.funscriptLocations || []);
    setHasChanges(false);
  }, [mediaSyncSettings]);

  // Poll playback status when playing
  useEffect(() => {
    if (!isPlaying) {
      setDetailedStatus(null);
      return;
    }

    const interval = setInterval(() => {
      const status = syncedPlayback.status;
      setDetailedStatus(status);
    }, 100); // Update 10 times per second for smooth display

    return () => clearInterval(interval);
  }, [isPlaying]);

  // Check for changes
  useEffect(() => {
    const savedLocations = mediaSyncSettings.funscriptLocations || [];
    const locationsChanged = JSON.stringify(funscriptLocations) !== JSON.stringify(savedLocations);

    const changed =
      hereSphereEnabled !== mediaSyncSettings.hereSphereEnabled ||
      hereSphereIp !== mediaSyncSettings.hereSphereIp ||
      hereSpherePort !== mediaSyncSettings.hereSpherePort.toString() ||
      locationsChanged;
    setHasChanges(changed);
  }, [
    hereSphereEnabled,
    hereSphereIp,
    hereSpherePort,
    funscriptLocations,
    mediaSyncSettings,
  ]);

  const handleTestConnection = async () => {
    if (!hereSphereIp || !hereSpherePort) {
      Alert.alert('Configuration Required', 'Please configure HereSphere IP and port first');
      return;
    }

    const port = parseInt(hereSpherePort);
    if (isNaN(port)) {
      Alert.alert('Invalid Port', 'Please enter a valid port number');
      return;
    }

    try {
      setPlaybackStatus('Testing connection...');
      hereSphereService.configure(hereSphereIp, port);
      const connected = await hereSphereService.testConnection();

      if (connected) {
        Alert.alert(
          'Success',
          'Connected to HereSphere player via TCP socket.\n\n' +
          'Connection established successfully!'
        );
        setPlaybackStatus('Connection test passed');
      } else {
        Alert.alert(
          'Connection Failed',
          'Cannot connect to HereSphere player.\n\n' +
          'Check:\n' +
          '• HereSphere is running\n' +
          '• IP and port are correct\n' +
          '• Both devices on same network\n' +
          '• App has been rebuilt (required after config changes)'
        );
        setPlaybackStatus('Connection test failed');
      }
    } catch (error: any) {
      Alert.alert('Connection Error', error.message);
      setPlaybackStatus(`Connection error: ${error.message}`);
    }
  };

  const handleLoadFunscript = () => {
    if (!funscriptJson.trim()) {
      Alert.alert('Error', 'Please paste funscript JSON data');
      return;
    }

    try {
      syncedPlayback.loadFunscript(funscriptJson);
      Alert.alert('Success', 'Funscript loaded successfully');
      setPlaybackStatus('Funscript loaded');
    } catch (error: any) {
      Alert.alert('Error', `Failed to load funscript: ${error.message}`);
    }
  };

  const handleTogglePlayback = async () => {
    if (!isDeviceConnected) {
      Alert.alert('Device Not Connected', 'Please connect to FOC-Stim device first (use Control tab)');
      return;
    }

    if (!hereSphereIp || !hereSpherePort) {
      Alert.alert('Configuration Required', 'Please configure HereSphere settings');
      return;
    }

    const enabledLocations = funscriptLocations.filter(l => l.enabled);
    if (enabledLocations.length === 0) {
      Alert.alert(
        'No Funscript Locations',
        'Please configure at least one location where funscript files are located.\n\n' +
        'Funscripts will be automatically loaded when you play a video in HereSphere.'
      );
      return;
    }

    const port = parseInt(hereSpherePort);

    try {
      if (isPlaying) {
        // Stop playback
        await syncedPlayback.stop();
        setIsPlaying(false);
        setPlaybackStatus('Stopped');
        Alert.alert('Stopped', 'Synced playback stopped');
      } else {
        // Start playback
        setPlaybackStatus('Starting...');
        await syncedPlayback.start(hereSphereIp, port, enabledLocations);
        setIsPlaying(true);
        setPlaybackStatus('Ready - Play a video in HereSphere');
        Alert.alert(
          'Started',
          'Synced playback started.\n\n' +
          'Funscripts will automatically load when you play a video in HereSphere.'
        );
      }
    } catch (error: any) {
      Alert.alert('Error', `Playback error: ${error.message}`);
      setIsPlaying(false);
      setPlaybackStatus(`Error: ${error.message}`);
    }
  };

  const handleAddLocation = () => {
    setEditingLocation(null);
    setLocationName('');
    setLocationType('webdav');
    setLocationEnabled(true);
    setWebdavUrl('');
    setWebdavUsername('');
    setWebdavPassword('');
    setLocalPath('');
    setShowLocationEditor(true);
  };

  const handleEditLocation = (location: FunscriptLocation) => {
    setEditingLocation(location);
    setLocationName(location.name);
    setLocationType(location.type);
    setLocationEnabled(location.enabled);
    setWebdavUrl(location.webdavUrl || '');
    setWebdavUsername(location.webdavUsername || '');
    setWebdavPassword(location.webdavPassword || '');
    setLocalPath(location.localPath || '');
    setShowLocationEditor(true);
  };

  const handleDeleteLocation = (locationId: string) => {
    Alert.alert(
      'Delete Location',
      'Are you sure you want to delete this location?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: () => {
            setFunscriptLocations(funscriptLocations.filter(l => l.id !== locationId));
          },
        },
      ]
    );
  };

  const handleTestWebDAVConnection = async () => {
    if (!webdavUrl) {
      Alert.alert('Missing URL', 'Please enter WebDAV URL');
      return;
    }

    try {
      const testLocation: FunscriptLocation = {
        id: 'test',
        name: 'Test',
        type: 'webdav',
        enabled: true,
        webdavUrl,
        webdavUsername,
        webdavPassword,
      };

      const success = await webdavService.testConnection(testLocation);
      if (success) {
        Alert.alert('Success', 'WebDAV connection successful!');
      } else {
        Alert.alert('Failed', 'Could not connect to WebDAV server');
      }
    } catch (error: any) {
      Alert.alert('Error', `Connection failed: ${error.message}`);
    }
  };

  const handleSaveLocation = () => {
    // Validate
    if (!locationName.trim()) {
      Alert.alert('Missing Name', 'Please enter a location name');
      return;
    }

    if (locationType === 'webdav') {
      if (!webdavUrl.trim()) {
        Alert.alert('Missing URL', 'Please enter WebDAV URL');
        return;
      }
    } else {
      if (!localPath.trim()) {
        Alert.alert('Missing Path', 'Please enter local directory path');
        return;
      }
    }

    const newLocation: FunscriptLocation = {
      id: editingLocation?.id || `location-${Date.now()}`,
      name: locationName,
      type: locationType,
      enabled: locationEnabled,
      ...(locationType === 'webdav' ? {
        webdavUrl,
        webdavUsername,
        webdavPassword,
      } : {
        localPath,
      }),
    };

    if (editingLocation) {
      // Update existing
      setFunscriptLocations(funscriptLocations.map(l =>
        l.id === editingLocation.id ? newLocation : l
      ));
    } else {
      // Add new
      setFunscriptLocations([...funscriptLocations, newLocation]);
    }

    setShowLocationEditor(false);
  };

  const handleSave = async () => {
    // Validate IP address if HereSphere is enabled
    if (hereSphereEnabled && hereSphereIp) {
      const ipPattern = /^(\d{1,3}\.){3}\d{1,3}$/;
      if (!ipPattern.test(hereSphereIp)) {
        Alert.alert('Invalid IP Address', 'Please enter a valid IP address for HereSphere (e.g., 192.168.1.100)');
        return;
      }
    }

    // Validate port
    const port = parseInt(hereSpherePort);
    if (hereSphereEnabled && (isNaN(port) || port < 1 || port > 65535)) {
      Alert.alert('Invalid Port', 'Please enter a valid port number (1-65535)');
      return;
    }

    try {
      await saveMediaSyncSettings({
        hereSphereEnabled,
        hereSphereIp,
        hereSpherePort: port,
        funscriptLocations,
      });
      Alert.alert('Success', 'Media sync settings saved successfully');
    } catch (error: any) {
      Alert.alert('Error', `Failed to save settings: ${error.message}`);
    }
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <Text style={styles.title}>Media Sync</Text>
      <View style={styles.separator} lightColor="#eee" darkColor="rgba(255,255,255,0.1)" />

      {/* HereSphere Configuration Section */}
      <View style={styles.section}>
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>HereSphere Player</Text>
          <Switch
            value={hereSphereEnabled}
            onValueChange={setHereSphereEnabled}
            trackColor={{ false: '#767577', true: '#81b0ff' }}
            thumbColor={hereSphereEnabled ? '#3498db' : '#f4f3f4'}
          />
        </View>
        <Text style={styles.sectionDescription}>
          Configure connection to HereSphere video player for synchronized playback.
        </Text>

        {hereSphereEnabled && (
          <>
            <View style={styles.settingContainer}>
              <Text style={styles.label}>Player IP Address</Text>
              <TextInput
                style={styles.input}
                value={hereSphereIp}
                onChangeText={setHereSphereIp}
                placeholder="192.168.1.100"
                keyboardType="numeric"
                autoCapitalize="none"
                autoCorrect={false}
              />
              <Text style={styles.hint}>
                IP address of the device running HereSphere player
              </Text>
            </View>

            <View style={styles.settingContainer}>
              <Text style={styles.label}>Player Port</Text>
              <TextInput
                style={styles.input}
                value={hereSpherePort}
                onChangeText={setHereSpherePort}
                placeholder="23554"
                keyboardType="numeric"
                autoCapitalize="none"
                autoCorrect={false}
              />
              <Text style={styles.hint}>
                Default HereSphere port is 23554
              </Text>
            </View>
          </>
        )}
      </View>

      {/* Funscript Locations Configuration Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Funscript Locations</Text>
        <Text style={styles.sectionDescription}>
          Configure locations (WebDAV shares or local directories) where funscript files are located. Funscripts will be automatically loaded based on video filename.
        </Text>

        {funscriptLocations.length === 0 ? (
          <View style={styles.emptyState}>
            <Text style={styles.emptyStateText}>
              No locations configured yet.{'\n'}
              Click "Add Location" below to get started.
            </Text>
          </View>
        ) : (
          <View style={styles.locationsList}>
            {funscriptLocations.map((location) => (
              <View key={location.id} style={styles.locationItem}>
                <View style={styles.locationHeader}>
                  <Text style={styles.locationName}>
                    {location.enabled ? '✓' : '○'} {location.name}
                  </Text>
                  <View style={styles.locationActions}>
                    <Pressable
                      onPress={() => handleEditLocation(location)}
                      style={styles.iconButton}>
                      <Text style={styles.iconButtonText}>✎</Text>
                    </Pressable>
                    <Pressable
                      onPress={() => handleDeleteLocation(location.id)}
                      style={styles.iconButton}>
                      <Text style={styles.iconButtonText}>✕</Text>
                    </Pressable>
                  </View>
                </View>
                <Text style={styles.locationDetails}>
                  {location.type === 'webdav'
                    ? `WebDAV: ${location.webdavUrl}`
                    : `Local: ${location.localPath}`}
                </Text>
              </View>
            ))}
          </View>
        )}

        <Pressable
          onPress={handleAddLocation}
          style={({ pressed }) => [
            styles.actionButton,
            styles.addButton,
            { opacity: pressed ? 0.8 : 1 },
          ]}>
          <Text style={styles.actionButtonText}>+ Add Location</Text>
        </Pressable>

        <Text style={styles.hint}>
          Supports: video.funscript, video.alpha.funscript, video.beta.funscript, etc.
        </Text>
      </View>

      {/* Location Editor Modal */}
      <Modal
        visible={showLocationEditor}
        animationType="slide"
        transparent={true}
        onRequestClose={() => setShowLocationEditor(false)}>
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <ScrollView>
              <Text style={styles.modalTitle}>
                {editingLocation ? 'Edit Location' : 'Add Location'}
              </Text>

              <View style={styles.settingContainer}>
                <Text style={styles.label}>Location Name</Text>
                <TextInput
                  style={styles.input}
                  value={locationName}
                  onChangeText={setLocationName}
                  placeholder="My NAS"
                  autoCapitalize="words"
                />
              </View>

              <View style={styles.settingContainer}>
                <View style={styles.sectionHeader}>
                  <Text style={styles.label}>Type</Text>
                  <View style={styles.typeSelector}>
                    <Pressable
                      onPress={() => setLocationType('webdav')}
                      style={[
                        styles.typeButton,
                        locationType === 'webdav' && styles.typeButtonActive,
                      ]}>
                      <Text style={[
                        styles.typeButtonText,
                        locationType === 'webdav' && styles.typeButtonTextActive,
                      ]}>WebDAV</Text>
                    </Pressable>
                    <Pressable
                      onPress={() => setLocationType('local')}
                      style={[
                        styles.typeButton,
                        locationType === 'local' && styles.typeButtonActive,
                      ]}>
                      <Text style={[
                        styles.typeButtonText,
                        locationType === 'local' && styles.typeButtonTextActive,
                      ]}>Local</Text>
                    </Pressable>
                  </View>
                </View>
              </View>

              <View style={styles.settingContainer}>
                <View style={styles.sectionHeader}>
                  <Text style={styles.label}>Enabled</Text>
                  <Switch
                    value={locationEnabled}
                    onValueChange={setLocationEnabled}
                    trackColor={{ false: '#767577', true: '#81b0ff' }}
                    thumbColor={locationEnabled ? '#3498db' : '#f4f3f4'}
                  />
                </View>
              </View>

              {locationType === 'webdav' ? (
                <>
                  <View style={styles.settingContainer}>
                    <Text style={styles.label}>WebDAV URL</Text>
                    <TextInput
                      style={styles.input}
                      value={webdavUrl}
                      onChangeText={setWebdavUrl}
                      placeholder="http://192.168.1.10/webdav/movies"
                      keyboardType="url"
                      autoCapitalize="none"
                      autoCorrect={false}
                    />
                    <Text style={styles.hint}>
                      Full URL to WebDAV directory containing funscripts
                    </Text>
                  </View>

                  <View style={styles.settingContainer}>
                    <Text style={styles.label}>Username (optional)</Text>
                    <TextInput
                      style={styles.input}
                      value={webdavUsername}
                      onChangeText={setWebdavUsername}
                      placeholder="username"
                      autoCapitalize="none"
                      autoCorrect={false}
                    />
                  </View>

                  <View style={styles.settingContainer}>
                    <Text style={styles.label}>Password (optional)</Text>
                    <TextInput
                      style={styles.input}
                      value={webdavPassword}
                      onChangeText={setWebdavPassword}
                      placeholder="password"
                      secureTextEntry
                      autoCapitalize="none"
                      autoCorrect={false}
                    />
                  </View>

                  <Pressable
                    onPress={handleTestWebDAVConnection}
                    style={({ pressed }) => [
                      styles.actionButton,
                      styles.testButton,
                      { opacity: pressed ? 0.8 : 1 },
                    ]}>
                    <Text style={styles.actionButtonText}>Test Connection</Text>
                  </Pressable>
                </>
              ) : (
                <View style={styles.settingContainer}>
                  <Text style={styles.label}>Local Directory Path</Text>
                  <TextInput
                    style={styles.input}
                    value={localPath}
                    onChangeText={setLocalPath}
                    placeholder="/storage/emulated/0/Download"
                    autoCapitalize="none"
                    autoCorrect={false}
                  />
                  <Text style={styles.hint}>
                    Full path to local directory containing funscripts
                  </Text>
                </View>
              )}

              <View style={styles.modalButtons}>
                <Pressable
                  onPress={() => setShowLocationEditor(false)}
                  style={({ pressed }) => [
                    styles.modalButton,
                    styles.cancelButton,
                    { opacity: pressed ? 0.8 : 1 },
                  ]}>
                  <Text style={styles.cancelButtonText}>Cancel</Text>
                </Pressable>
                <Pressable
                  onPress={handleSaveLocation}
                  style={({ pressed }) => [
                    styles.modalButton,
                    styles.saveLocationButton,
                    { opacity: pressed ? 0.8 : 1 },
                  ]}>
                  <Text style={styles.actionButtonText}>
                    {editingLocation ? 'Update' : 'Add'}
                  </Text>
                </Pressable>
              </View>
            </ScrollView>
          </View>
        </View>
      </Modal>

      {/* Playback Control Section */}
      {hereSphereEnabled && (
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Synced Playback</Text>
          <Text style={styles.sectionDescription}>
            Connect to HereSphere and start synchronized playback. Funscripts will load automatically when you play a video.
          </Text>

          {/* Test Connection Button */}
          <Pressable
            onPress={handleTestConnection}
            style={({ pressed }) => [
              styles.actionButton,
              styles.testButton,
              { opacity: pressed ? 0.8 : 1 },
            ]}>
            <Text style={styles.actionButtonText}>Test HereSphere Connection</Text>
          </Pressable>

          {/* Start/Stop Playback Button */}
          <Pressable
            onPress={handleTogglePlayback}
            disabled={!isDeviceConnected}
            style={({ pressed }) => [
              styles.actionButton,
              isPlaying ? styles.stopButton : styles.startButton,
              {
                opacity: pressed ? 0.8 : isDeviceConnected ? 1 : 0.5,
              },
            ]}>
            <Text style={styles.actionButtonText}>
              {isPlaying ? 'Stop Synced Playback' : 'Start Synced Playback'}
            </Text>
          </Pressable>

          {/* Playback Status */}
          {playbackStatus && (
            <View style={styles.statusBox}>
              <Text style={styles.statusText}>Status: {playbackStatus}</Text>
            </View>
          )}

          {/* Detailed Playback Status */}
          {detailedStatus && detailedStatus.hasFunscript && (
            <View style={styles.detailedStatusBox}>
              <Text style={styles.detailedStatusTitle}>Playback Details</Text>

              <View style={styles.statusRow}>
                <Text style={styles.statusLabel}>Video:</Text>
                <Text style={styles.statusValue}>{detailedStatus.videoIdentifier || 'None'}</Text>
              </View>

              {detailedStatus.funscriptCollection && (
                <View style={styles.statusRow}>
                  <Text style={styles.statusLabel}>Funscripts:</Text>
                  <View style={styles.funscriptList}>
                    {detailedStatus.funscriptCollection.funscripts.map((fs: any, idx: number) => (
                      <Text key={idx} style={styles.funscriptItem}>
                        {fs.channel === 'default' ? '• ' : `• ${fs.channel}: `}{fs.filename}
                      </Text>
                    ))}
                  </View>
                </View>
              )}

              <View style={styles.statusRow}>
                <Text style={styles.statusLabel}>Time:</Text>
                <Text style={styles.statusValue}>
                  {Math.floor(detailedStatus.currentTimeMs / 60000)}:{String(Math.floor((detailedStatus.currentTimeMs % 60000) / 1000)).padStart(2, '0')}
                </Text>
              </View>

              <View style={styles.statusRow}>
                <Text style={styles.statusLabel}>Position:</Text>
                <Text style={styles.statusValue}>
                  {detailedStatus.currentFunscriptPos.toFixed(1)} / 100
                </Text>
              </View>

              <View style={styles.statusRow}>
                <Text style={styles.statusLabel}>Device Pos:</Text>
                <Text style={styles.statusValue}>
                  {detailedStatus.currentDevicePos.toFixed(3)} ({detailedStatus.currentDevicePos >= 0 ? '+' : ''}{(detailedStatus.currentDevicePos * 100).toFixed(1)}%)
                </Text>
              </View>

              <View style={styles.statusRow}>
                <Text style={styles.statusLabel}>Actions:</Text>
                <Text style={styles.statusValue}>{detailedStatus.actionCount}</Text>
              </View>
            </View>
          )}

          {!isDeviceConnected && (
            <View style={styles.warningBox}>
              <Text style={styles.warningText}>
                ⚠️ Device not connected. Use Control tab to connect first.
              </Text>
            </View>
          )}
        </View>
      )}

      {/* Save Settings Button */}
      <Pressable
        onPress={handleSave}
        disabled={!hasChanges}
        style={({ pressed }) => [
          styles.saveButton,
          {
            opacity: pressed ? 0.8 : hasChanges ? 1 : 0.5,
          },
        ]}>
        <Text style={styles.saveButtonText}>
          {!hasChanges ? 'No Changes' : 'Save Settings'}
        </Text>
      </Pressable>

      {/* Info Section */}
      <View style={styles.infoSection}>
        <Text style={styles.infoTitle}>ℹ️ Media Sync Info</Text>
        <Text style={styles.infoText}>
          • HereSphere integration allows synchronized playback with haptic scripts{'\n'}
          • Funscripts are automatically loaded based on video filename{'\n'}
          • Supports multi-channel funscripts (alpha, beta, volume, etc.){'\n'}
          • Example: video.mp4 → video.funscript, video.alpha.funscript{'\n'}
          • Ensure proper network connectivity for reliable synchronization
        </Text>
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
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 5,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
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
  funscriptInput: {
    minHeight: 100,
    textAlignVertical: 'top',
    fontFamily: 'monospace',
    fontSize: 12,
  },
  hint: {
    fontSize: 11,
    color: '#999',
    marginTop: 6,
    fontStyle: 'italic',
  },
  actionButton: {
    width: '100%',
    paddingVertical: 12,
    paddingHorizontal: 25,
    borderRadius: 8,
    alignItems: 'center',
    marginBottom: 10,
  },
  actionButtonText: {
    color: '#fff',
    fontSize: 15,
    fontWeight: 'bold',
  },
  loadButton: {
    backgroundColor: '#3498db',
  },
  testButton: {
    backgroundColor: '#9b59b6',
  },
  startButton: {
    backgroundColor: '#27ae60',
  },
  stopButton: {
    backgroundColor: '#e74c3c',
  },
  saveButton: {
    width: '100%',
    paddingVertical: 12,
    paddingHorizontal: 25,
    borderRadius: 8,
    backgroundColor: '#27ae60',
    alignItems: 'center',
    marginBottom: 20,
  },
  saveButtonText: {
    color: '#fff',
    fontSize: 15,
    fontWeight: 'bold',
  },
  statusBox: {
    padding: 12,
    backgroundColor: 'rgba(52, 152, 219, 0.1)',
    borderRadius: 6,
    borderWidth: 1,
    borderColor: '#3498db',
    marginTop: 10,
  },
  statusText: {
    fontSize: 13,
    color: '#2c3e50',
    textAlign: 'center',
    fontWeight: '600',
  },
  warningBox: {
    padding: 12,
    backgroundColor: 'rgba(241, 196, 15, 0.1)',
    borderRadius: 6,
    borderWidth: 1,
    borderColor: '#f1c40f',
    marginTop: 10,
  },
  warningText: {
    fontSize: 12,
    color: '#f39c12',
    textAlign: 'center',
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
  bottomPadding: {
    height: 40,
  },
  emptyState: {
    padding: 20,
    alignItems: 'center',
    backgroundColor: 'rgba(150, 150, 150, 0.1)',
    borderRadius: 6,
    marginBottom: 10,
  },
  emptyStateText: {
    fontSize: 13,
    color: '#999',
    textAlign: 'center',
  },
  locationsList: {
    marginBottom: 10,
  },
  locationItem: {
    padding: 12,
    backgroundColor: 'rgba(255, 255, 255, 0.05)',
    borderRadius: 6,
    borderWidth: 1,
    borderColor: '#ddd',
    marginBottom: 8,
  },
  locationName: {
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 4,
  },
  locationDetails: {
    fontSize: 12,
    color: '#666',
    fontFamily: 'monospace',
  },
  locationHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 4,
  },
  locationActions: {
    flexDirection: 'row',
    gap: 8,
  },
  iconButton: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: 'rgba(0, 0, 0, 0.05)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  iconButtonText: {
    fontSize: 18,
    color: '#666',
  },
  addButton: {
    backgroundColor: '#3498db',
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  modalContent: {
    backgroundColor: '#1a1a1a',
    borderRadius: 12,
    padding: 20,
    width: '100%',
    maxWidth: 500,
    maxHeight: '80%',
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 20,
    textAlign: 'center',
    color: '#fff',
  },
  typeSelector: {
    flexDirection: 'row',
    gap: 10,
  },
  typeButton: {
    paddingVertical: 8,
    paddingHorizontal: 16,
    borderRadius: 6,
    borderWidth: 1,
    borderColor: '#444',
    backgroundColor: '#2c2c2c',
  },
  typeButtonActive: {
    backgroundColor: '#3498db',
    borderColor: '#3498db',
  },
  typeButtonText: {
    fontSize: 14,
    color: '#aaa',
  },
  typeButtonTextActive: {
    color: '#fff',
    fontWeight: '600',
  },
  modalButtons: {
    flexDirection: 'row',
    gap: 10,
    marginTop: 20,
  },
  modalButton: {
    flex: 1,
    paddingVertical: 12,
    paddingHorizontal: 20,
    borderRadius: 8,
    alignItems: 'center',
  },
  cancelButton: {
    backgroundColor: '#444',
  },
  cancelButtonText: {
    color: '#fff',
    fontSize: 15,
    fontWeight: 'bold',
  },
  saveLocationButton: {
    backgroundColor: '#27ae60',
  },
  detailedStatusBox: {
    padding: 15,
    backgroundColor: 'rgba(39, 174, 96, 0.1)',
    borderRadius: 6,
    borderWidth: 1,
    borderColor: '#27ae60',
    marginTop: 10,
  },
  detailedStatusTitle: {
    fontSize: 15,
    fontWeight: 'bold',
    marginBottom: 10,
    color: '#27ae60',
  },
  statusRow: {
    flexDirection: 'row',
    marginBottom: 6,
    alignItems: 'flex-start',
  },
  statusLabel: {
    fontSize: 12,
    fontWeight: '600',
    width: 90,
    color: '#555',
  },
  statusValue: {
    fontSize: 12,
    flex: 1,
    color: '#333',
    fontFamily: 'monospace',
  },
  funscriptList: {
    flex: 1,
  },
  funscriptItem: {
    fontSize: 11,
    color: '#666',
    marginBottom: 2,
    fontFamily: 'monospace',
  },
});
