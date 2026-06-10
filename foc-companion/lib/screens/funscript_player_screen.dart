import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

import 'package:foc_companion/services/background_service.dart';
import 'package:foc_companion/providers/device_provider.dart';
import 'package:foc_companion/providers/settings_provider.dart';
import 'package:foc_companion/services/funscript_bundle_loader.dart';
import 'package:foc_companion/services/funscript_playback_controller.dart';
import 'package:foc_companion/services/app_logger.dart';
import 'package:foc_companion/services/video_sync_controller.dart';
import 'package:foc_companion/models/funscript_bundle.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/services/media_sync_orchestrator.dart';

/// Full-screen funscript player with transport controls and live axis display.
class FunscriptPlayerScreen extends StatefulWidget {
  final Map<String, dynamic>? meta;

  const FunscriptPlayerScreen({super.key, this.meta});

  @override
  State<FunscriptPlayerScreen> createState() => _FunscriptPlayerScreenState();
}

class _FunscriptPlayerScreenState extends State<FunscriptPlayerScreen> {
  FunscriptBundle? _bundle;
  final FunscriptPlaybackController _controller = FunscriptPlaybackController();
  bool _isLoading = true;
  String? _error;
  Timer? _tickTimer;
  VideoSyncController? _videoSync;
  bool _syncConnecting = false;
  MediaSyncOrchestrator? _orchestrator;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    
    _orchestrator = MediaSyncOrchestrator(
      settings: settings,
      playbackController: _controller,
      onBundleLoaded: (bundle) {
        if (mounted) setState(() => _bundle = bundle);
      },
    );

    _videoSync = VideoSyncController(funscriptController: _controller);
    _videoSync!.onFileChanged = (path) {
      // Robustly extract filename from URL or Path
      final uri = Uri.tryParse(path);
      String filename = (uri != null && uri.pathSegments.isNotEmpty) 
          ? uri.pathSegments.last 
          : path.split('/').last.split('\\').last;
      
      _orchestrator?.onFilenameChanged(filename);
    };

    _controller.addListener(_syncHardwareWithController);

    _loadBundle().then((_) {
      if (widget.meta == null && mounted) {
        _toggleVideoSync();
      }
    });
  }

  @override
  void dispose() {
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
    if (widget.meta == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final libraryDir = '${appDir.path}/funscript_library';
      final bundle = await FunscriptBundleLoader.loadFromLibrary(
        widget.meta!['id'] as String,
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
          BackgroundServiceManager.sendCommand('updateFunscriptValues', {
            'boxIndex': 0,
            'values': _filterAxes(allValues, prostate: false),
          });
          BackgroundServiceManager.sendCommand('updateFunscriptValues', {
            'boxIndex': 1,
            'values': _filterAxes(allValues, prostate: true),
          });
        } else {
          BackgroundServiceManager.sendCommand('updateFunscriptValues', {
            'boxIndex': activeBox,
            'values': _filterAxes(allValues, prostate: activeBox == 1),
          });
        }
      }
    });
  }

  Map<String, double> _filterAxes(Map<String, double> allValues, {required bool prostate}) {
    final result = <String, double>{};
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

  int get _boxIndex => widget.meta?['boxIndex'] as int? ?? 
      context.read<DeviceProvider>().settings.activeUiBoxIndex;

  void _syncHardwareWithController() {
    if (!mounted) return;
    final state = _controller.state;

    if (state == PlaybackState.playing) {
      _setupHardwarePlayback();
      if (_tickTimer == null) _startTickTimer();
    } else if (state == PlaybackState.paused) {
      final device = context.read<DeviceProvider>();
      final targets = device.settings.linkDevicesEnabled ? [0, 1] : [_boxIndex];
      for (final idx in targets) {
        BackgroundServiceManager.sendCommand('pauseFunscriptPlayback', {'boxIndex': idx});
      }
      _stopTickTimer();
    } else if (state == PlaybackState.stopped) {
      final device = context.read<DeviceProvider>();
      final targets = device.settings.linkDevicesEnabled ? [0, 1] : [_boxIndex];
      for (final idx in targets) {
        BackgroundServiceManager.sendCommand('stopFunscriptPlayback', {'boxIndex': idx});
      }
      _stopTickTimer();
    }
  }

  void _setupHardwarePlayback() {
    if (!_getIsConnected(context, listen: false)) return;

    final device = context.read<DeviceProvider>();
    final linked = device.settings.linkDevicesEnabled;
    final targets = linked ? [0, 1] : [_boxIndex];

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

  void _play() {
    if (!_getIsConnected(context, listen: false)) return;
    _controller.play();
    _setupHardwarePlayback();
    _startTickTimer();
  }

  void _pause() {
    _controller.pause();
    final device = context.read<DeviceProvider>();
    final targets = device.settings.linkDevicesEnabled ? [0, 1] : [_boxIndex];

    for (final idx in targets) {
      BackgroundServiceManager.sendCommand('pauseFunscriptPlayback', {
        'boxIndex': idx,
      });
    }
    _stopTickTimer();
  }

  void _stop() {
    _controller.stop();
    final device = context.read<DeviceProvider>();
    final targets = device.settings.linkDevicesEnabled ? [0, 1] : [_boxIndex];

    for (final idx in targets) {
      BackgroundServiceManager.sendCommand('stopFunscriptPlayback', {
        'boxIndex': idx,
      });
    }
    _stopTickTimer();
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

    return ListenableBuilder(
      listenable: Listenable.merge([_controller, _videoSync]),
      builder: (context, _) {
        final isLinked = _videoSync?.isLinked ?? false;

        return Scaffold(
          appBar: AppBar(
            title: Text(_bundle?.name ?? 'Waiting for video…'),
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_bundle != null) _buildInfoCard()
                else _buildEmptyPlayerInfo(),
                const SizedBox(height: 16),
                _buildAxisDisplay(isLinked),
                const SizedBox(height: 20),

                if (!isLinked) ...[
                  _buildSeekBar(),
                  const SizedBox(height: 8),
                  _buildTimeDisplay(),
                  const SizedBox(height: 20),
                ],

                _buildTransportControls(isLinked),
                const SizedBox(height: 12),

                _buildSyncIndicator(),
                const SizedBox(height: 12),

                if (_bundle != null) _buildWaveformPreview(),

                const SizedBox(height: 32),

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
          ),
        );
      },
    );
  }

  Widget _buildEmptyPlayerInfo() {
    final player = context.read<SettingsProvider>().mediaSync.activePlayer;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.sync, size: 48, color: Colors.blue),
            const SizedBox(height: 12),
            Text(
              'No Script Loaded',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              player == VideoPlayerType.none 
                ? 'Select a player in Settings to begin sync.'
                : 'Link with ${player.name} to automatically load scripts.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
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
            if (axes.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'Axes: ${axes.join(", ")}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[500]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAxisDisplay(bool isLinked) {
    final values = _controller.currentValues;
    final status = _videoSync?.playerStatus;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Live Axis Values',
                    style: Theme.of(context).textTheme.titleSmall),
                if (isLinked) ...[
                  Text(' | ', style: TextStyle(color: Colors.grey[600])),
                  Text(
                    _formatTime(_controller.positionMs),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ],
            ),
            if (isLinked && status != null) ...[
              const SizedBox(height: 4),
              Text(
                'Linked: ${_getFilenameFromPath(status.filePath ?? "")}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            if (values.isEmpty)
               const Text('Waiting for script…', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))
            else
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
      onChangeEnd: (_) {
        if (_controller.state == PlaybackState.playing) {
          _controller.play();
          _startTickTimer();
        }
      },
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

  Widget _buildTransportControls(bool isLinked) {
    final state = _controller.state;
    final isPlaying = state == PlaybackState.playing;
    final isConnected = _getIsConnected(context, listen: true);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isLinked) ...[
              IconButton(
                icon: const Icon(Icons.replay_10),
                tooltip: 'Back 10s',
                onPressed: () => _controller.seek(
                    (_controller.positionMs - 10000).clamp(0, _controller.durationMs)),
              ),
              const SizedBox(width: 16),
            ],
            FloatingActionButton.large(
              onPressed: isPlaying ? _pause : (isConnected ? _play : null),
              backgroundColor:
                  isPlaying ? Theme.of(context).colorScheme.secondary : null,
              child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 32),
            ),
            const SizedBox(width: 16),
            if (!isLinked) ...[
              IconButton(
                icon: const Icon(Icons.forward_10),
                tooltip: 'Forward 10s',
                onPressed: () => _controller.seek(
                    (_controller.positionMs + 10000).clamp(0, _controller.durationMs)),
              ),
              const SizedBox(width: 16),
            ],
            _buildSyncButton(),
          ],
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

  Widget _buildSyncButton() {
    final isLinked = _videoSync?.isLinked ?? false;
    final syncState = _videoSync?.syncState ?? SyncState.idle;

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
      _stop();
      setState(() {});
      return;
    }

    final settings = context.read<SettingsProvider>();
    final m = settings.mediaSync;

    if (m.activePlayer == VideoPlayerType.none) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No video player configured. Set up in Settings → Media Sync.'),
      ));
      return;
    }

    setState(() => _syncConnecting = true);

    try {
      await _videoSync!.link(
        m.activePlayer,
        heresphereIp: m.hereSphereIp,
        herespherePort: m.hereSpherePort,
        mpcHcIp: m.mpcHcIp,
        mpcHcPort: m.mpcHcPort,
      );
      
      // Ensure the device enters funscript mode
      _setupHardwarePlayback();
      
      // Start the hardware update loop now that we're linked
      _startTickTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sync failed: $e')));
    } finally {
      if (mounted) setState(() => _syncConnecting = false);
    }
  }

  Widget _buildSyncIndicator() {
    final isBeyond = _videoSync?.isVideoBeyondScript ?? false;
    if (!isBeyond) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withOpacity(0.4)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber, size: 16, color: Colors.amber),
          SizedBox(width: 8),
          Text('Video beyond script duration', style: TextStyle(fontSize: 12, color: Colors.amber)),
        ],
      ),
    );
  }

  Widget _buildWaveformPreview() {
    final axes = _bundle?.axes ?? {};
    if (axes.isEmpty) return const SizedBox.shrink();

    final savedAxis = widget.meta?['waveformAxis'] as String? ?? 'volume';
    String selectedAxis = axes.containsKey(savedAxis) ? savedAxis : axes.keys.first;

    final currentScript = axes[selectedAxis];
    if (currentScript == null || currentScript.actions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildWaveformForScript(currentScript, selectedAxis),
      ],
    );
  }

  Widget _buildWaveformForScript(dynamic script, String label) {
    final actions = script.actions;
    final duration = script.durationMs;
    if (duration <= 0 || actions.isEmpty) return const SizedBox.shrink();

    const sampleCount = 200;
    final samples = <double>[];
    for (int i = 0; i < sampleCount; i++) {
      final timeMs = (i * duration) ~/ sampleCount;
      int lo = 0, hi = actions.length - 1;
      while (hi - lo > 1) {
        final mid = (lo + hi) ~/ 2;
        if (actions[mid].at <= timeMs) lo = mid;
        else hi = mid;
      }
      final a = actions[lo], b = actions[hi];
      if (a.at == b.at) samples.add(a.pos / 100.0);
      else {
        final t = (timeMs - a.at) / (b.at - a.at);
        samples.add(((a.pos + t * (b.pos - a.pos)) / 100.0).clamp(0.0, 1.0));
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label Waveform', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SizedBox(
              height: 72,
              child: CustomPaint(
                size: Size.infinite,
                painter: _WaveformPainter(
                  samples: samples,
                  playbackPosition: _controller.progress,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFilenameFromPath(String path) {
    if (path.isEmpty) return "...";
    final uri = Uri.tryParse(path);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.last;
    }
    return path.split('/').last.split('\\').last;
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> samples;
  final double playbackPosition;
  final Color color;

  _WaveformPainter({required this.samples, required this.playbackPosition, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;
    final paint = Paint()..color = color.withOpacity(0.7)..strokeWidth = 1.5..style = PaintingStyle.stroke;
    final path = Path();
    for (int i = 0; i < samples.length; i++) {
      final x = (i / (samples.length - 1)) * size.width;
      final y = size.height - (samples[i] * size.height);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
    final linePaint = Paint()..color = Colors.red..strokeWidth = 2;
    final lineX = playbackPosition.clamp(0.0, 1.0) * size.width;
    canvas.drawLine(Offset(lineX, 0), Offset(lineX, size.height), linePaint);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) => old.playbackPosition != playbackPosition;
}
