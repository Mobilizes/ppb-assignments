import 'dart:ui';
import 'package:flutter/material.dart';

class ScopePainter extends CustomPainter {
  final List<double> channel;

  ScopePainter({required this.channel});

  @override
  void paint(Canvas canvas, Size size) {
    final sectionHeight = size.height;

    final paint = Paint()
      ..color = Colors.blue
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
