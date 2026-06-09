import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

import 'package:foc_companion/services/background_service.dart';
import 'package:foc_companion/providers/device_provider.dart';
import 'package:foc_companion/services/funscript_bundle_loader.dart';
import 'package:foc_companion/services/funscript_playback_controller.dart';
import 'package:foc_companion/services/app_logger.dart';
import 'package:foc_companion/services/video_sync_controller.dart';
import 'package:foc_companion/models/funscript_bundle.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/providers/settings_provider.dart';

/// Full-screen funscript player with transport controls and live axis display.
///
/// V1: Playback controller runs in foreground; sends commands to background
/// service to toggle funscript mode. The background CommandLoop reads the
/// shared controller's values each tick.
class FunscriptPlayerScreen extends StatefulWidget {
  final Map<String, dynamic> meta;

  const FunscriptPlayerScreen({super.key, required this.meta});

  @override
  State<FunscriptPlayerScreen> createState() => _FunscriptPlayerScreenState();
}

class _FunscriptPlayerScreenState extends State<FunscriptPlayerScreen> {
  FunscriptBundle? _bundle;
  final FunscriptPlaybackController _controller =
      FunscriptPlaybackController();
  bool _isLoading = true;
  String? _error;
  Timer? _tickTimer;
  VideoSyncController? _videoSync;
  bool _syncConnecting = false;
  PlaybackState _lastPlaybackState = PlaybackState.stopped;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _loadBundle();
  }

  void _onControllerChanged() {
    final state = _controller.state;
    if (state != _lastPlaybackState) {
      _lastPlaybackState = state;
      if (state == PlaybackState.playing) {
        _syncDevicePlay();
        _startTickTimer();
      } else if (state == PlaybackState.paused) {
        _syncDevicePause();
        _stopTickTimer();
      } else if (state == PlaybackState.stopped) {
        _syncDeviceStop();
        _stopTickTimer();
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _tickTimer?.cancel();
    _controller.stop();
    _videoSync?.dispose();
    
    // Attempt to stop on both boxes just in case they were linked
    for (int i = 0; i < 2; i++) {
      BackgroundServiceManager.sendCommand('stopFunscriptPlayback', {
        'boxIndex': i,
      });
    }
    
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadBundle() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final libraryDir = '${appDir.path}/funscript_library';
      final bundle = await FunscriptBundleLoader.loadFromLibrary(
        widget.meta['id'] as String,
        libraryDir,
      );
      if (mounted) {
        setState(() {
          _bundle = bundle;
          _isLoading = false;
        });
        _controller.load(bundle);
      }
    } catch (e) {
      AppLogger.instance.e('FunscriptPlayerScreen: load failed', error: e);
      if (mounted) setState(() => _error = 'Failed to load bundle: $e');
    }
  }

  void _startTickTimer() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      if (_controller.tick()) {
        final device = context.read<DeviceProvider>();
        final linked = device.settings.linkDevicesEnabled;
        final activeBox = _boxIndex;

        final allValues = _controller.currentValues;

        if (linked) {
          // Send to both
          BackgroundServiceManager.sendCommand('updateFunscriptValues', {
            'boxIndex': 0,
            'values': _filterAxes(allValues, prostate: false),
          });
          BackgroundServiceManager.sendCommand('updateFunscriptValues', {
            'boxIndex': 1,
            'values': _filterAxes(allValues, prostate: true),
          });
        } else {
          // Send to single target box
          BackgroundServiceManager.sendCommand('updateFunscriptValues', {
            'boxIndex': activeBox,
            'values': _filterAxes(allValues, prostate: activeBox == 1),
          });
        }
      }
    });
  }

  /// Maps axis variants to standard names. If prostate is true, prefers {axis}-prostate.
  Map<String, double> _filterAxes(Map<String, double> allValues, {required bool prostate}) {
    final result = <String, double>{};
    // Base axes are those that don't end in -prostate
    final baseAxes = allValues.keys.where((k) => !k.endsWith('-prostate')).toList();

    for (final axis in baseAxes) {
      if (prostate) {
        final pKey = '$axis-prostate';
        if (allValues.containsKey(pKey)) {
          result[axis] = allValues[pKey]!;
        } else {
          result[axis] = allValues[axis]!;
        }
      } else {
        result[axis] = allValues[axis]!;
      }
    }
    return result;
  }

  void _stopTickTimer() {
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  bool _getIsConnected(BuildContext context, {required bool listen}) {
    final device = listen
        ? Provider.of<DeviceProvider>(context)
        : Provider.of<DeviceProvider>(context, listen: false);
    return device.api.isConnected;
  }

  int get _boxIndex => widget.meta['boxIndex'] as int? ?? 0;

  void _syncDevicePlay() {
    if (!mounted) return;
    if (!_getIsConnected(context, listen: false)) return;

    final device = context.read<DeviceProvider>();
    final linked = device.settings.linkDevicesEnabled;
    final targets = linked ? [0, 1] : [_boxIndex];

    // When linking, ensure both boxes start from the same state:
    // stop both and set volume to the lower of the two (or 0).
    if (linked) {
      for (int i = 0; i < 2; i++) {
        BackgroundServiceManager.sendCommand('stopFunscriptPlayback', {
          'boxIndex': i,
        });
      }
      final vol0 = device.boxes[0].boxVolume;
      final vol1 = device.boxes[1].boxVolume;
      final safeVolume = vol0 < vol1 ? vol0 : vol1;
      for (int i = 0; i < 2; i++) {
        BackgroundServiceManager.sendCommand('setVolume', {
          'boxIndex': i,
          'volume': safeVolume,
        });
      }
    }

    for (final idx in targets) {
      BackgroundServiceManager.sendCommand('startFunscriptPlayback', {
        'boxIndex': idx,
      });
    }
  }

  void _syncDevicePause() {
    if (!mounted) return;
    final device = context.read<DeviceProvider>();
    final targets = device.settings.linkDevicesEnabled ? [0, 1] : [_boxIndex];

    for (final idx in targets) {
      BackgroundServiceManager.sendCommand('pauseFunscriptPlayback', {
        'boxIndex': idx,
      });
    }
  }

  void _syncDeviceStop() {
    if (!mounted) return;
    final device = context.read<DeviceProvider>();
    final targets = device.settings.linkDevicesEnabled ? [0, 1] : [_boxIndex];

    for (final idx in targets) {
      BackgroundServiceManager.sendCommand('stopFunscriptPlayback', {
        'boxIndex': idx,
      });
    }
  }

  void _play() {
    _controller.play();
  }

  void _pause() {
    _controller.pause();
  }

  void _stop() {
    _controller.stop();
  }

  void _seekTo(double progress) {
    _controller.seek((progress * _controller.durationMs).round());
  }

  String _formatTime(int ms) {
    final totalSeconds = ms ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading…')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_bundle?.name ?? 'Player'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Back to pattern mode',
            onPressed: () {
              _stop();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Bundle info ──
                _buildInfoCard(),
                const SizedBox(height: 16),

                // ── Axis values display ──
                _buildAxisDisplay(),
                const SizedBox(height: 20),

                // ── Seek bar ──
                _buildSeekBar(),
                const SizedBox(height: 8),
                _buildTimeDisplay(),
                const SizedBox(height: 20),

                // ── Transport controls ──
                _buildTransportControls(),
                const SizedBox(height: 12),

                // ── Sync status indicator ──
                _buildSyncIndicator(),
                const SizedBox(height: 12),

                // ── Waveform preview ──
                if (_bundle != null) _buildWaveformPreview(),

                const SizedBox(height: 32),

                // ── Stop & return to pattern ──
                OutlinedButton.icon(
                  onPressed: () {
                    _stop();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('Stop & Return to Pattern'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard() {
    final axes = _bundle?.axisNames ?? [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _bundle?.name ?? 'Unknown',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Duration: ${_formatTime(_bundle?.durationMs ?? 0)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (_bundle?.sourceFile.isNotEmpty == true) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.attach_file, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _bundle!.sourceFile,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (axes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: axes
                    .map((a) => Chip(
                          label: Text(a, style: const TextStyle(fontSize: 11)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 6),
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAxisDisplay() {
    final values = _controller.currentValues;
    if (values.isEmpty && _controller.state != PlaybackState.playing) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Press play to see live axis values',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Live Axis Values',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: _controller.bundle?.axisNames.map((axis) {
                    final val = _controller.getValue(axis);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(axis,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.grey)),
                        Text(
                          val != null ? val.toStringAsFixed(3) : '—',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  }).toList() ??
                  [],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeekBar() {
    final progress = _controller.progress;
    return Slider(
      value: progress.clamp(0.0, 1.0),
      onChanged: (v) => _seekTo(v),
    );
  }

  Widget _buildTimeDisplay() {
    final position = _formatTime(_controller.positionMs);
    final duration = _formatTime(_controller.durationMs);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(position, style: const TextStyle(fontSize: 13)),
        Text(duration, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _buildTransportControls() {
    final state = _controller.state;
    final isPlaying = state == PlaybackState.playing;
    final isConnected = _getIsConnected(context, listen: true);

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Skip back 10s
              IconButton(
                icon: const Icon(Icons.replay_10),
                tooltip: 'Back 10s',
                onPressed: () => _controller.seek(
                    (_controller.positionMs - 10000).clamp(0, _controller.durationMs)),
              ),
              const SizedBox(width: 8),
              // Loop toggle
              IconButton(
                icon: Icon(Icons.repeat,
                    color: _controller.loop ? Theme.of(context).colorScheme.primary : null),
                tooltip: 'Loop',
                onPressed: () => _controller.setLoop(!_controller.loop),
              ),
              const SizedBox(width: 8),
              // Play / Pause
              FloatingActionButton.large(
                onPressed: isPlaying ? _pause : (isConnected ? _play : null),
                backgroundColor:
                    isPlaying ? Theme.of(context).colorScheme.secondary : null,
                child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 32),
              ),
              const SizedBox(width: 8),
              // Stop
              IconButton(
                icon: const Icon(Icons.stop),
                tooltip: 'Stop',
                onPressed: _stop,
              ),
              const SizedBox(width: 8),
              // Skip forward 10s
              IconButton(
                icon: const Icon(Icons.forward_10),
                tooltip: 'Forward 10s',
                onPressed: () => _controller.seek(
                    (_controller.positionMs + 10000).clamp(0, _controller.durationMs)),
              ),
              const SizedBox(width: 8),
              // Video sync toggle
              _buildSyncButton(),
            ],
          ),
        ),
        if (!isConnected)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Connect a device to play',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.orange),
            ),
          ),
      ],
    );
  }

  Widget _buildWaveformPreview() {
    // Use the configured waveform axis (default: volume, then alpha, then first available)
    final axes = _bundle?.axes ?? {};
    if (axes.isEmpty) return const SizedBox.shrink();

    final savedAxis = widget.meta['waveformAxis'] as String? ?? 'volume';
    String selectedAxis = axes.containsKey(savedAxis) ? savedAxis : axes.keys.first;

    final script = axes[selectedAxis];
    if (script == null || script.actions.isEmpty) {
      // Try other axes as fallback
      for (final entry in axes.entries) {
        if (entry.value.actions.isNotEmpty) {
          selectedAxis = entry.key;
          break;
        }
      }
    }

    final currentScript = axes[selectedAxis];
    if (currentScript == null || currentScript.actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildWaveformForScript(currentScript, _axisDisplayName(selectedAxis)),
        if (axes.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: axes.keys.map((axis) {
                final isSelected = axis == selectedAxis;
                return ChoiceChip(
                  label: Text(axis, style: const TextStyle(fontSize: 11)),
                  selected: isSelected,
                  onSelected: (_) {
                    // Update meta and rebuild
                    setState(() {
                      widget.meta['waveformAxis'] = axis;
                    });
                    // Persist the change
                    _saveWaveformAxis(axis);
                  },
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  String _axisDisplayName(String axis) {
    switch (axis) {
      case 'alpha': return 'Alpha';
      case 'beta': return 'Beta';
      case 'volume': return 'Volume';
      case 'frequency': return 'Frequency';
      case 'pulse_frequency': return 'Pulse Freq';
      case 'pulse_width': return 'Pulse Width';
      case 'pulse_rise_time': return 'Pulse Rise';
      case 'pulse_interval_random': return 'Pulse Interval';
      default: return axis[0].toUpperCase() + axis.substring(1);
    }
  }

  Future<void> _saveWaveformAxis(String axis) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final libraryDir = '${appDir.path}/funscript_library';
      await FunscriptBundleLoader.updateWaveformAxis(
        widget.meta['id'] as String,
        axis,
        libraryDir,
      );
    } catch (e) {
      AppLogger.instance.e('FunscriptPlayerScreen: failed to save waveform axis', error: e);
    }
  }

  // ── Video Sync ────────────────────────────────────────────────

  Widget _buildSyncButton() {
    final isLinked = _videoSync?.isLinked ?? false;
    final syncState = _videoSync?.syncState ?? SyncState.idle;
    final isBeyond = _videoSync?.isVideoBeyondScript ?? false;

    Color color;
    IconData icon;
    String tooltip;

    if (_syncConnecting) {
      color = Theme.of(context).colorScheme.primary;
      icon = Icons.sync;
      tooltip = 'Connecting…';
    } else if (isLinked && syncState == SyncState.error) {
      color = Theme.of(context).colorScheme.error;
      icon = Icons.link_off;
      tooltip = 'Sync error — tap to retry';
    } else if (isLinked && isBeyond) {
      color = Colors.amber;
      icon = Icons.link;
      tooltip = 'Video beyond script — tap to unlink';
    } else if (isLinked) {
      color = Theme.of(context).colorScheme.primary;
      icon = Icons.link;
      tooltip = 'Unlink video sync';
    } else {
      color = Theme.of(context).disabledColor;
      icon = Icons.link_off;
      tooltip = 'Link video sync';
    }

    return IconButton(
      icon: Icon(icon, color: color),
      tooltip: tooltip,
      onPressed: () => _toggleVideoSync(),
    );
  }

  Future<void> _toggleVideoSync() async {
    if (_videoSync != null && _videoSync!.isLinked) {
      _videoSync!.unlink();
      _videoSync!.dispose();
      _videoSync = null;
      setState(() {});
      return;
    }

    // Read active player from settings
    final settings = context.read<SettingsProvider>();
    final m = settings.mediaSync;

    if (m.activePlayer == VideoPlayerType.none) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(const SnackBar(
            content: Text(
                'No video player configured. Set up in Settings → Video Sync.'),
          ));
      }
      return;
    }

    setState(() => _syncConnecting = true);

    _videoSync = VideoSyncController(funscriptController: _controller);
    _videoSync!.addListener(() {
      if (mounted) setState(() => _syncConnecting = false);
    });

    try {
      await _videoSync!.link(
        m.activePlayer,
        heresphereIp: m.hereSphereIp,
        herespherePort: m.hereSpherePort,
        mpcHcIp: m.mpcHcIp,
        mpcHcPort: m.mpcHcPort,
      );
    } catch (e) {
      AppLogger.instance.e('VideoSync: link failed', error: e);
      if (mounted) {
        setState(() => _syncConnecting = false);
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text('Sync failed: $e')));
      }
    }
  }

  Widget _buildSyncIndicator() {
    final isLinked = _videoSync?.isLinked ?? false;
    final isBeyond = _videoSync?.isVideoBeyondScript ?? false;

    if (!isLinked || !isBeyond) return const SizedBox.shrink();

    final videoTime = _formatTime(_videoSync!.playerStatus.currentTimeMs.toInt());
    final scriptTime = _formatTime(_controller.durationMs);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          Text(
            'Video at $videoTime — script ended at $scriptTime',
            style: const TextStyle(fontSize: 12, color: Colors.amber),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveformForScript(dynamic script, String label) {
    final actions = script.actions;
    final duration = script.durationMs;
    if (duration <= 0 || actions.isEmpty) return const SizedBox.shrink();

    // Sample up to 200 points
    const sampleCount = 200;
    final samples = <double>[];
    for (int i = 0; i < sampleCount; i++) {
      final timeMs = (i * duration) ~/ sampleCount;
      if (actions.length == 1) {
        samples.add(actions.first.pos / 100.0);
      } else {
        int lo = 0, hi = actions.length - 1;
        while (hi - lo > 1) {
          final mid = (lo + hi) ~/ 2;
          if (actions[mid].at <= timeMs) lo = mid;
          else hi = mid;
        }
        if (timeMs <= actions.first.at) {
          samples.add(actions.first.pos / 100.0);
        } else if (timeMs >= actions.last.at) {
          samples.add(actions.last.pos / 100.0);
        } else {
          final a = actions[lo], b = actions[hi];
          final t = (timeMs - a.at) / (b.at - a.at);
          samples.add(((a.pos + t * (b.pos - a.pos)) / 100.0).clamp(0.0, 1.0));
        }
      }
    }

    final playbackX = _controller.progress;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label Waveform',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: CustomPaint(
                size: Size.infinite,
                painter: _WaveformPainter(
                  samples: samples,
                  playbackPosition: playbackX,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for waveform visualization.
class _WaveformPainter extends CustomPainter {
  final List<double> samples;
  final double playbackPosition;
  final Color color;

  _WaveformPainter({
    required this.samples,
    required this.playbackPosition,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;

    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < samples.length; i++) {
      final x = (i / (samples.length - 1)) * size.width;
      final y = size.height - (samples[i] * size.height);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);

    // Playback position line
    final linePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;
    final lineX = playbackPosition.clamp(0.0, 1.0) * size.width;
    canvas.drawLine(Offset(lineX, 0), Offset(lineX, size.height), linePaint);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) =>
      old.playbackPosition != playbackPosition;
}
