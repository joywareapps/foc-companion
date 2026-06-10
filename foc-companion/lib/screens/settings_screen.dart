import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:foc_companion/providers/settings_provider.dart';
import 'package:foc_companion/providers/device_provider.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/services/app_logger.dart';
import 'package:foc_companion/screens/media_sync_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final device = Provider.of<DeviceProvider>(context);
    final isConnected = device.boxes[settings.activeUiBoxIndex].connectionStatus != "Disconnected";
    final isPlaying = device.boxes[settings.activeUiBoxIndex].isLoopRunning;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // ── Device Switcher ─────────────────────────
        const Text("Target Configuration Slot",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 6),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(
              value: 0,
              label: Text("Box 1"),
              icon: Icon(Icons.looks_one),
            ),
            ButtonSegment(
              value: 1,
              label: Text("Box 2"),
              icon: Icon(Icons.looks_two),
            ),
          ],
          selected: {settings.activeUiBoxIndex},
          onSelectionChanged: (s) => settings.setActiveUiBoxIndex(s.first),
        ),
        const SizedBox(height: 20),

        // ── Display ─────────────────────────────────
        SwitchListTile(
          title: const Text("Keep screen on"),
          subtitle: const Text("Prevent the screen from sleeping while the app is open"),
          value: settings.keepScreenOn,
          onChanged: (v) => settings.setKeepScreenOn(v),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        ListTile(
          title: const Text("Video Player Sync"),
          subtitle: const Text("Configure integration with HereSphere and other players"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const MediaSyncScreen()),
            );
          },
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 16),

        // ── Connection Settings Section ─────────────
        _ConnectionSettingsSection(
          settings: settings,
          device: device,
          isConnected: isConnected,
          isPlaying: isPlaying,
          boxIndex: settings.activeUiBoxIndex,
        ),

        const SizedBox(height: 24),

        // ── Video Sync ──────────────────────────────
        const Text("Video Sync",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.movie_outlined),
          title: const Text("Video Player Sync"),
          subtitle: const Text("Sync funscript playback with HereSphere or MPC-HC"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MediaSyncScreen()),
            );
          },
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
// Connection Settings & Safety Limits Section (Bound to boxIndex)
// ─────────────────────────────────────────────────────────

class _ConnectionSettingsSection extends StatefulWidget {
  final SettingsProvider settings;
  final DeviceProvider device;
  final bool isConnected;
  final bool isPlaying;
  final int boxIndex;

  const _ConnectionSettingsSection({
    required this.settings,
    required this.device,
    required this.isConnected,
    required this.isPlaying,
    required this.boxIndex,
  });

  @override
  State<_ConnectionSettingsSection> createState() => _ConnectionSettingsSectionState();
}

class _ConnectionSettingsSectionState extends State<_ConnectionSettingsSection> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInputs();
  }

  @override
  void didUpdateWidget(covariant _ConnectionSettingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.boxIndex != widget.boxIndex) {
      _loadInputs();
    }
  }

  void _loadInputs() {
    final conn = widget.settings.boxes[widget.boxIndex].connection;
    _ipController.text = conn.wifiIp;
    _portController.text = conn.wifiPort.toString();
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boxProfile = widget.settings.boxes[widget.boxIndex];
    final d = boxProfile.device;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Connection ──────────────────────────────
        Text("Connection (Box ${widget.boxIndex + 1})",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
        const SizedBox(height: 8),
        if (widget.isConnected)
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
          enabled: !widget.isConnected,
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
          enabled: !widget.isConnected,
          decoration: const InputDecoration(
            labelText: "FOC-Stim Device Port",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.router),
          ),
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 24),

        // ── Safety Limits ────────────────────────────
        Text("Safety Limits (Box ${widget.boxIndex + 1})",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
        const SizedBox(height: 8),
        if (widget.isPlaying)
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
          enabled: !widget.isPlaying,
          onChanged: (v) => setState(() => d.minFrequency = v),
        ),
        _buildSlider(
          label: "Max Carrier Frequency (Hz)",
          value: d.maxFrequency,
          min: 100,
          max: 2000,
          decimals: 0,
          enabled: !widget.isPlaying,
          onChanged: (v) => setState(() => d.maxFrequency = v),
        ),
        _buildSlider(
          label: "Max Amplitude (mA)",
          value: d.waveformAmplitude * 1000,
          min: 10,
          max: 150,
          decimals: 0,
          enabled: !widget.isPlaying,
          onChanged: (v) => setState(() => d.waveformAmplitude = v / 1000),
        ),

        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.isConnected
                    ? null
                    : () {
                        widget.settings.resetConnectionAndLimits(); // Reset current active box
                        _loadInputs();
                        ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
                          SnackBar(content: Text("Reset Box ${widget.boxIndex + 1} to defaults")),
                        );
                      },
                child: const Text("Reset"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: widget.isConnected
                    ? null
                    : () async {
                        final ok = await widget.settings.reloadConnectionAndLimits();
                        if (mounted) {
                          _loadInputs();
                          ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
                            SnackBar(
                              content: Text(ok ? "Loaded Box ${widget.boxIndex + 1} settings" : "Nothing saved yet"),
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
                onPressed: widget.isConnected
                    ? null
                    : () async {
                        boxProfile.connection.wifiIp = _ipController.text;
                        boxProfile.connection.wifiPort =
                            int.tryParse(_portController.text) ?? 55533;
                        await widget.settings.saveSettings();
                        if (mounted) {
                          ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
                            SnackBar(content: Text("Box ${widget.boxIndex + 1} Settings Saved")),
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
                          Text(
                            _fmt(entry.time),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontFamily: 'SpaceMono',
                            ),
                          ),
                          const SizedBox(width: 6),
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
