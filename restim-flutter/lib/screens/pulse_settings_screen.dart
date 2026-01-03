import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restim_flutter/providers/settings_provider.dart';

class PulseSettingsScreen extends StatefulWidget {
  const PulseSettingsScreen({super.key});

  @override
  State<PulseSettingsScreen> createState() => _PulseSettingsScreenState();
}

class _PulseSettingsScreenState extends State<PulseSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final p = settings.pulse;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text("Pulse Configuration", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        _buildSlider(
          label: "Carrier Frequency (Hz)",
          value: p.carrierFrequency,
          min: settings.device.minFrequency,
          max: settings.device.maxFrequency,
          onChanged: (v) => setState(() => p.carrierFrequency = v),
        ),

        _buildSlider(
          label: "Pulse Frequency (Hz)",
          value: p.pulseFrequency,
          min: 1,
          max: 100,
          onChanged: (v) => setState(() => p.pulseFrequency = v),
        ),

        _buildSlider(
          label: "Pulse Width (cycles)",
          value: p.pulseWidth,
          min: 3,
          max: 15,
          onChanged: (v) => setState(() => p.pulseWidth = v),
        ),

        _buildSlider(
          label: "Pulse Rise Time (cycles)",
          value: p.pulseRiseTime,
          min: 2,
          max: 5,
          onChanged: (v) => setState(() => p.pulseRiseTime = v),
        ),

        _buildSlider(
          label: "Randomization (%)",
          value: p.pulseIntervalRandom,
          min: 0,
          max: 100,
          onChanged: (v) => setState(() => p.pulseIntervalRandom = v),
        ),

        const SizedBox(height: 30),
        FilledButton(
          onPressed: () async {
            await settings.saveSettings();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Settings Saved")),
            );
          },
          child: const Text("Save Pulse Settings"),
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
            Text(value.toStringAsFixed(0)),
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
