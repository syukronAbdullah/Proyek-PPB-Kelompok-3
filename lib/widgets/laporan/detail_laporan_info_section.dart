import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class DetailLaporanInfoSection extends StatelessWidget {
  final String status;
  final String categoryName;
  final String title;
  final String location;
  final String description;
  final Widget photoSection;

  const DetailLaporanInfoSection({
    super.key,
    required this.status,
    required this.categoryName,
    required this.title,
    required this.location,
    required this.description,
    required this.photoSection,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailStatusBadge(status: status),
        const SizedBox(height: 16),
        photoSection,
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.mutedBackground,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            categoryName,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.slateTextSecondary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.slateTextPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: AppColors.success,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                location,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.slateTextSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'DESKRIPSI',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.slateTextSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.slateTextBody,
            height: 1.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _DetailStatusBadge extends StatelessWidget {
  final String status;

  const _DetailStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: colors.foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(_statusLabel(status)),
        ],
      ),
    );
  }

  _StatusColors _statusColors(String status) {
    if (status == 'menunggu') {
      return const _StatusColors(
        foreground: AppColors.warning,
        background: Color(0xFFFFF3E0),
      );
    } else if (status == 'diproses') {
      return const _StatusColors(
        foreground: AppColors.info,
        background: Color(0xFFE3F2FD),
      );
    } else if (status == 'selesai') {
      return const _StatusColors(
        foreground: AppColors.success,
        background: Color(0xFFE8F5EE),
      );
    } else if (status == 'ditolak') {
      return const _StatusColors(
        foreground: AppColors.danger,
        background: Color(0xFFFEF2F2),
      );
    }

    return const _StatusColors(
      foreground: Colors.grey,
      background: AppColors.mutedBackground,
    );
  }

  String _statusLabel(String status) {
    if (status == 'menunggu') {
      return 'Menunggu';
    } else if (status == 'diproses') {
      return 'Diproses';
    } else if (status == 'selesai') {
      return 'Selesai';
    } else if (status == 'ditolak') {
      return 'Ditolak';
    }

    return status;
  }
}

class _StatusColors {
  final Color foreground;
  final Color background;

  const _StatusColors({required this.foreground, required this.background});
}
