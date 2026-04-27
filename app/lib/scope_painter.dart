import 'dart:ui';
import 'package:flutter/material.dart';

class ScopePainter extends CustomPainter {
  final List<double> channel;
  final Color lineColor;

  ScopePainter({required this.channel, this.lineColor = Colors.blue});

  @override
  void paint(Canvas canvas, Size size) {
    final sectionHeight = size.height;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    List<Offset> points = [];

    if (channel.isEmpty) return;

    double xStep = size.width / channel.length;

    for (int i = 0; i < channel.length; i++) {
      double x = i * xStep;

      double y = sectionHeight - (channel[i] * sectionHeight);
      points.add(Offset(x, y));
    }

    canvas.drawPoints(PointMode.polygon, points, paint);
  }

  @override
  bool shouldRepaint(covariant ScopePainter oldDelegate) => true;
}
