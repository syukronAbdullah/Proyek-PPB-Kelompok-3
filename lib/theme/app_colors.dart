import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // =====================================================
  // Brand
  // =====================================================

  static const Color primary = Color(0xFF0D4A28);
  static const Color primaryAction = Color(0xFF1A5E35);
  static const Color primaryDark = Color(0xFF0B3020);
  static const Color primaryLight = Color(0xFF3DAA6A);

  // =====================================================
  // Gradient
  // =====================================================

  static const Color gradientStart = Color(0xFF0D4A28);
  static const Color gradientEnd = Color(0xFF1A6B3A);

  // =====================================================
  // Background
  // =====================================================

  static const Color background = Colors.white;
  static const Color pageBackground = Color(0xFFF8FAFC);
  static const Color mutedBackground = Color(0xFFF1F5F9);
  static const Color cardBackground = Color(0xFF1A5038);

  // =====================================================
  // Text
  // =====================================================

  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black38;
  static const Color slateTextPrimary = Color(0xFF1E293B);
  static const Color slateTextSecondary = Color(0xFF64748B);
  static const Color slateTextMuted = Color(0xFF94A3B8);
  static const Color slateTextBody = Color(0xFF334155);
  static const Color slateTextDisabled = Color(0xFFCBD5E1);

  // =====================================================
  // Border
  // =====================================================

  static const Color border = Color(0xFFE0E0E0);
  static const Color borderSoft = Color(0xFFE2E8F0);
  static const Color inputBackground = Color(0xFFF7F7F7);
  static const Color inputBorder = Color(0xFFE5E5E5);

  // =====================================================
  // Status
  // =====================================================

  static const Color error = Colors.redAccent;
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF1565C0);
  static const Color success = Color(0xFF1A6B3A);
  static const Color warning = Color(0xFFE07B00);
  static const Color disabled = Colors.grey;

  // =====================================================
  // Accent
  // =====================================================

  static const Color accent = Color(0xFF6DDBA0);
  static const Color icon = Color(0xFF1E7A44);

  // =====================================================
  // Common
  // =====================================================

  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // =====================================================
  // Backward Compatibility
  // (sementara agar kode lama tetap jalan)
  // =====================================================

  static const Color darkGreen1 = primary;
  static const Color darkGreen2 = gradientEnd;

  static const Color midGreen = Color(0xFF2E8B57);
  static const Color lightGreen = primaryLight;

  static const Color deepBg = primaryDark;
  static const Color cardBg = cardBackground;
  static const Color screenBg = primaryDark;

  static const Color iconGreen = icon;
  static const Color accentGreen = accent;
}
