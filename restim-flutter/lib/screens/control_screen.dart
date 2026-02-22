import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restim_flutter/models/settings_models.dart';
import 'package:restim_flutter/providers/device_provider.dart';
import 'package:restim_flutter/providers/settings_provider.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final device = Provider.of<DeviceProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final isConnected = device.api.isConnected;
    final is4Phase = device.deviceMode == DeviceMode.fourPhase;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Connection Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    device.connectionStatus,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  // Mode toggle — disabled when connected
                  SegmentedButton<DeviceMode>(
                    segments: const [
                      ButtonSegment(
                        value: DeviceMode.threePhase,
                        label: Text("3-Phase"),
                        icon: Icon(Icons.looks_3_outlined),
                      ),
                      ButtonSegment(
                        value: DeviceMode.fourPhase,
                        label: Text("4-Phase"),
                        icon: Icon(Icons.looks_4_outlined),
                      ),
                    ],
                    selected: {settings.device.deviceMode},
                    onSelectionChanged: isConnected
                        ? null
                        : (Set<DeviceMode> sel) {
                            settings.device.deviceMode = sel.first;
                            settings.saveSettings();
                          },
                  ),
                  if (isConnected)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "Disconnect to change mode",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: isConnected ? device.disconnect : device.connect,
                    style: FilledButton.styleFrom(
                      backgroundColor: isConnected ? Colors.red : null,
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: Text(isConnected ? 'Disconnect' : 'Connect'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Status Card
          if (isConnected) ...[
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Temp: ${device.temperature}"),
                    Text("Bat: ${device.batteryVoltage}"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Pattern Control
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text("Pattern Control", style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: device.toggleLoop,
                      icon: Icon(device.isLoopRunning ? Icons.stop : Icons.play_arrow),
                      label: Text(device.isLoopRunning
                          ? "Stop Pattern"
                          : is4Phase
                              ? "Start Cycle Pattern"
                              : "Start Circle Pattern"),
                      style: FilledButton.styleFrom(
                        backgroundColor: device.isLoopRunning ? Colors.orange : Colors.green,
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
