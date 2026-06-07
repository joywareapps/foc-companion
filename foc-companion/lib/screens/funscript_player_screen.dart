import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:foc_companion/services/funscript_bundle_loader.dart';
import 'package:foc_companion/services/funscript_playback_controller.dart';
import 'package:foc_companion/services/app_logger.dart';
import 'package:foc_companion/models/funscript_bundle.dart';

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

  @override
  void initState() {
    super.initState();
    _loadBundle();
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _controller.stop();
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
      _controller.tick();
    });
  }

  void _stopTickTimer() {
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  void _play() {
    _controller.play();
    _startTickTimer();
  }

  void _pause() {
    _controller.pause();
    _stopTickTimer();
  }

  void _stop() {
    _controller.stop();
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
                const SizedBox(height: 24),

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
      onChangeEnd: (_) {
        if (_controller.state == PlaybackState.playing) {
          _controller.play(); // Reset tick timer after seek
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

  Widget _buildTransportControls() {
    final state = _controller.state;
    final isPlaying = state == PlaybackState.playing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Skip back 10s
        IconButton(
          icon: const Icon(Icons.replay_10),
          tooltip: 'Back 10s',
          onPressed: () => _controller.seek(
              (_controller.positionMs - 10000).clamp(0, _controller.durationMs)),
        ),
        const SizedBox(width: 16),
        // Loop toggle
        IconButton(
          icon: Icon(Icons.repeat,
              color: _controller.loop ? Theme.of(context).colorScheme.primary : null),
          tooltip: 'Loop',
          onPressed: () => _controller.setLoop(!_controller.loop),
        ),
        const SizedBox(width: 16),
        // Play / Pause
        FloatingActionButton.large(
          onPressed: isPlaying ? _pause : _play,
          backgroundColor:
              isPlaying ? Theme.of(context).colorScheme.secondary : null,
          child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 32),
        ),
        const SizedBox(width: 16),
        // Stop
        IconButton(
          icon: const Icon(Icons.stop),
          tooltip: 'Stop',
          onPressed: _stop,
        ),
        const SizedBox(width: 16),
        // Skip forward 10s
        IconButton(
          icon: const Icon(Icons.forward_10),
          tooltip: 'Forward 10s',
          onPressed: () => _controller.seek(
              (_controller.positionMs + 10000).clamp(0, _controller.durationMs)),
        ),
      ],
    );
  }

  Widget _buildWaveformPreview() {
    // Show a simplified waveform of the alpha axis (most common)
    final alphaScript = _bundle?.axes['alpha'];
    if (alphaScript == null || alphaScript.actions.isEmpty) {
      // Try beta as fallback
      final betaScript = _bundle?.axes['beta'];
      if (betaScript == null || betaScript.actions.isEmpty) return const SizedBox.shrink();
      return _buildWaveformForScript(betaScript, 'Beta');
    }
    return _buildWaveformForScript(alphaScript, 'Alpha');
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
