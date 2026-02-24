import 'package:flutter/material.dart';

/// Paints the full slider track as a horizontal linear gradient,
/// ignoring the active/inactive split used by the default track shape.
class GradientSliderTrackShape extends RoundedRectSliderTrackShape {
  final Color startColor;
  final Color endColor;

  const GradientSliderTrackShape({
    required this.startColor,
    required this.endColor,
  });

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final paint = Paint()
      ..shader =
          LinearGradient(colors: [startColor, endColor]).createShader(trackRect);

    final radius = Radius.circular(trackRect.height / 2);
    context.canvas.drawRRect(
      RRect.fromRectAndCorners(
        trackRect,
        topLeft: radius,
        bottomLeft: radius,
        topRight: radius,
        bottomRight: radius,
      ),
      paint,
    );
  }
}
