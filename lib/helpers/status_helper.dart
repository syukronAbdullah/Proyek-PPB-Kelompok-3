import 'package:flutter/material.dart';

class StatusHelper {
  static const String menunggu = 'menunggu';
  static const String diproses = 'diproses';
  static const String selesai = 'selesai';
  static const String ditolak = 'ditolak';

  static String normalize(String status) {
    return status.toLowerCase().trim();
  }

  static String getLabel(String status) {
    switch (normalize(status)) {
      case menunggu:
        return 'Menunggu';
      case diproses:
        return 'Diproses';
      case selesai:
        return 'Selesai';
      case ditolak:
        return 'Ditolak';
      default:
        return status;
    }
  }

  static Color getColor(String status) {
    switch (normalize(status)) {
      case menunggu:
        return const Color(0xFFE07B00);
      case diproses:
        return const Color(0xFF1565C0);
      case selesai:
        return const Color(0xFF1A6B3A);
      case ditolak:
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF64748B);
    }
  }

  static Color getBackgroundColor(String status) {
    switch (normalize(status)) {
      case menunggu:
        return const Color(0xFFFFF4E5);
      case diproses:
        return const Color(0xFFE8F1FF);
      case selesai:
        return const Color(0xFFEAF7EF);
      case ditolak:
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  static IconData getIcon(String status) {
    switch (normalize(status)) {
      case menunggu:
        return Icons.hourglass_empty_rounded;
      case diproses:
        return Icons.sync_rounded;
      case selesai:
        return Icons.check_circle_rounded;
      case ditolak:
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  static bool isFinal(String status) {
    final normalized = normalize(status);
    return normalized == selesai || normalized == ditolak;
  }

  static bool canEdit(String status) {
    return normalize(status) == menunggu;
  }

  static bool canDelete(String status) {
    return normalize(status) == menunggu;
  }

  StatusHelper._();
}