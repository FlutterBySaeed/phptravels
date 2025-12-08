import 'package:flutter/material.dart';

class CustomRangeTrackShape extends RangeSliderTrackShape {
  final double activeMin;
  final double activeMax;

  const CustomRangeTrackShape({
    required this.activeMin,
    required this.activeMax,
  });

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset startThumbCenter,
    required Offset endThumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Paint activeTrackPaint = Paint()
      ..color = sliderTheme.activeTrackColor ?? Colors.orange;

    final Paint inactiveTrackPaint = Paint()
      ..color = sliderTheme.inactiveTrackColor ?? Colors.grey.shade300;
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, const Radius.circular(2)),
      inactiveTrackPaint,
    );
    final Rect activeRect = Rect.fromLTRB(
      startThumbCenter.dx,
      trackRect.top,
      endThumbCenter.dx,
      trackRect.bottom,
    );
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(activeRect, const Radius.circular(2)),
      activeTrackPaint,
    );

    // Draw colored dots at division points
    final dotColors = [
      Colors.red, // Poor (0)
      Colors.orange, // Fair (1)
      Colors.green[300]!, // Good (2)
      Colors.green, // Very Good (3)
      Colors.green, // Excellent (4)
    ];

    // Calculate dot positions across FULL track width
    final double trackWidth = trackRect.width;

    for (int i = 0; i < 5; i++) {
      final bool isActive = i >= activeMin.round() && i <= activeMax.round();
      // Position at 0%, 25%, 50%, 75%, 100% of track width
      final double dotX = trackRect.left + (i / 4) * trackWidth;
      final double dotY = trackRect.center.dy;

      // Draw dot
      final Paint dotPaint = Paint()
        ..color = isActive ? dotColors[i] : Colors.grey.shade300
        ..style = PaintingStyle.fill;

      context.canvas.drawCircle(
        Offset(dotX, dotY),
        6,
        dotPaint,
      );

      // Draw white border
      final Paint borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      context.canvas.drawCircle(
        Offset(dotX, dotY),
        6,
        borderPaint,
      );
    }
  }
}
