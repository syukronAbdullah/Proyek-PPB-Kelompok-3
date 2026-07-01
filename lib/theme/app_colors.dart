import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // =====================================================
  // Brand
  // =====================================================

  static const Color primary = Color(0xFF0D4A28);
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
  static const Color cardBackground = Color(0xFF1A5038);

  // =====================================================
  // Text
  // =====================================================

  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black38;

  // =====================================================
  // Border
  // =====================================================

  static const Color border = Color(0xFFE0E0E0);

  // =====================================================
  // Status
  // =====================================================

  static const Color error = Colors.redAccent;
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