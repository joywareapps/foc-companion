import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/providers/settings_provider.dart';

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
        if (d.deviceMode == DeviceMode.threePhase) ...[
          const Text("3-Phase Calibration",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        ] else ...[
          const Text("4-Phase Calibration",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildSlider(
            label: "Center",
            value: d.calibration4Center,
            min: -2,
            max: 2,
            onChanged: (v) => setState(() => d.calibration4Center = v),
          ),
          _buildSlider(
            label: "Electrode A",
            value: d.calibration4A,
            min: -2,
            max: 2,
            onChanged: (v) => setState(() => d.calibration4A = v),
          ),
          _buildSlider(
            label: "Electrode B",
            value: d.calibration4B,
            min: -2,
            max: 2,
            onChanged: (v) => setState(() => d.calibration4B = v),
          ),
          _buildSlider(
            label: "Electrode C",
            value: d.calibration4C,
            min: -2,
            max: 2,
            onChanged: (v) => setState(() => d.calibration4C = v),
          ),
          _buildSlider(
            label: "Electrode D",
            value: d.calibration4D,
            min: -2,
            max: 2,
            onChanged: (v) => setState(() => d.calibration4D = v),
          ),
        ],

        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  settings.resetCalibration();
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
                  final ok = await settings.reloadCalibration();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
                      SnackBar(
                        content: Text(ok ? "Calibration loaded" : "Nothing saved yet"),
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
                      const SnackBar(content: Text("Calibration Saved")),
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
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value.toStringAsFixed(2)),
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
