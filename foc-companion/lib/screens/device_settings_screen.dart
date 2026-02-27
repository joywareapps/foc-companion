import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/providers/device_provider.dart';
import 'package:foc_companion/providers/settings_provider.dart';
import 'package:foc_companion/widgets/gradient_slider_track.dart';

class DeviceSettingsScreen extends StatefulWidget {
  const DeviceSettingsScreen({super.key});

  @override
  State<DeviceSettingsScreen> createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final device = Provider.of<DeviceProvider>(context);
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
            color: Colors.red,
          ),
          _buildLeftRightSlider(
            value: d.calibration3Left,
            onChanged: (v) => setState(() => d.calibration3Left = v),
          ),
          if (device.impedanceA != null) ...[
            const SizedBox(height: 8),
            _ImpedanceRow(
              channels: [
                ('Ch A', device.impedanceA),
                ('Ch B', device.impedanceB),
                ('Ch C', device.impedanceC),
              ],
            ),
          ],
        ] else ...[
          const Text("4-Phase Calibration",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildSlider(
            label: "Electrode A",
            value: d.calibration4A,
            min: -2,
            max: 2,
            onChanged: (v) => setState(() => d.calibration4A = v),
            color: Colors.red,
            impedance: device.impedanceA,
          ),
          _buildSlider(
            label: "Electrode B",
            value: d.calibration4B,
            min: -2,
            max: 2,
            onChanged: (v) => setState(() => d.calibration4B = v),
            color: Colors.blue,
            impedance: device.impedanceB,
          ),
          _buildSlider(
            label: "Electrode C",
            value: d.calibration4C,
            min: -2,
            max: 2,
            onChanged: (v) => setState(() => d.calibration4C = v),
            color: Colors.amber,
            impedance: device.impedanceC,
          ),
          _buildSlider(
            label: "Electrode D",
            value: d.calibration4D,
            min: -2,
            max: 2,
            onChanged: (v) => setState(() => d.calibration4D = v),
            color: Colors.green,
            impedance: device.impedanceD,
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

  Widget _buildLeftRightSlider({
    required double value,
    required Function(double) onChanged,
  }) {
    const leftColor = Colors.blue;
    const rightColor = Colors.amber;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Left',
                style: TextStyle(color: leftColor, fontWeight: FontWeight.w500)),
            Text(value.toStringAsFixed(2)),
            const Text('Right',
                style: TextStyle(color: rightColor, fontWeight: FontWeight.w500)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackShape: const GradientSliderTrackShape(
              startColor: leftColor,
              endColor: rightColor,
            ),
          ),
          child: Slider(
            value: value.clamp(-2.0, 2.0),
            min: -2,
            max: 2,
            onChanged: onChanged,
          ),
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
    Color? color,
    double? impedance,
  }) {
    final slider = Slider(
      value: value.clamp(min, max),
      min: min,
      max: max,
      onChanged: onChanged,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: color != null
                  ? TextStyle(color: color, fontWeight: FontWeight.w500)
                  : null,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (impedance != null) ...[
                  _ImpedanceBadge(impedance),
                  const SizedBox(width: 8),
                ],
                Text(value.toStringAsFixed(2)),
              ],
            ),
          ],
        ),
        color != null
            ? SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: color,
                  thumbColor: color,
                  overlayColor: color.withAlpha(30),
                ),
                child: slider,
              )
            : slider,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Impedance badge — coloured "420 Ω" chip shown next to a channel label.
// Green < 600 Ω · Amber 600–1000 Ω · Red > 1000 Ω
// ─────────────────────────────────────────────────────────

class _ImpedanceBadge extends StatelessWidget {
  final double ohms;
  const _ImpedanceBadge(this.ohms);

  Color _color() {
    if (ohms < 600) return Colors.green;
    if (ohms < 1000) return Colors.amber;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: _color().withAlpha(30),
        border: Border.all(color: _color().withAlpha(120)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${ohms.round()} Ω',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _color(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Compact impedance row for 3-phase (channels don't map 1:1 to sliders).
// ─────────────────────────────────────────────────────────

class _ImpedanceRow extends StatelessWidget {
  final List<(String, double?)> channels;
  const _ImpedanceRow({required this.channels});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Impedance:', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 8),
        ...channels.map((ch) {
          final label = ch.$1;
          final ohms = ch.$2;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$label ', style: Theme.of(context).textTheme.bodySmall),
                if (ohms != null)
                  _ImpedanceBadge(ohms)
                else
                  Text('—', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          );
        }),
      ],
    );
  }
}
