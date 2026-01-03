import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restim_flutter/providers/settings_provider.dart';

class DeviceSettingsScreen extends StatefulWidget {
  const DeviceSettingsScreen({super.key});

  @override
  State<DeviceSettingsScreen> createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final d = settings.device;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text("Safety Limits", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        
        _buildSlider(
          label: "Min Carrier Frequency (Hz)",
          value: d.minFrequency,
          min: 100,
          max: 2000,
          onChanged: (v) => setState(() => d.minFrequency = v),
        ),

        _buildSlider(
          label: "Max Carrier Frequency (Hz)",
          value: d.maxFrequency,
          min: 100,
          max: 2000,
          onChanged: (v) => setState(() => d.maxFrequency = v),
        ),

        _buildSlider(
          label: "Amplitude (mA)",
          value: d.waveformAmplitude * 1000,
          min: 10,
          max: 150,
          onChanged: (v) => setState(() => d.waveformAmplitude = v / 1000),
        ),

        const Divider(height: 40),
        const Text("Calibration", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        _buildSlider(
          label: "Center",
          value: d.calibration3Center,
          min: -2,
          max: 2,
          onChanged: (v) => setState(() => d.calibration3Center = v),
        ),

        _buildSlider(
          label: "Up",
          value: d.calibration3Up,
          min: -2,
          max: 2,
          onChanged: (v) => setState(() => d.calibration3Up = v),
        ),

        _buildSlider(
          label: "Left",
          value: d.calibration3Left,
          min: -2,
          max: 2,
          onChanged: (v) => setState(() => d.calibration3Left = v),
        ),

        const SizedBox(height: 30),
        FilledButton(
          onPressed: () async {
            await settings.saveSettings();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Settings Saved")),
            );
          },
          child: const Text("Save Device Settings"),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value.toStringAsFixed(label.contains("Hz") || label.contains("mA") ? 0 : 2)),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
