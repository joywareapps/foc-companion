import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restim_flutter/providers/device_provider.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final device = Provider.of<DeviceProvider>(context);

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
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: device.api.isConnected ? device.disconnect : device.connect,
                    style: FilledButton.styleFrom(
                      backgroundColor: device.api.isConnected ? Colors.red : null,
                    ),
                    child: Text(device.api.isConnected ? 'Disconnect' : 'Connect'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Status Card
          if (device.api.isConnected) ...[
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
                      label: Text(device.isLoopRunning ? "Stop Circle Pattern" : "Start Circle Pattern"),
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
