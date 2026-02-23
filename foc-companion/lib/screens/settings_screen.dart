import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foc_companion/providers/settings_provider.dart';
import 'package:foc_companion/providers/device_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _ipController.text = settings.focStim.wifiIp;
    _portController.text = settings.focStim.wifiPort.toString();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final device = Provider.of<DeviceProvider>(context);
    final d = settings.device;

    final isConnected = device.api.isConnected;
    final isPlaying = device.isLoopRunning;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // ── Connection ──────────────────────────────
        const Text("Connection",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
        const SizedBox(height: 8),
        if (isConnected)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "Disconnect to change connection settings.",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),
        TextField(
          controller: _ipController,
          enabled: !isConnected,
          decoration: const InputDecoration(
            labelText: "FOC-Stim Device IP",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.wifi),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _portController,
          enabled: !isConnected,
          decoration: const InputDecoration(
            labelText: "FOC-Stim Device Port",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.router),
          ),
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 24),

        // ── Safety Limits ────────────────────────────
        const Text("Safety Limits",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
        const SizedBox(height: 8),
        if (isPlaying)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "Stop playback to change safety limits.",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),

        _buildSlider(
          label: "Min Carrier Frequency (Hz)",
          value: d.minFrequency,
          min: 100,
          max: 2000,
          decimals: 0,
          enabled: !isPlaying,
          onChanged: (v) => setState(() => d.minFrequency = v),
        ),
        _buildSlider(
          label: "Max Carrier Frequency (Hz)",
          value: d.maxFrequency,
          min: 100,
          max: 2000,
          decimals: 0,
          enabled: !isPlaying,
          onChanged: (v) => setState(() => d.maxFrequency = v),
        ),
        _buildSlider(
          label: "Max Amplitude (mA)",
          value: d.waveformAmplitude * 1000,
          min: 10,
          max: 150,
          decimals: 0,
          enabled: !isPlaying,
          onChanged: (v) => setState(() => d.waveformAmplitude = v / 1000),
        ),

        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isConnected
                    ? null
                    : () {
                        settings.resetConnectionAndLimits();
                        _ipController.text = settings.focStim.wifiIp;
                        _portController.text =
                            settings.focStim.wifiPort.toString();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Reset to defaults")),
                        );
                      },
                child: const Text("Reset"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: isConnected
                    ? null
                    : () async {
                        final ok = await settings.reloadConnectionAndLimits();
                        if (context.mounted) {
                          _ipController.text = settings.focStim.wifiIp;
                          _portController.text =
                              settings.focStim.wifiPort.toString();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ok ? "Settings loaded" : "Nothing saved yet"),
                            ),
                          );
                        }
                      },
                child: const Text("Load"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: isConnected
                    ? null
                    : () async {
                        settings.focStim.wifiIp = _ipController.text;
                        settings.focStim.wifiPort =
                            int.tryParse(_portController.text) ?? 55533;
                        await settings.saveSettings();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Settings Saved")),
                          );
                        }
                      },
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int decimals,
    required bool enabled,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: enabled
                    ? null
                    : TextStyle(
                        color: Theme.of(context).disabledColor)),
            Text(value.toStringAsFixed(decimals),
                style: enabled
                    ? null
                    : TextStyle(
                        color: Theme.of(context).disabledColor)),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
