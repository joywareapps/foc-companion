import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foc_companion/providers/settings_provider.dart';

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
        const Text("Pulse Configuration",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        _buildSlider(
          label: "Carrier Frequency (Hz)",
          value: p.carrierFrequency,
          min: settings.device.minFrequency,
          max: settings.device.maxFrequency,
          decimals: 0,
          onChanged: (v) => setState(() => p.carrierFrequency = v),
        ),

        _buildSlider(
          label: "Pulse Frequency (Hz)",
          value: p.pulseFrequency,
          min: 1,
          max: 100,
          decimals: 0,
          onChanged: (v) => setState(() => p.pulseFrequency = v),
        ),

        _buildSlider(
          label: "Pulse Width (cycles)",
          value: p.pulseWidth,
          min: 3,
          max: 15,
          decimals: 0,
          onChanged: (v) => setState(() => p.pulseWidth = v),
        ),

        _buildSlider(
          label: "Pulse Rise Time (cycles)",
          value: p.pulseRiseTime,
          min: 2,
          max: 5,
          decimals: 0,
          onChanged: (v) => setState(() => p.pulseRiseTime = v),
        ),

        _buildSlider(
          label: "Randomization (%)",
          value: p.pulseIntervalRandom,
          min: 0,
          max: 100,
          decimals: 0,
          onChanged: (v) => setState(() => p.pulseIntervalRandom = v),
        ),

        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  settings.resetPulse();
                  ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
                    const SnackBar(content: Text("Reset to defaults")),
                  );
                },
                child: const Text("Reset"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final ok = await settings.reloadPulse();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
                      SnackBar(
                        content: Text(ok ? "Pulse settings loaded" : "Nothing saved yet"),
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
                onPressed: () async {
                  await settings.saveSettings();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
                      const SnackBar(content: Text("Pulse Settings Saved")),
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
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value.toStringAsFixed(decimals)),
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
