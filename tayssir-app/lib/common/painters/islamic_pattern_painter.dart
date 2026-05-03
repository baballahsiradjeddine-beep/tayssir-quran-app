import 'dart:math' as math;
import 'package:flutter/material.dart';

class IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double spacing;
  final double starRadius;

  IslamicPatternPainter({
    this.color = Colors.white,
    this.opacity = 0.08,
    this.spacing = 35.0,
    this.starRadius = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        _drawSmallStar(canvas, Offset(x, y), starRadius, paint);
      }
    }
  }

  void _drawSmallStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    final double innerRadius = radius * 0.4;
    
    for (int i = 0; i < 16; i++) {
      double angle = (i * 22.5) * math.pi / 180;
      double r = i.isEven ? radius : innerRadius;
      double x = center.dx + r * math.cos(angle);
      double y = center.dy + r * math.sin(angle);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant IslamicPatternPainter oldDelegate) => 
    color != oldDelegate.color || 
    opacity != oldDelegate.opacity || 
    spacing != oldDelegate.spacing || 
    starRadius != oldDelegate.starRadius;
}
