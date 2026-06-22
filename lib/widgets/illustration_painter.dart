import 'package:flutter/material.dart';
import '../models/onboarding_data.dart';
import '../models/app_colors.dart';

class IllustrationPanel extends StatelessWidget {
  final OnboardingIllustration illustration;
  const IllustrationPanel({super.key, required this.illustration});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.deepBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen2.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CustomPaint(
          painter: IllustrationPainter(type: illustration),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class IllustrationPainter extends CustomPainter {
  final OnboardingIllustration type;
  const IllustrationPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = AppColors.deepBg,
    );

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF1A5035).withOpacity(0.5)
      ..strokeWidth = 0.5;
    for (double x = 0; x < w; x += w / 8) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += h / 6) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    switch (type) {
      case OnboardingIllustration.report:
        _paintReportScene(canvas, size);
      case OnboardingIllustration.monitor:
        _paintMonitorScene(canvas, size);
      case OnboardingIllustration.check:
        _paintCheckScene(canvas, size);
    }
  }

  // ── Slide 1: Phone + form ──────────────────────────────────────────────
  void _paintReportScene(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.5),
            width: w * 0.45,
            height: h * 0.72),
        const Radius.circular(22),
      ),
      Paint()..color = const Color(0xFF1A4A2E),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.495),
            width: w * 0.37,
            height: h * 0.60),
        const Radius.circular(14),
      ),
      Paint()..color = AppColors.screenBg,
    );

    // Status bar
    canvas.drawRect(
      Rect.fromLTWH(w * 0.315, h * 0.185, w * 0.37, h * 0.04),
      Paint()..color = const Color(0xFF1E5A38),
    );

    // Form fields
    final fieldPaint = Paint()..color = const Color(0xFF1E5A38);
    for (int i = 0; i < 4; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.325, h * (0.245 + i * 0.095), w * 0.35, h * 0.065),
          const Radius.circular(6),
        ),
        fieldPaint,
      );
    }

    // Photo placeholder
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.325, h * 0.625, w * 0.155, h * 0.09),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF2A7A4C),
    );

    // Submit button
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.325, h * 0.73, w * 0.35, h * 0.055),
        const Radius.circular(8),
      ),
      Paint()..color = AppColors.lightGreen,
    );

    canvas.drawCircle(
      Offset(w * 0.73, h * 0.25),
      w * 0.04,
      Paint()..color = AppColors.lightGreen,
    );
  }

  // ── Slide 2: Tablet dashboard ──────────────────────────────────────────
  void _paintMonitorScene(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Tablet frame
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.48),
            width: w * 0.78,
            height: h * 0.62),
        const Radius.circular(16),
      ),
      Paint()..color = const Color(0xFF1C4A30),
    );

    // Screen
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.46),
            width: w * 0.68,
            height: h * 0.50),
        const Radius.circular(10),
      ),
      Paint()..color = AppColors.screenBg,
    );

    // Header bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.16, h * 0.215, w * 0.68, h * 0.06),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF2A6B44),
    );

    // Sidebar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.16, h * 0.275, w * 0.16, h * 0.39),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF173D28),
    );

    // Sidebar menu items
    final menuPaint = Paint()..color = const Color(0xFF2E7A50);
    for (int i = 0; i < 5; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.175, h * (0.29 + i * 0.065), w * 0.12, h * 0.025),
          const Radius.circular(3),
        ),
        menuPaint,
      );
    }

    // Content cards
    final cardPaint = Paint()..color = AppColors.cardBg;
    for (final p in [
      [0.34, 0.275, 0.235, 0.115],
      [0.585, 0.275, 0.235, 0.115],
      [0.34, 0.415, 0.48, 0.24],
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * p[0], h * p[1], w * p[2], h * p[3]),
          const Radius.circular(6),
        ),
        cardPaint,
      );
    }

    // Bar chart
    final barPaint = Paint()..color = AppColors.lightGreen;
    for (int i = 0; i < [0.07, 0.12, 0.09, 0.14, 0.10, 0.13].length; i++) {
      final bh = h * [0.07, 0.12, 0.09, 0.14, 0.10, 0.13][i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * (0.355 + i * 0.068), h * 0.655 - bh, w * 0.038, bh),
          const Radius.circular(3),
        ),
        barPaint,
      );
    }

    // Tablet stand
    final standPath = Path()
      ..moveTo(w * 0.42, h * 0.80)
      ..lineTo(w * 0.38, h * 0.92)
      ..lineTo(w * 0.62, h * 0.92)
      ..lineTo(w * 0.58, h * 0.80)
      ..close();
    canvas.drawPath(standPath, Paint()..color = const Color(0xFF1C4A30));
    canvas.drawRect(
      Rect.fromLTWH(w * 0.34, h * 0.91, w * 0.32, h * 0.025),
      Paint()..color = const Color(0xFF2A6040),
    );
  }

  // ── Slide 3: Checkmark + timeline ─────────────────────────────────────
  void _paintCheckScene(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawCircle(
      Offset(w * 0.5, h * 0.44),
      w * 0.24,
      Paint()..color = AppColors.cardBg,
    );
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.44),
      w * 0.17,
      Paint()..color = const Color(0xFF237A4C),
    );

    final checkPaint = Paint()
      ..color = AppColors.accentGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.41, h * 0.44)
        ..lineTo(w * 0.48, h * 0.51)
        ..lineTo(w * 0.60, h * 0.38),
      checkPaint,
    );

    final linePaint = Paint()
      ..color = const Color(0xFF2E7A50)
      ..strokeWidth = 1.5;
    final dotColors = [
      AppColors.lightGreen,
      AppColors.lightGreen,
      AppColors.lightGreen,
      const Color(0xFF1C4A30),
    ];
    for (int i = 0; i < 4; i++) {
      final cy = h * (0.72 + i * 0.065);
      canvas.drawCircle(Offset(w * 0.22, cy), 5, Paint()..color = dotColors[i]);
      if (i < 3) {
        canvas.drawLine(
          Offset(w * 0.22, cy + 5),
          Offset(w * 0.22, cy + h * 0.065 - 5),
          linePaint,
        );
      }
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.3, cy - 6, w * 0.48, 12),
          const Radius.circular(4),
        ),
        Paint()..color = AppColors.cardBg,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
