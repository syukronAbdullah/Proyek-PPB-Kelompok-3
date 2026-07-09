import 'package:flutter/material.dart';

import '../../models/laporan_model.dart';
import '../../theme/app_colors.dart';

class DetailLaporanTimeline extends StatelessWidget {
  final LaporanModel laporan;
  final String currentStatus;

  const DetailLaporanTimeline({
    super.key,
    required this.laporan,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Timeline Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.slateTextPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _TimelineNode(
            title: 'Laporan Dibuat',
            subtitle:
                'Laporan Anda telah berhasil masuk ke sistem SILAPOR UIN.',
            time: laporan.waktu,
            isDone: true,
            isActive: currentStatus == 'menunggu',
          ),
          if (currentStatus == 'ditolak') ...[
            _TimelineNode(
              title: 'Ditolak',
              subtitle:
                  laporan.catatanAdmin != null &&
                      laporan.catatanAdmin!.isNotEmpty
                  ? laporan.catatanAdmin!
                  : 'Laporan ditolak oleh admin.',
              time: laporan.waktu,
              isDone: true,
              isActive: true,
              isRejected: true,
              isLast: true,
              adminNote: laporan.catatanAdmin,
            ),
          ] else ...[
            _TimelineNode(
              title: 'Sedang Diproses',
              subtitle:
                  'Tim IT/Sarpras sedang menuju lokasi untuk pengecekan infrastruktur.',
              time: currentStatus != 'menunggu' ? laporan.waktu : '',
              isDone: currentStatus == 'diproses' || currentStatus == 'selesai',
              isActive: currentStatus == 'diproses',
              adminNote: laporan.catatanAdmin,
            ),
            _TimelineNode(
              title: 'Selesai',
              subtitle: currentStatus == 'selesai'
                  ? 'Laporan selesai diatasi oleh unit terkait.'
                  : 'Status akan diperbarui setelah masalah berhasil diatasi oleh unit terkait.',
              time: currentStatus == 'selesai'
                  ? laporan.waktu
                  : 'Belum Selesai',
              isDone: currentStatus == 'selesai',
              isActive: currentStatus == 'selesai',
              isLast: true,
            ),
          ],
          const SizedBox(height: 12),
          const _InfoTambahanCard(),
        ],
      ),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final bool isDone;
  final bool isActive;
  final bool isLast;
  final bool isRejected;
  final String? adminNote;

  const _TimelineNode({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isDone,
    required this.isActive,
    this.isLast = false,
    this.isRejected = false,
    this.adminNote,
  });

  @override
  Widget build(BuildContext context) {
    final nodeColor = _nodeColor();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isActive
                      ? nodeColor.withValues(alpha: 0.2)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: nodeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppColors.borderSoft),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isActive
                              ? FontWeight.w800
                              : FontWeight.w700,
                          color: AppColors.slateTextPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: time == 'Belum Selesai'
                              ? AppColors.slateTextMuted
                              : AppColors.slateTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.slateTextSecondary,
                      height: 1.4,
                    ),
                  ),
                  if (adminNote != null && adminNote!.isNotEmpty && isDone) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.pageBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderSoft),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.supervised_user_circle_outlined,
                            size: 18,
                            color: AppColors.info,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '"$adminNote"',
                              style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: AppColors.slateTextBody,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _nodeColor() {
    if (isRejected) {
      return AppColors.danger;
    } else if (isDone) {
      return isActive ? AppColors.info : AppColors.success;
    }

    return AppColors.slateTextDisabled;
  }
}

class _InfoTambahanCard extends StatelessWidget {
  const _InfoTambahanCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF8EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE6C1)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Tambahan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB45309),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Estimasi waktu penyelesaian adalah 2-3 hari kerja tergantung tingkat kerusakan perangkat.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB45309),
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
