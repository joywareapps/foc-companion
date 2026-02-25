import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foc_companion/models/settings_models.dart';
import 'package:foc_companion/providers/device_provider.dart';
import 'package:foc_companion/core/patterns.dart';
import 'package:foc_companion/screens/control_screen.dart';
import 'package:foc_companion/screens/device_settings_screen.dart';
import 'package:foc_companion/screens/pulse_settings_screen.dart';
// import 'package:foc_companion/screens/media_sync_screen.dart';  // hidden — re-enable with Media tab
import 'package:foc_companion/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _showCalibration = false;

  static const List<Widget> _pages = <Widget>[
    ControlScreen(),
    PulseSettingsScreen(),
    // MediaSyncScreen(),  // hidden for now — re-enable by restoring this line and its NavigationDestination
    SettingsScreen(),
  ];

  void _showDiagnosticDialog(BuildContext context, DeviceProvider device) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Consumer<DeviceProvider>(
          builder: (context, device, _) {
            final error = device.lastErrorMessage;
            final isCapturing = device.isRecordingLogs;

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Hardware Error"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(error ?? "Unknown Error",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (isCapturing) ...[
                    const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text("Capturing diagnostic data...",
                            style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ] else
                    const Text(
                      "Diagnostic data captured. You can share this log with the developers.",
                      style: TextStyle(fontSize: 13),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    "Messages captured: ${device.capturedLogs.length} / 1000",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isCapturing
                      ? null
                      : () {
                          device.clearLogs();
                          Navigator.of(context).pop();
                        },
                  child: const Text("Dismiss"),
                ),
                FilledButton.icon(
                  onPressed: isCapturing ? null : () => device.shareLogs(),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text("Share Log"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceProvider>(
      builder: (context, device, _) {
        final isConnected = device.api.isConnected;
        final is4Phase = device.deviceMode == DeviceMode.fourPhase;

        // Auto-reset calibration view when device disconnects unexpectedly
        if (!isConnected && _showCalibration) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _showCalibration = false);
          });
        }

        // Show diagnostic dialog if error detected
        if (device.lastErrorMessage != null && !device.isShowingErrorDialog) {
          device.isShowingErrorDialog = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showDiagnosticDialog(context, device);
          });
        }

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: isConnected ? 64 : kToolbarHeight,
            title: isConnected
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (device.isSlowConnection)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.amber,
                                size: 16,
                              ),
                            ),
                          Flexible(
                            child: Text(
                              device.connectionStatus,
                              style: Theme.of(context).textTheme.titleSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Temp: ${device.temperature}  ·  Bat: ${device.batteryVoltage}"
                        "${device.batterySoc != null ? ' (${(device.batterySoc! > 1.0 ? device.batterySoc! : device.batterySoc! * 100).toStringAsFixed(0)}%)' : ''}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  )
                : Text(device.connectionStatus),
            actions: isConnected
                ? [
                    IconButton(
                      icon: Icon(
                        Icons.tune,
                        color: _showCalibration
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      tooltip: _showCalibration ? 'Close Calibration' : 'Calibration',
                      onPressed: () =>
                          setState(() => _showCalibration = !_showCalibration),
                    ),
                    IconButton(
                      icon: const Icon(Icons.power_off),
                      tooltip: 'Disconnect',
                      style: IconButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () {
                        setState(() => _showCalibration = false);
                        device.disconnect();
                      },
                    ),
                  ]
                : null,
          ),
          body: isConnected && _showCalibration
              ? const DeviceSettingsScreen()
              : _pages.elementAt(_selectedIndex),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isConnected)
                _showCalibration
                    ? _CalibrationCloseBar(
                        onClose: () =>
                            setState(() => _showCalibration = false),
                      )
                    : _PlayBar(device: device, is4Phase: is4Phase),
              NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (i) => setState(() {
                  _selectedIndex = i;
                  _showCalibration = false;
                }),
                destinations: const <NavigationDestination>[
                  NavigationDestination(
                    icon: Icon(Icons.play_circle_outline),
                    label: 'Control',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.electric_bolt),
                    label: 'Pulse',
                  ),
                  // NavigationDestination(icon: Icon(Icons.sync), label: 'Media'),  // hidden
                  NavigationDestination(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
// Calibration close bar — replaces play bar while calibration is open.
// Mirrors the play bar height/style so the layout doesn't shift.
// ─────────────────────────────────────────────────────────

class _CalibrationCloseBar extends StatelessWidget {
  final VoidCallback onClose;

  const _CalibrationCloseBar({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
      child: Row(
        children: [
          Icon(Icons.tune, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Calibration',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
            onPressed: onClose,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Persistent play bar — always visible above NavigationBar
// when connected.
//
//  Stopped:  [▶ Start <pattern name>          ] (green, full width)
//  Running:  [——— volume slider ———] [■]    (slider + stop icon)
// ─────────────────────────────────────────────────────────

class _PlayBar extends StatelessWidget {
  final DeviceProvider device;
  final bool is4Phase;

  const _PlayBar({required this.device, required this.is4Phase});

  String get _patternName {
    if (is4Phase) {
      final p = FourphasePatternRegistry.all;
      return p[device.cockpit4Phase.patternIndex.clamp(0, p.length - 1)].name;
    } else {
      final p = ThreephasePatternRegistry.all;
      return p[device.cockpit.patternIndex.clamp(0, p.length - 1)].name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (device.isLoopRunning) {
      // ── Running: volume slider (0–100%) + stop button ──
      final vol = device.volume;
      final boxVol = device.boxVolume;
      final totalVol = vol * boxVol;

      return Container(
        color: colorScheme.surfaceContainerHighest,
        child: Stack(
          children: [
            // VU-meter background fill
            Positioned.fill(
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: totalVol.clamp(0.0, 1.0),
                child: Container(
                  color: colorScheme.primary.withAlpha(40),
                ),
              ),
            ),
            // Foreground content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                                                  Text(
                                                    'App: ${(vol * 100).round()}%',
                                                    style: Theme.of(context).textTheme.labelMedium,
                                                  ),
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        device.isHardwareVolumeLocked
                                                            ? Icons.lock
                                                            : Icons.lock_open,
                                                        size: 14,
                                                        color: device.isHardwareVolumeLocked
                                                            ? Colors.orange
                                                            : colorScheme.onSurfaceVariant,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Box: ${(boxVol * 100).round()}%',
                                                        style: Theme.of(context).textTheme.labelMedium,
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                            
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                'Total: ${(totalVol * 100).round()}%',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: vol,
                          min: 0.0,
                          max: 1.0,
                          onChanged: (v) => device.setVolume(v),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filled(
                    icon: const Icon(Icons.stop),
                    tooltip: 'Stop',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: device.toggleLoop,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // ── Stopped: Start button ──
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: FilledButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: Text('Start $_patternName'),
          onPressed: device.toggleLoop,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green,
            minimumSize: const Size.fromHeight(44),
          ),
        ),
      );
    }
  }
}
