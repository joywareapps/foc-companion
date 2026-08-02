import 'package:flutter/material.dart';
import 'package:foc_companion/providers/device_provider.dart';

/// Volume bar showing App/Box/Total volume percentages with a slider,
/// plus a background fill indicating potential vs. actual (sensor-modulated)
/// volume. Shared between the pattern play bar and the funscript player.
class VolumeBar extends StatelessWidget {
  final DeviceProvider device;
  final Widget? trailing;

  const VolumeBar({super.key, required this.device, this.trailing});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final vol = device.volume;
    final boxVol = device.boxVolume;
    final sensorMult = device.sensorMultiplier;
    final potentialVol = vol * boxVol;
    final actualVol = potentialVol * sensorMult;

    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Stack(
        children: [
          // Base layer: Potential volume (less saturated/semi-transparent)
          Positioned.fill(
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: potentialVol.clamp(0.0, 1.0),
              child: Container(
                color: colorScheme.primary.withAlpha(20),
              ),
            ),
          ),
          // Top layer: Actual volume modified by sensor (opaque)
          Positioned.fill(
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: actualVol.clamp(0.0, 1.0),
              child: Container(
                color: colorScheme.primary.withAlpha(80),
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
                              Tooltip(
                                message: device.isPotLocked
                                    ? 'Hardware volume locked'
                                    : 'Hardware volume unlocked',
                                child: Icon(
                                  device.isPotLocked
                                      ? Icons.lock
                                      : Icons.lock_open,
                                  size: 18,
                                  color: device.isPotLocked
                                      ? Colors.orange
                                      : colorScheme.onSurfaceVariant,
                                ),
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
                              'Total: ${(actualVol * 100).round()}%',
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
                if (trailing != null) ...[
                  trailing!,
                  const SizedBox(width: 4),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
