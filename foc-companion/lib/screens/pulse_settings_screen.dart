import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foc_companion/core/command_loop.dart';
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

    // Live-compute firmware values for the info display.
    final axes = pulseFirmwareAxes(
      carrierHz: p.carrierFrequency,
      speed: p.speed,
      pulse: p.pulse,
      texture: p.texture,
    );
    final effFreqHz = axes.freqHz;
    final effWidthMs =
        (axes.widthCycles / p.carrierFrequency * 1000);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text("Pulse Configuration",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        // ── Carrier frequency ──────────────────────────────────────────────
        _buildSlider(
          label: "Tone (carrier frequency)",
          value: p.carrierFrequency,
          min: settings.device.minFrequency,
          max: settings.device.maxFrequency,
          displayValue:
              "${p.carrierFrequency.toStringAsFixed(0)} Hz",
          onChanged: (v) => setState(() => p.carrierFrequency = v),
          onChangeEnd: (_) => settings.saveSettings(),
        ),

        const Divider(height: 24),
        const Text("Pulse shape",
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),

        // ── Speed (inter-pulse gap) ────────────────────────────────────────
        _buildAxisSlider(
          label: "Speed",
          minLabel: "slow",
          maxLabel: "fast",
          value: p.speed,
          infoText:
              "${effFreqHz.toStringAsFixed(1)} Hz effective",
          onChanged: (v) => setState(() => p.speed = v),
          onChangeEnd: (_) => settings.saveSettings(),
        ),

        // ── Pulse (wavelet duration) ───────────────────────────────────────
        _buildAxisSlider(
          label: "Pulse",
          minLabel: "short",
          maxLabel: "long",
          value: p.pulse,
          infoText:
              "${effWidthMs.toStringAsFixed(1)} ms • ${axes.widthCycles.toStringAsFixed(1)} cycles",
          onChanged: (v) => setState(() => p.pulse = v),
          onChangeEnd: (_) => settings.saveSettings(),
        ),

        // ── Texture (onset sharpness) ──────────────────────────────────────
        _buildAxisSlider(
          label: "Texture",
          minLabel: "sharp",
          maxLabel: "smooth",
          value: p.texture,
          infoText:
              "${axes.riseCycles.toStringAsFixed(1)} cycle rise",
          onChanged: (v) => setState(() => p.texture = v),
          onChangeEnd: (_) => settings.saveSettings(),
        ),

        const Divider(height: 24),

        // ── Randomization ──────────────────────────────────────────────────
        _buildSlider(
          label: "Randomization",
          value: p.pulseIntervalRandom,
          min: 0,
          max: 100,
          displayValue: "${p.pulseIntervalRandom.toStringAsFixed(0)}%",
          onChanged: (v) => setState(() => p.pulseIntervalRandom = v),
          onChangeEnd: (_) => settings.saveSettings(),
        ),

        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  settings.resetPulse();
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                        const SnackBar(content: Text("Reset to defaults")));
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
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(SnackBar(
                        content: Text(ok
                            ? "Pulse settings loaded"
                            : "Nothing saved yet"),
                      ));
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
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(const SnackBar(
                          content: Text("Pulse Settings Saved")));
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

  /// Standard numeric slider (for carrier frequency, randomization).
  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String displayValue,
    required void Function(double) onChanged,
    void Function(double)? onChangeEnd,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(displayValue,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
        ),
      ],
    );
  }

  /// Named-endpoint slider for the intuitive 0–1 pulse axes.
  Widget _buildAxisSlider({
    required String label,
    required String minLabel,
    required String maxLabel,
    required double value,
    required String infoText,
    required void Function(double) onChanged,
    void Function(double)? onChangeEnd,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(infoText,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey)),
          ],
        ),
        Slider(value: value, min: 0, max: 1, onChanged: onChanged, onChangeEnd: onChangeEnd),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(minLabel,
                  style: Theme.of(context).textTheme.labelSmall),
              Text(maxLabel,
                  style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
