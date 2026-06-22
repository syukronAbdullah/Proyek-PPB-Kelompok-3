import 'package:flutter/material.dart';

class SpeakerIconPainter extends CustomPainter {
  final Color color;
  const SpeakerIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Megaphone body
    final megaPath = Path()
      ..moveTo(w * 0.38, h * 0.28)
      ..lineTo(w * 0.72, h * 0.06)
      ..lineTo(w * 0.72, h * 0.88)
      ..lineTo(w * 0.38, h * 0.72)
      ..close();
    canvas.drawPath(megaPath, paint);

    // Speaker box
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.14, h * 0.30, w * 0.24, h * 0.38),
        const Radius.circular(4),
      ),
      paint,
    );

    // Handle
    final handlePath = Path()
      ..moveTo(w * 0.22, h * 0.68)
      ..lineTo(w * 0.17, h * 0.95)
      ..lineTo(w * 0.30, h * 0.95)
      ..lineTo(w * 0.36, h * 0.68)
      ..close();
    canvas.drawPath(handlePath, paint);

    // Sound waves
    final wavePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.82, h * 0.50),
        width: w * 0.22,
        height: h * 0.34,
      ),
      -0.6, 1.2, false, wavePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.82, h * 0.50),
        width: w * 0.38,
        height: h * 0.54,
      ),
      -0.65, 1.3, false, wavePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
