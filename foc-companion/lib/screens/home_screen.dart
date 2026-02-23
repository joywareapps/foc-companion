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
      final volPct = (vol * 100).round();

      return Container(
        color: colorScheme.surfaceContainerHighest,
        padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Volume $volPct%',
                    style: Theme.of(context).textTheme.labelMedium,
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
