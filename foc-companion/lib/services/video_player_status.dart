/// Normalized status from any video player backend (HereSphere, MPC-HC, etc.).
///
/// All video player services produce this type so that [VideoSyncController]
/// can treat them uniformly without knowing the underlying protocol.
class VideoPlayerStatus {
  final bool connected;
  final bool isPlaying;
  final double currentTimeMs;
  final double durationMs;
  final String? filePath;
  final double playbackSpeed;

  const VideoPlayerStatus({
    this.connected = false,
    this.isPlaying = false,
    this.currentTimeMs = 0,
    this.durationMs = 0,
    this.filePath,
    this.playbackSpeed = 1.0,
  });

  const VideoPlayerStatus.disconnected()
      : connected = false,
        isPlaying = false,
        currentTimeMs = 0,
        durationMs = 0,
        filePath = null,
        playbackSpeed = 1.0;

  @override
  String toString() =>
      'VideoPlayerStatus(connected: $connected, playing: $isPlaying, '
      'time: ${currentTimeMs.toInt()}ms / ${durationMs.toInt()}ms, '
      'file: $filePath, speed: $playbackSpeed)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoPlayerStatus &&
          connected == other.connected &&
          isPlaying == other.isPlaying &&
          currentTimeMs == other.currentTimeMs &&
          durationMs == other.durationMs &&
          filePath == other.filePath &&
          playbackSpeed == other.playbackSpeed;

  @override
  int get hashCode => Object.hash(
        connected,
        isPlaying,
        currentTimeMs,
        durationMs,
        filePath,
        playbackSpeed,
      );
}
