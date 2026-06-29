import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/providers/device_provider.dart';
import 'package:foc_companion/providers/settings_provider.dart';

class DeviceSettingsScreen extends StatefulWidget {
  const DeviceSettingsScreen({super.key});

  @override
  State<DeviceSettingsScreen> createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen> {
  bool _sensorExpanded = false;
  bool _isDeterminingRange = false;
  double _detectedMin = double.infinity;
  double _detectedMax = double.negativeInfinity;
  Timer? _saveDebounce;

  void _debouncedSave(SettingsProvider settings) {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 300), settings.saveSettings);
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    super.dispose();
  }

  Widget _buildSensorSettingsPanel(SettingsProvider settings, DeviceProvider device) {
    final boxAs5311 = settings.boxes[settings.activeUiBoxIndex].as5311;
    final activeConfig = boxAs5311.activeConfig;
    final colorScheme = Theme.of(context).colorScheme;

    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _sensorExpanded = isExpanded;
        });
      },
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              leading: const Icon(Icons.sensors),
              title: const Text('AS5311 Sensor Calibration'),
              subtitle: Text('Mode: ${boxAs5311.mode}'),
            );
          },
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: boxAs5311.mode,
                  decoration: const InputDecoration(labelText: 'Sensor Mode', isDense: true),
                  items: const [
                    DropdownMenuItem(value: 'off', child: Text('Off')),
                    DropdownMenuItem(value: 'absolute', child: Text('Absolute Position')),
                    DropdownMenuItem(value: 'velocity', child: Text('Velocity (Speed)')),
                    DropdownMenuItem(value: 'highpass', child: Text('High-Pass Filter')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => boxAs5311.mode = v);
                      settings.saveSettings();
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: boxAs5311.targetBox,
                  decoration: const InputDecoration(labelText: 'Routing', isDense: true),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Apply to Box 1')),
                    DropdownMenuItem(value: 1, child: Text('Apply to Box 2')),
                    DropdownMenuItem(value: 2, child: Text('Apply to Both')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => boxAs5311.targetBox = v);
                      settings.saveSettings();
                    }
                  },
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Use Absolute Value (Positive Only)', style: TextStyle(fontSize: 14)),
                  value: activeConfig.useAbsolute,
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => activeConfig.useAbsolute = v);
                      settings.saveSettings();
                    }
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Slider Bounds: ${activeConfig.sliderMin.toStringAsFixed(1)} to ${activeConfig.sliderMax.toStringAsFixed(1)}', style: Theme.of(context).textTheme.bodySmall),
                    OutlinedButton.icon(
                      icon: Icon(_isDeterminingRange ? Icons.stop : Icons.fiber_manual_record),
                      label: Text(_isDeterminingRange ? 'Stop Recording' : 'Determine Range'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _isDeterminingRange ? Colors.red : null,
                        side: BorderSide(color: _isDeterminingRange ? Colors.red : colorScheme.outline),
                      ),
                      onPressed: () {
                        setState(() {
                          if (_isDeterminingRange) {
                            // Stop and apply
                            _isDeterminingRange = false;
                            if (_detectedMax > _detectedMin) {
                              double detectedRange = _detectedMax - _detectedMin;
                              activeConfig.sliderMin = _detectedMin - (detectedRange / 2.0);
                              activeConfig.sliderMax = _detectedMax + (detectedRange / 2.0);
                              
                              // Keep threshold within new bounds
                              activeConfig.threshold = activeConfig.threshold.clamp(activeConfig.sliderMin, activeConfig.sliderMax);
                              settings.saveSettings();
                            }
                          } else {
                            // Start
                            _isDeterminingRange = true;
                            _detectedMin = double.infinity;
                            _detectedMax = double.negativeInfinity;
                          }
                        });
                      },
                    ),
                  ],
                ),
                if (_isDeterminingRange) ...[
                  _RangeDetector(
                    sensorRaw: device.sensorRaw,
                    onRangeUpdated: (min, max) {
                      if (min < _detectedMin || max > _detectedMax) {
                        setState(() {
                          if (min < _detectedMin) _detectedMin = min;
                          if (max > _detectedMax) _detectedMax = max;
                        });
                      }
                    },
                    detectedMin: _detectedMin,
                    detectedMax: _detectedMax,
                  ),
                ],
                const SizedBox(height: 24),
                // Dual VU-Meter Stack
                Row(
                  children: [
                    const SizedBox(
                      width: 60,
                      child: Text('Raw', style: TextStyle(fontSize: 12)),
                    ),
                    Expanded(
                      child: _VuMeter(
                        value: device.sensorRaw, 
                        min: activeConfig.threshold, 
                        max: activeConfig.threshold + activeConfig.range,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const SizedBox(
                      width: 60,
                      child: Text('Decayed', style: TextStyle(fontSize: 12)),
                    ),
                    Expanded(
                      child: _VuMeter(
                        value: device.sensorDecayed, 
                        min: activeConfig.threshold, 
                        max: activeConfig.threshold + activeConfig.range,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Threshold and Range Slider (Stacked under VU meters)
                Padding(
                  padding: const EdgeInsets.only(left: 60.0),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 16.0,
                      activeTrackColor: colorScheme.primary.withAlpha(80),
                      inactiveTrackColor: colorScheme.surfaceContainerHighest,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                    ),
                    child: RangeSlider(
                      values: RangeValues(
                        activeConfig.threshold.clamp(activeConfig.sliderMin, activeConfig.sliderMax), 
                        (activeConfig.threshold + activeConfig.range).clamp(activeConfig.sliderMin, activeConfig.sliderMax)
                      ),
                      min: activeConfig.sliderMin,
                      max: activeConfig.sliderMax,
                      onChanged: (RangeValues values) {
                        setState(() {
                          activeConfig.threshold = values.start;
                          activeConfig.range = (values.end - values.start).clamp(0.01, activeConfig.sliderMax - activeConfig.sliderMin);
                        });
                        _debouncedSave(settings);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSlider(
                  label: 'Volume Multiplier Change',
                  value: activeConfig.volumeChange,
                  min: -1.0,
                  max: 1.0,
                  onChanged: (v) {
                    setState(() => activeConfig.volumeChange = v);
                    settings.saveSettings();
                  },
                ),
                _buildSlider(
                  label: 'Decay Rate (seconds)',
                  value: activeConfig.decayRate,
                  min: 0.0,
                  max: 5.0,
                  onChanged: (v) {
                    setState(() => activeConfig.decayRate = v);
                    settings.saveSettings();
                  },
                ),
              ],
            ),
          ),
          isExpanded: _sensorExpanded,
        ),
      ],
    );
  }

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
            onChangeEnd: (_) => settings.saveSettings(),
          ),
          _buildSlider(
            label: "Electrode A",
            value: d.calibration3A,
            min: -5,
            max: 0,
            onChanged: (v) => settings.updateCalibration3Modern(v, d.calibration3B, d.calibration3C),
            onChangeEnd: (_) => settings.saveSettings(),
            color: Colors.red,
            impedance: device.impedanceA,
          ),
          _buildSlider(
            label: "Electrode B",
            value: d.calibration3B,
            min: -5,
            max: 0,
            onChanged: (v) => settings.updateCalibration3Modern(d.calibration3A, v, d.calibration3C),
            onChangeEnd: (_) => settings.saveSettings(),
            color: Colors.blue,
            impedance: device.impedanceB,
          ),
          _buildSlider(
            label: "Electrode C",
            value: d.calibration3C,
            min: -5,
            max: 0,
            onChanged: (v) => settings.updateCalibration3Modern(d.calibration3A, d.calibration3B, v),
            onChangeEnd: (_) => settings.saveSettings(),
            color: Colors.amber,
            impedance: device.impedanceC,
          ),
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
            onChangeEnd: (_) => settings.saveSettings(),
            color: Colors.red,
            impedance: device.impedanceA,
          ),
          _buildSlider(
            label: "Electrode B",
            value: d.calibration4B,
            min: -2,
            max: 2,
            onChanged: (v) => setState(() => d.calibration4B = v),
            onChangeEnd: (_) => settings.saveSettings(),
            color: Colors.blue,
            impedance: device.impedanceB,
          ),
          _buildSlider(
            label: "Electrode C",
            value: d.calibration4C,
            min: -2,
            max: 2,
            onChanged: (v) => setState(() => d.calibration4C = v),
            onChangeEnd: (_) => settings.saveSettings(),
            color: Colors.amber,
            impedance: device.impedanceC,
          ),
          _buildSlider(
            label: "Electrode D",
            value: d.calibration4D,
            min: -2,
            max: 2,
            onChanged: (v) => setState(() => d.calibration4D = v),
            onChangeEnd: (_) => settings.saveSettings(),
            color: Colors.green,
            impedance: device.impedanceD,
          ),
        ],

        const SizedBox(height: 24),
        _buildSensorSettingsPanel(settings, device),

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
    Function(double)? onChangeEnd,
    Color? color,
    double? impedance,
  }) {
    final slider = Slider(
      value: value.clamp(min, max),
      min: min,
      max: max,
      onChanged: onChanged,
      onChangeEnd: onChangeEnd,
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
// Simple VU Meter for sensor feedback
// ─────────────────────────────────────────────────────────

// Tracks sensor range during calibration recording — updates parent via callback
// rather than mutating state inside build().
class _RangeDetector extends StatefulWidget {
  final double sensorRaw;
  final void Function(double min, double max) onRangeUpdated;
  final double detectedMin;
  final double detectedMax;

  const _RangeDetector({
    required this.sensorRaw,
    required this.onRangeUpdated,
    required this.detectedMin,
    required this.detectedMax,
  });

  @override
  State<_RangeDetector> createState() => _RangeDetectorState();
}

class _RangeDetectorState extends State<_RangeDetector> {
  @override
  void didUpdateWidget(_RangeDetector old) {
    super.didUpdateWidget(old);
    if (widget.sensorRaw != old.sensorRaw) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onRangeUpdated(widget.sensorRaw, widget.sensorRaw);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final minStr = widget.detectedMin != double.infinity
        ? widget.detectedMin.toStringAsFixed(2)
        : '-';
    final maxStr = widget.detectedMax != double.negativeInfinity
        ? widget.detectedMax.toStringAsFixed(2)
        : '-';
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        'Move sensor to limits... Detected: $minStr to $maxStr',
        style: const TextStyle(
            color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}

class _VuMeter extends StatelessWidget {
  final double value;
  final double min;
  final double max;

  const _VuMeter({required this.value, this.min = 0.0, required this.max});

  @override
  Widget build(BuildContext context) {
    double range = max - min;
    if (range <= 0) range = 0.01;
    final fillFraction = ((value - min) / range).clamp(0.0, 1.0);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: fillFraction,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.green, Colors.yellow, Colors.red],
              stops: [0.3, 0.7, 1.0],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}
