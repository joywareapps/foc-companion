import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:foc_companion/providers/settings_provider.dart';
import 'package:foc_companion/providers/device_provider.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/services/app_logger.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _ipController.text = settings.focStim.wifiIp;
    _portController.text = settings.focStim.wifiPort.toString();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final device = Provider.of<DeviceProvider>(context);
    final d = settings.device;

    final isConnected = device.api.isConnected;
    final isPlaying = device.isLoopRunning;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // ── Display ─────────────────────────────────
        SwitchListTile(
          title: const Text("Keep screen on"),
          subtitle: const Text("Prevent the screen from sleeping while the app is open"),
          value: settings.keepScreenOn,
          onChanged: (v) => settings.setKeepScreenOn(v),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 16),

        // ── Connection ──────────────────────────────
        const Text("Connection",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
        const SizedBox(height: 8),
        if (isConnected)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "Disconnect to change connection settings.",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),
        TextField(
          controller: _ipController,
          enabled: !isConnected,
          decoration: const InputDecoration(
            labelText: "FOC-Stim Device IP",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.wifi),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _portController,
          enabled: !isConnected,
          decoration: const InputDecoration(
            labelText: "FOC-Stim Device Port",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.router),
          ),
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 24),

        // ── Safety Limits ────────────────────────────
        const Text("Safety Limits",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
        const SizedBox(height: 8),
        if (isPlaying)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "Stop playback to change safety limits.",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),

        _buildSlider(
          label: "Min Carrier Frequency (Hz)",
          value: d.minFrequency,
          min: 100,
          max: 2000,
          decimals: 0,
          enabled: !isPlaying,
          onChanged: (v) => setState(() => d.minFrequency = v),
        ),
        _buildSlider(
          label: "Max Carrier Frequency (Hz)",
          value: d.maxFrequency,
          min: 100,
          max: 2000,
          decimals: 0,
          enabled: !isPlaying,
          onChanged: (v) => setState(() => d.maxFrequency = v),
        ),
        _buildSlider(
          label: "Max Amplitude (mA)",
          value: d.waveformAmplitude * 1000,
          min: 10,
          max: 150,
          decimals: 0,
          enabled: !isPlaying,
          onChanged: (v) => setState(() => d.waveformAmplitude = v / 1000),
        ),

        const SizedBox(height: 24),

        // ── Device Behavior ──────────────────────────────
        const Text("Device Behavior",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
        const SizedBox(height: 8),
        _buildActionSelector(
          label: "Short press",
          value: settings.deviceBehavior.shortPressAction,
          onChanged: (v) {
            settings.deviceBehavior.shortPressAction = v;
            settings.saveSettings();
          },
        ),
        const SizedBox(height: 8),
        _buildActionSelector(
          label: "Long press",
          value: settings.deviceBehavior.longPressAction,
          onChanged: (v) {
            settings.deviceBehavior.longPressAction = v;
            settings.saveSettings();
          },
        ),
        _buildSlider(
          label: "Long press threshold (ms)",
          value: settings.deviceBehavior.longPressMillis.toDouble(),
          min: 300,
          max: 2000,
          decimals: 0,
          enabled: true,
          onChanged: (v) {
            settings.deviceBehavior.longPressMillis = v.round();
            settings.saveSettings();
          },
        ),

        const SizedBox(height: 24),

        // ── Application Log ─────────────────────────────
        const Text("Application Log",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
        const _LogViewer(),

        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isConnected
                    ? null
                    : () {
                        settings.resetConnectionAndLimits();
                        _ipController.text = settings.focStim.wifiIp;
                        _portController.text =
                            settings.focStim.wifiPort.toString();
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
                onPressed: isConnected
                    ? null
                    : () async {
                        final ok = await settings.reloadConnectionAndLimits();
                        if (context.mounted) {
                          _ipController.text = settings.focStim.wifiIp;
                          _portController.text =
                              settings.focStim.wifiPort.toString();
                          ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
                            SnackBar(
                              content: Text(ok ? "Settings loaded" : "Nothing saved yet"),
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
                onPressed: isConnected
                    ? null
                    : () async {
                        settings.focStim.wifiIp = _ipController.text;
                        settings.focStim.wifiPort =
                            int.tryParse(_portController.text) ?? 55533;
                        await settings.saveSettings();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
                            const SnackBar(content: Text("Settings Saved")),
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
    required bool enabled,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: enabled
                    ? null
                    : TextStyle(
                        color: Theme.of(context).disabledColor)),
            Text(value.toStringAsFixed(decimals),
                style: enabled
                    ? null
                    : TextStyle(
                        color: Theme.of(context).disabledColor)),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }

  Widget _buildActionSelector({
    required String label,
    required ButtonAction value,
    required ValueChanged<ButtonAction> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label),
        ),
        Expanded(
          child: SegmentedButton<ButtonAction>(
            segments: const [
              ButtonSegment(
                value: ButtonAction.nothing,
                label: Text("Nothing"),
              ),
              ButtonSegment(
                value: ButtonAction.togglePlayPause,
                label: Text("Play/Pause"),
              ),
              ButtonSegment(
                value: ButtonAction.toggleVolumeLock,
                label: Text("Vol. Lock"),
              ),
            ],
            selected: {value},
            onSelectionChanged: (s) => onChanged(s.first),
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Log viewer — scrollable list of in-memory log entries.
// Newest entry at top. Colour-coded by level.
// ─────────────────────────────────────────────────────────

class _LogViewer extends StatelessWidget {
  const _LogViewer();

  static const _levelColors = {
    LogLevel.debug: Colors.grey,
    LogLevel.info: Colors.blue,
    LogLevel.warning: Colors.amber,
    LogLevel.error: Colors.red,
  };

  static const _levelLabels = {
    LogLevel.debug: 'D',
    LogLevel.info: 'I',
    LogLevel.warning: 'W',
    LogLevel.error: 'E',
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppLogger.instance,
      builder: (context, _) {
        final entries = AppLogger.instance.entries.reversed.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${entries.length} entries',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy all'),
                  onPressed: entries.isEmpty
                      ? null
                      : () {
                          final text = AppLogger.instance.entries
                              .map((e) =>
                                  '[${_fmt(e.time)}] ${_levelLabels[e.level]} ${e.message}')
                              .join('\n');
                          Clipboard.setData(ClipboardData(text: text));
                          ScaffoldMessenger.of(context)
                            ..clearSnackBars()
                            ..showSnackBar(const SnackBar(
                                content: Text('Log copied to clipboard')));
                        },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Clear'),
                  onPressed: entries.isEmpty
                      ? null
                      : () => AppLogger.instance.clear(),
                ),
              ],
            ),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No log entries yet.',
                    style: TextStyle(color: Colors.grey)),
              )
            else
              SizedBox(
                height: 280,
                child: ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, i) {
                    final entry = entries[i];
                    final color = _levelColors[entry.level]!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Level badge
                          Container(
                            width: 16,
                            alignment: Alignment.center,
                            child: Text(
                              _levelLabels[entry.level]!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: color,
                                fontFamily: 'SpaceMono',
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Timestamp
                          Text(
                            _fmt(entry.time),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontFamily: 'SpaceMono',
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Message
                          Expanded(
                            child: Text(
                              entry.message,
                              style: TextStyle(
                                fontSize: 11,
                                color: color,
                                fontFamily: 'SpaceMono',
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  static String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}:'
      '${t.second.toString().padLeft(2, '0')}';
}
