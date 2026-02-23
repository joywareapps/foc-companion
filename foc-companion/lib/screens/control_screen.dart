import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/providers/device_provider.dart';
import 'package:foc_companion/providers/settings_provider.dart';
import 'package:foc_companion/core/patterns.dart';

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
              _ConnectionCard(device: device, isConnected: isConnected),
              if (isConnected) ...[
                const SizedBox(height: 16),
                if (!is4Phase) ...[
                  _PatternCard(device: device),
                  const SizedBox(height: 16),
                  _SpeedCard(device: device),
                  const SizedBox(height: 16),
                  _ModulationCard(device: device),
                  const SizedBox(height: 16),
                ],
                _StartStopButton(device: device, is4Phase: is4Phase),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
// Connection Card
// ─────────────────────────────────────────────────────────

class _ConnectionCard extends StatelessWidget {
  final DeviceProvider device;
  final bool isConnected;

  const _ConnectionCard({required this.device, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isConnected) ...[
              Text(
                device.connectionStatus,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                "Temp: ${device.temperature}  ·  Bat: ${device.batteryVoltage}",
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Text(
                device.connectionStatus,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
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
                selected: {settings.device.deviceMode},
                onSelectionChanged: (Set<DeviceMode> sel) {
                  settings.device.deviceMode = sel.first;
                  settings.saveSettings();
                },
              ),
            ],
            const SizedBox(height: 12),
            FilledButton(
              onPressed: isConnected ? device.disconnect : device.connect,
              style: FilledButton.styleFrom(
                backgroundColor: isConnected ? Colors.red : null,
                minimumSize: const Size.fromHeight(44),
              ),
              child: Text(isConnected ? 'Disconnect' : 'Connect'),
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
// Pulse Freq Modulation Card
// ─────────────────────────────────────────────────────────

class _ModulationCard extends StatelessWidget {
  final DeviceProvider device;

  const _ModulationCard({required this.device});

  static const _functions = ['sine', 'triangle', 'saw', 'square'];
  static const _funcLabels = ['Sin', 'Tri', 'Saw', 'Sqr'];

  void _update(DeviceProvider device, PulseModulationConfig updated) {
    device.updatePulseModConfig(updated);
  }

  PulseModulationConfig _copy(PulseModulationConfig src) {
    return PulseModulationConfig()
      ..enabled = src.enabled
      ..function = src.function
      ..speedMultiplier = src.speedMultiplier
      ..depthHz = src.depthHz
      ..center = src.center
      ..dutyCycle = src.dutyCycle;
  }

  @override
  Widget build(BuildContext context) {
    final cfg = device.cockpit.pulseFreqMod;

    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              "Pulse Freq Modulation",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            Switch(
              value: cfg.enabled,
              onChanged: (v) {
                final updated = _copy(cfg)..enabled = v;
                _update(device, updated);
              },
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                // Depth slider
                Row(
                  children: [
                    const SizedBox(width: 52, child: Text("Depth:")),
                    Expanded(
                      child: Slider(
                        value: cfg.depthHz.clamp(0.0, 50.0),
                        min: 0,
                        max: 50,
                        divisions: 50,
                        onChanged: (v) {
                          final updated = _copy(cfg)..depthHz = v;
                          _update(device, updated);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 52,
                      child: Text("${cfg.depthHz.toStringAsFixed(0)} Hz",
                          textAlign: TextAlign.end),
                    ),
                  ],
                ),

                // Speed slider
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

                // Saw center (only shown for saw)
                if (cfg.function == 'saw') ...[
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
                ],

                // Duty cycle (only shown for square)
                if (cfg.function == 'square') ...[
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Start / Stop Button
// ─────────────────────────────────────────────────────────

class _StartStopButton extends StatelessWidget {
  final DeviceProvider device;
  final bool is4Phase;

  const _StartStopButton({required this.device, required this.is4Phase});

  @override
  Widget build(BuildContext context) {
    final patterns = ThreephasePatternRegistry.all;
    final idx = device.cockpit.patternIndex.clamp(0, patterns.length - 1);
    final patternName = is4Phase ? "Cycle" : patterns[idx].name;

    return FilledButton.icon(
      onPressed: device.toggleLoop,
      icon: Icon(device.isLoopRunning ? Icons.stop : Icons.play_arrow),
      label: Text(device.isLoopRunning ? "Stop" : "Start $patternName"),
      style: FilledButton.styleFrom(
        backgroundColor: device.isLoopRunning ? Colors.red : Colors.green,
        minimumSize: const Size.fromHeight(50),
      ),
    );
  }
}
