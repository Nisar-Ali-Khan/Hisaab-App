import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ComplianceRing extends StatelessWidget {
  final double percentage; // 0-100
  final double size;

  const ComplianceRing({super.key, required this.percentage, this.size = 180});

  Color _getRingColor(BuildContext context) {
    if (percentage >= 80) return context.colors.teal;
    if (percentage >= 60) return context.colors.gold;
    return context.colors.rose;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(percentage: percentage, color: _getRingColor(context), context: context),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${percentage.toStringAsFixed(0)}%', style: AppText.display(context, size: 32)),
              const SizedBox(height: 2),
              Text('via approved\nchannels', textAlign: TextAlign.center, style: AppText.body(context, size: 11, color: context.colors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final BuildContext context;
  _RingPainter({required this.percentage, required this.color, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    final trackPaint = Paint()
      ..color = context.colors.creamDeep
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final sweep = 2 * pi * (percentage.clamp(0, 100) / 100);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, sweep, false, progressPaint);

    // 80% threshold marker.
    final markerAngle = -pi / 2 + 2 * pi * 0.8;
    final markerOuter = Offset(center.dx + radius * cos(markerAngle), center.dy + radius * sin(markerAngle));
    final markerPaint = Paint()..color = context.colors.ink;
    canvas.drawCircle(markerOuter, 3, markerPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}
