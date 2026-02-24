import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/providers/device_provider.dart';
import 'package:foc_companion/providers/settings_provider.dart';
import 'package:foc_companion/core/patterns.dart';
import 'package:foc_companion/widgets/gradient_slider_track.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceProvider>(
      builder: (context, device, _) {
        final isConnected = device.api.isConnected;
        final is4Phase = device.deviceMode == DeviceMode.fourPhase;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isConnected) ...[
                _ConnectionCard(device: device),
                const SizedBox(height: 16),
                const _CalibrationCard(),
              ],
              if (isConnected) ...[
                if (!is4Phase) ...[
                  _PatternCard(device: device),
                  const SizedBox(height: 16),
                  _SpeedCard(device: device),
                  const SizedBox(height: 16),
                  _ModulationCard(device: device),
                ] else ...[
                  _FourPhasePatternCard(device: device),
                  const SizedBox(height: 16),
                  _FourPhaseSpeedCard(device: device),
                  const SizedBox(height: 16),
                  _FourPhaseModulationCard(device: device),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
// Calibration Card (shown when disconnected)
// ─────────────────────────────────────────────────────────

class _CalibrationCard extends StatefulWidget {
  const _CalibrationCard();

  @override
  State<_CalibrationCard> createState() => _CalibrationCardState();
}

class _CalibrationCardState extends State<_CalibrationCard> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final d = settings.device;
    final is4Phase = d.deviceMode == DeviceMode.fourPhase;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              is4Phase ? '4-Phase Calibration' : '3-Phase Calibration',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (is4Phase) ...[
              _buildSlider('Electrode A', d.calibration4A, (v) => d.calibration4A = v, color: Colors.red),
              _buildSlider('Electrode B', d.calibration4B, (v) => d.calibration4B = v, color: Colors.blue),
              _buildSlider('Electrode C', d.calibration4C, (v) => d.calibration4C = v, color: Colors.amber),
              _buildSlider('Electrode D', d.calibration4D, (v) => d.calibration4D = v, color: Colors.green),
            ] else ...[
              _buildSlider('Center', d.calibration3Center, (v) => d.calibration3Center = v),
              _buildSlider('Up', d.calibration3Up, (v) => d.calibration3Up = v, color: Colors.red),
              _buildLeftRightSlider(d.calibration3Left, (v) => d.calibration3Left = v),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      settings.resetCalibration();
                      ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
                        const SnackBar(content: Text('Reset to defaults')),
                      );
                    },
                    child: const Text('Reset'),
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
                            content: Text(ok ? 'Calibration loaded' : 'Nothing saved yet'),
                          ),
                        );
                      }
                    },
                    child: const Text('Load'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      await settings.saveSettings();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
                          const SnackBar(content: Text('Calibration Saved')),
                        );
                      }
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftRightSlider(double value, void Function(double) onSet) {
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
            onChanged: (v) => setState(() => onSet(v)),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(String label, double value, void Function(double) onSet,
      {Color? color}) {
    final slider = Slider(
      value: value.clamp(-2.0, 2.0),
      min: -2,
      max: 2,
      onChanged: (v) => setState(() => onSet(v)),
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
            Text(value.toStringAsFixed(2)),
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
// Connection Card
// ─────────────────────────────────────────────────────────

class _ConnectionCard extends StatelessWidget {
  final DeviceProvider device;

  const _ConnectionCard({required this.device});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<DeviceMode>(
              segments: const [
                ButtonSegment(
                  value: DeviceMode.threePhase,
                  label: Text("3-Phase"),
                  icon: Icon(Icons.looks_3_outlined),
                ),
                ButtonSegment(
                  value: DeviceMode.fourPhase,
                  label: Text("4-Phase"),
                  icon: Icon(Icons.looks_4_outlined),
                ),
              ],
              selected: {device.deviceMode},
              onSelectionChanged: (Set<DeviceMode> sel) {
                device.setDeviceMode(sel.first);
              },
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: device.connect,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
              child: const Text('Connect'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Pattern Card
// ─────────────────────────────────────────────────────────

class _PatternCard extends StatelessWidget {
  final DeviceProvider device;

  const _PatternCard({required this.device});

  @override
  Widget build(BuildContext context) {
    final patterns = ThreephasePatternRegistry.all;
    final idx = device.cockpit.patternIndex.clamp(0, patterns.length - 1);
    final selected = patterns[idx];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pattern", style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            DropdownButton<int>(
              isExpanded: true,
              value: idx,
              items: patterns.asMap().entries.map((e) {
                return DropdownMenuItem<int>(
                  value: e.key,
                  child: Text(e.value.name),
                );
              }).toList(),
              onChanged: (i) {
                if (i != null) device.selectPattern(i);
              },
            ),
            const SizedBox(height: 4),
            Text(
              selected.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Speed Card
// ─────────────────────────────────────────────────────────

class _SpeedCard extends StatelessWidget {
  final DeviceProvider device;

  const _SpeedCard({required this.device});

  static const _presets = [0.25, 0.5, 1.0, 2.0, 3.0, 4.0];

  @override
  Widget build(BuildContext context) {
    final velocity = device.cockpit.velocity;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Speed", style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: velocity.clamp(0.1, 4.0),
                    min: 0.1,
                    max: 4.0,
                    divisions: 39,
                    onChanged: (v) => device.setVelocity(v),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    "${velocity.toStringAsFixed(2)}x",
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _presets.map((preset) {
                  final isActive = (velocity - preset).abs() < 0.01;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: OutlinedButton(
                      onPressed: () => device.setVelocity(preset),
                      style: isActive
                          ? OutlinedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primaryContainer,
                            )
                          : null,
                      child: Text(_presetLabel(preset)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _presetLabel(double v) {
    if (v == 0.25) return '¼';
    if (v == 0.5) return '½';
    if (v == 1.0) return '1';
    return '${v.toInt()}';
  }
}

// ─────────────────────────────────────────────────────────
// Pulse Modulation Card
// ─────────────────────────────────────────────────────────

class _ModulationCard extends StatelessWidget {
  final DeviceProvider device;

  const _ModulationCard({required this.device});

  static const _functions = ['sine', 'triangle', 'saw', 'square'];
  static const _funcLabels = ['Sin', 'Tri', 'Saw', 'Sqr'];
  static const _modes = ['off', 'freq', 'width', 'both'];
  static const _modeLabels = ['Off', 'Freq', 'Width', 'F+W'];

  void _update(DeviceProvider device, PulseModulationConfig updated) {
    device.updatePulseModConfig(updated);
  }

  PulseModulationConfig _copy(PulseModulationConfig src) {
    return PulseModulationConfig()
      ..mode = src.mode
      ..function = src.function
      ..speedMultiplier = src.speedMultiplier
      ..minHz = src.minHz
      ..maxHz = src.maxHz
      ..minWidth = src.minWidth
      ..maxWidth = src.maxWidth
      ..phaseShiftDeg = src.phaseShiftDeg
      ..center = src.center
      ..dutyCycle = src.dutyCycle;
  }

  Widget _rangeRow(
    BuildContext context, {
    required String label,
    required double minVal,
    required double maxVal,
    required double sliderMin,
    required double sliderMax,
    required String unit,
    required double kGap,
    required void Function(double, double) onChanged,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Text('${minVal.round()}', style: Theme.of(context).textTheme.bodySmall),
            Expanded(
              child: Center(
                child: Text(label, style: Theme.of(context).textTheme.labelSmall),
              ),
            ),
            Text('${maxVal.round()} $unit',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        RangeSlider(
          values: RangeValues(minVal, maxVal),
          min: sliderMin,
          max: sliderMax,
          divisions: (sliderMax - sliderMin).round(),
          labels: RangeLabels(
            '${minVal.round()} $unit',
            '${maxVal.round()} $unit',
          ),
          onChanged: (RangeValues values) {
            double newMin = values.start;
            double newMax = values.end;
            if (newMax - newMin < kGap) {
              final dMin = (newMin - minVal).abs();
              final dMax = (newMax - maxVal).abs();
              if (dMin >= dMax) {
                newMax = (newMin + kGap).clamp(sliderMin + kGap, sliderMax);
                newMin = newMax - kGap;
              } else {
                newMin = (newMax - kGap).clamp(sliderMin, sliderMax - kGap);
                newMax = newMin + kGap;
              }
            }
            onChanged(newMin, newMax);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cfg = device.cockpit.pulseFreqMod;
    final activeMode = cfg.mode;

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            Text("Pulse Modulation",
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(width: 8),
            Expanded(
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  minimumSize: const Size(0, 30),
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  textStyle: const TextStyle(fontSize: 11),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                segments: List.generate(
                  _modes.length,
                  (i) => ButtonSegment(
                    value: _modes[i],
                    label: Text(_modeLabels[i]),
                  ),
                ),
                selected: {activeMode},
                onSelectionChanged: (sel) {
                  final updated = _copy(cfg)..mode = sel.first;
                  _update(device, updated);
                },
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Speed slider (top)
                Row(
                  children: [
                    const SizedBox(width: 52, child: Text("Speed:")),
                    Expanded(
                      child: Slider(
                        value: cfg.speedMultiplier.clamp(0.25, 4.0),
                        min: 0.25,
                        max: 4.0,
                        divisions: 15,
                        onChanged: (v) {
                          final updated = _copy(cfg)..speedMultiplier = v;
                          _update(device, updated);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 52,
                      child: Text("${cfg.speedMultiplier.toStringAsFixed(2)}x",
                          textAlign: TextAlign.end),
                    ),
                  ],
                ),

                // Function selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_functions.length, (i) {
                    final isActive = cfg.function == _functions[i];
                    return OutlinedButton(
                      onPressed: () {
                        final updated = _copy(cfg)..function = _functions[i];
                        _update(device, updated);
                      },
                      style: isActive
                          ? OutlinedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primaryContainer,
                            )
                          : null,
                      child: Text(_funcLabels[i]),
                    );
                  }),
                ),
                const SizedBox(height: 8),

                // Frequency range — shown for 'freq' and 'both'
                if (activeMode == 'freq' || activeMode == 'both')
                  _rangeRow(
                    context,
                    label: 'Frequency',
                    minVal: cfg.minHz,
                    maxVal: cfg.maxHz,
                    sliderMin: 1,
                    sliderMax: 100,
                    unit: 'Hz',
                    kGap: 10,
                    onChanged: (min, max) => _update(
                      device,
                      _copy(cfg)
                        ..minHz = min
                        ..maxHz = max,
                    ),
                  ),

                // Phase shift — shown only when both freq and width are active
                if (activeMode == 'both')
                  Row(
                    children: [
                      const SizedBox(width: 52, child: Text("Phase:")),
                      ...const [(90, '1/4'), (180, '1/2'), (270, '3/4'), (0, '1/1')]
                          .map((e) {
                        final isActive = cfg.phaseShiftDeg == e.$1;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: OutlinedButton(
                              onPressed: () => _update(
                                device,
                                _copy(cfg)..phaseShiftDeg = e.$1,
                              ),
                              style: isActive
                                  ? OutlinedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                    )
                                  : null,
                              child: Text(e.$2,
                                  style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),

                // Width range — shown for 'width' and 'both'
                if (activeMode == 'width' || activeMode == 'both')
                  _rangeRow(
                    context,
                    label: 'Width (cyc)',
                    minVal: cfg.minWidth,
                    maxVal: cfg.maxWidth,
                    sliderMin: 3,
                    sliderMax: 15,
                    unit: 'cyc',
                    kGap: 2,
                    onChanged: (min, max) => _update(
                      device,
                      _copy(cfg)
                        ..minWidth = min
                        ..maxWidth = max,
                    ),
                  ),

                // Saw center (only shown for saw)
                if (cfg.function == 'saw')
                  Row(
                    children: [
                      const SizedBox(width: 52, child: Text("Center:")),
                      Expanded(
                        child: Slider(
                          value: cfg.center.clamp(0.01, 0.99),
                          min: 0.01,
                          max: 0.99,
                          divisions: 49,
                          onChanged: (v) {
                            final updated = _copy(cfg)..center = v;
                            _update(device, updated);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 52,
                        child: Text("${(cfg.center * 100).toStringAsFixed(0)}%",
                            textAlign: TextAlign.end),
                      ),
                    ],
                  ),

                // Duty cycle (only shown for square)
                if (cfg.function == 'square')
                  Row(
                    children: [
                      const SizedBox(width: 52, child: Text("Duty:")),
                      Expanded(
                        child: Slider(
                          value: cfg.dutyCycle.clamp(0.1, 0.9),
                          min: 0.1,
                          max: 0.9,
                          divisions: 16,
                          onChanged: (v) {
                            final updated = _copy(cfg)..dutyCycle = v;
                            _update(device, updated);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 52,
                        child: Text("${(cfg.dutyCycle * 100).toStringAsFixed(0)}%",
                            textAlign: TextAlign.end),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 4-Phase Pattern Card
// ─────────────────────────────────────────────────────────

class _FourPhasePatternCard extends StatelessWidget {
  final DeviceProvider device;

  const _FourPhasePatternCard({required this.device});

  @override
  Widget build(BuildContext context) {
    final patterns = FourphasePatternRegistry.all;
    final idx = device.cockpit4Phase.patternIndex.clamp(0, patterns.length - 1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pattern", style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            DropdownButton<int>(
              isExpanded: true,
              value: idx,
              items: patterns.asMap().entries.map((e) {
                return DropdownMenuItem<int>(
                  value: e.key,
                  child: Text(e.value.name),
                );
              }).toList(),
              onChanged: (i) {
                if (i != null) device.select4PhasePattern(i);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 4-Phase Speed Card
// ─────────────────────────────────────────────────────────

class _FourPhaseSpeedCard extends StatelessWidget {
  final DeviceProvider device;

  const _FourPhaseSpeedCard({required this.device});

  static const _presets = [0.25, 0.5, 1.0, 2.0, 3.0, 4.0];

  @override
  Widget build(BuildContext context) {
    final velocity = device.cockpit4Phase.velocity;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Speed", style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: velocity.clamp(0.1, 4.0),
                    min: 0.1,
                    max: 4.0,
                    divisions: 39,
                    onChanged: (v) => device.set4PhaseVelocity(v),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    "${velocity.toStringAsFixed(2)}x",
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _presets.map((preset) {
                  final isActive = (velocity - preset).abs() < 0.01;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: OutlinedButton(
                      onPressed: () => device.set4PhaseVelocity(preset),
                      style: isActive
                          ? OutlinedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primaryContainer,
                            )
                          : null,
                      child: Text(_presetLabel(preset)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _presetLabel(double v) {
    if (v == 0.25) return '¼';
    if (v == 0.5) return '½';
    if (v == 1.0) return '1';
    return '${v.toInt()}';
  }
}

// ─────────────────────────────────────────────────────────
// 4-Phase Pulse Modulation Card
// ─────────────────────────────────────────────────────────

class _FourPhaseModulationCard extends StatelessWidget {
  final DeviceProvider device;

  const _FourPhaseModulationCard({required this.device});

  static const _functions = ['sine', 'triangle', 'saw', 'square'];
  static const _funcLabels = ['Sin', 'Tri', 'Saw', 'Sqr'];
  static const _modes = ['off', 'freq', 'width', 'both'];
  static const _modeLabels = ['Off', 'Freq', 'Width', 'F+W'];

  void _update(DeviceProvider device, PulseModulationConfig updated) {
    device.update4PhasePulseModConfig(updated);
  }

  PulseModulationConfig _copy(PulseModulationConfig src) {
    return PulseModulationConfig()
      ..mode = src.mode
      ..function = src.function
      ..speedMultiplier = src.speedMultiplier
      ..minHz = src.minHz
      ..maxHz = src.maxHz
      ..minWidth = src.minWidth
      ..maxWidth = src.maxWidth
      ..phaseShiftDeg = src.phaseShiftDeg
      ..center = src.center
      ..dutyCycle = src.dutyCycle;
  }

  Widget _rangeRow(
    BuildContext context, {
    required String label,
    required double minVal,
    required double maxVal,
    required double sliderMin,
    required double sliderMax,
    required String unit,
    required double kGap,
    required void Function(double, double) onChanged,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Text('${minVal.round()}', style: Theme.of(context).textTheme.bodySmall),
            Expanded(
              child: Center(
                child: Text(label, style: Theme.of(context).textTheme.labelSmall),
              ),
            ),
            Text('${maxVal.round()} $unit',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        RangeSlider(
          values: RangeValues(minVal, maxVal),
          min: sliderMin,
          max: sliderMax,
          divisions: (sliderMax - sliderMin).round(),
          labels: RangeLabels(
            '${minVal.round()} $unit',
            '${maxVal.round()} $unit',
          ),
          onChanged: (RangeValues values) {
            double newMin = values.start;
            double newMax = values.end;
            if (newMax - newMin < kGap) {
              final dMin = (newMin - minVal).abs();
              final dMax = (newMax - maxVal).abs();
              if (dMin >= dMax) {
                newMax = (newMin + kGap).clamp(sliderMin + kGap, sliderMax);
                newMin = newMax - kGap;
              } else {
                newMin = (newMax - kGap).clamp(sliderMin, sliderMax - kGap);
                newMax = newMin + kGap;
              }
            }
            onChanged(newMin, newMax);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cfg = device.cockpit4Phase.pulseFreqMod;
    final activeMode = cfg.mode;

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            Text("Pulse Modulation",
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(width: 8),
            Expanded(
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  minimumSize: const Size(0, 30),
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  textStyle: const TextStyle(fontSize: 11),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                segments: List.generate(
                  _modes.length,
                  (i) => ButtonSegment(
                    value: _modes[i],
                    label: Text(_modeLabels[i]),
                  ),
                ),
                selected: {activeMode},
                onSelectionChanged: (sel) {
                  final updated = _copy(cfg)..mode = sel.first;
                  _update(device, updated);
                },
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Speed slider (top)
                Row(
                  children: [
                    const SizedBox(width: 52, child: Text("Speed:")),
                    Expanded(
                      child: Slider(
                        value: cfg.speedMultiplier.clamp(0.25, 4.0),
                        min: 0.25,
                        max: 4.0,
                        divisions: 15,
                        onChanged: (v) {
                          final updated = _copy(cfg)..speedMultiplier = v;
                          _update(device, updated);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 52,
                      child: Text("${cfg.speedMultiplier.toStringAsFixed(2)}x",
                          textAlign: TextAlign.end),
                    ),
                  ],
                ),

                // Function selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_functions.length, (i) {
                    final isActive = cfg.function == _functions[i];
                    return OutlinedButton(
                      onPressed: () {
                        final updated = _copy(cfg)..function = _functions[i];
                        _update(device, updated);
                      },
                      style: isActive
                          ? OutlinedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primaryContainer,
                            )
                          : null,
                      child: Text(_funcLabels[i]),
                    );
                  }),
                ),
                const SizedBox(height: 8),

                // Frequency range — shown for 'freq' and 'both'
                if (activeMode == 'freq' || activeMode == 'both')
                  _rangeRow(
                    context,
                    label: 'Frequency',
                    minVal: cfg.minHz,
                    maxVal: cfg.maxHz,
                    sliderMin: 1,
                    sliderMax: 100,
                    unit: 'Hz',
                    kGap: 10,
                    onChanged: (min, max) => _update(
                      device,
                      _copy(cfg)
                        ..minHz = min
                        ..maxHz = max,
                    ),
                  ),

                // Phase shift — shown only when both freq and width are active
                if (activeMode == 'both')
                  Row(
                    children: [
                      const SizedBox(width: 52, child: Text("Phase:")),
                      ...const [(90, '1/4'), (180, '1/2'), (270, '3/4'), (0, '1/1')]
                          .map((e) {
                        final isActive = cfg.phaseShiftDeg == e.$1;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: OutlinedButton(
                              onPressed: () => _update(
                                device,
                                _copy(cfg)..phaseShiftDeg = e.$1,
                              ),
                              style: isActive
                                  ? OutlinedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                    )
                                  : null,
                              child: Text(e.$2,
                                  style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),

                // Width range — shown for 'width' and 'both'
                if (activeMode == 'width' || activeMode == 'both')
                  _rangeRow(
                    context,
                    label: 'Width (cyc)',
                    minVal: cfg.minWidth,
                    maxVal: cfg.maxWidth,
                    sliderMin: 3,
                    sliderMax: 15,
                    unit: 'cyc',
                    kGap: 2,
                    onChanged: (min, max) => _update(
                      device,
                      _copy(cfg)
                        ..minWidth = min
                        ..maxWidth = max,
                    ),
                  ),

                // Saw center (only shown for saw)
                if (cfg.function == 'saw')
                  Row(
                    children: [
                      const SizedBox(width: 52, child: Text("Center:")),
                      Expanded(
                        child: Slider(
                          value: cfg.center.clamp(0.01, 0.99),
                          min: 0.01,
                          max: 0.99,
                          divisions: 49,
                          onChanged: (v) {
                            final updated = _copy(cfg)..center = v;
                            _update(device, updated);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 52,
                        child: Text("${(cfg.center * 100).toStringAsFixed(0)}%",
                            textAlign: TextAlign.end),
                      ),
                    ],
                  ),

                // Duty cycle (only shown for square)
                if (cfg.function == 'square')
                  Row(
                    children: [
                      const SizedBox(width: 52, child: Text("Duty:")),
                      Expanded(
                        child: Slider(
                          value: cfg.dutyCycle.clamp(0.1, 0.9),
                          min: 0.1,
                          max: 0.9,
                          divisions: 16,
                          onChanged: (v) {
                            final updated = _copy(cfg)..dutyCycle = v;
                            _update(device, updated);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 52,
                        child: Text("${(cfg.dutyCycle * 100).toStringAsFixed(0)}%",
                            textAlign: TextAlign.end),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

