import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foc_companion/providers/device_provider.dart';
import 'package:foc_companion/providers/settings_provider.dart';

class SensorSettingsScreen extends StatefulWidget {
  const SensorSettingsScreen({super.key});

  @override
  State<SensorSettingsScreen> createState() => _SensorSettingsScreenState();
}

class _SensorSettingsScreenState extends State<SensorSettingsScreen> {
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

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final device = Provider.of<DeviceProvider>(context);
    final boxAs5311 = settings.boxes[settings.activeUiBoxIndex].as5311;
    final activeConfig = boxAs5311.activeConfig;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16.0),
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
            Text(
              'Slider Bounds: ${activeConfig.sliderMin.toStringAsFixed(1)} to ${activeConfig.sliderMax.toStringAsFixed(1)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
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
                    _isDeterminingRange = false;
                    if (_detectedMax > _detectedMin) {
                      final detectedRange = _detectedMax - _detectedMin;
                      activeConfig.sliderMin = _detectedMin - (detectedRange / 2.0);
                      activeConfig.sliderMax = _detectedMax + (detectedRange / 2.0);
                      activeConfig.threshold = activeConfig.threshold
                          .clamp(activeConfig.sliderMin, activeConfig.sliderMax);
                      settings.saveSettings();
                    }
                  } else {
                    _isDeterminingRange = true;
                    _detectedMin = double.infinity;
                    _detectedMax = double.negativeInfinity;
                  }
                });
              },
            ),
          ],
        ),
        if (_isDeterminingRange)
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
        const SizedBox(height: 24),
        // Dual VU-Meter Stack
        Row(
          children: [
            const SizedBox(width: 60, child: Text('Raw', style: TextStyle(fontSize: 12))),
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
            const SizedBox(width: 60, child: Text('Decayed', style: TextStyle(fontSize: 12))),
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
        // Threshold and Range Slider aligned under VU meters
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
                (activeConfig.threshold + activeConfig.range)
                    .clamp(activeConfig.sliderMin, activeConfig.sliderMax),
              ),
              min: activeConfig.sliderMin,
              max: activeConfig.sliderMax,
              onChanged: (values) {
                setState(() {
                  activeConfig.threshold = values.start;
                  activeConfig.range = (values.end - values.start)
                      .clamp(0.01, activeConfig.sliderMax - activeConfig.sliderMin);
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
        Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────

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
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────

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
