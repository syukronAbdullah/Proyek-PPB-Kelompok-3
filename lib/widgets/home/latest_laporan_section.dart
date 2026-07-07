import 'package:flutter/material.dart';

import '../../models/laporan_model.dart';
import '../laporan/status_badge.dart';

class LatestLaporanSection extends StatelessWidget {
  final List<LaporanModel> laporanList;
  final VoidCallback onViewAll;
  final ValueChanged<LaporanModel> onTapItem;

  const LatestLaporanSection({
    super.key,
    required this.laporanList,
    required this.onViewAll,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    final latestItems = laporanList.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(onViewAll: onViewAll),
        const SizedBox(height: 12),
        latestItems.isEmpty
            ? const _EmptyLatestLaporan()
            : Column(
                children: latestItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LatestLaporanTile(
                      laporan: item,
                      onTap: () => onTapItem(item),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final VoidCallback onViewAll;

  const _SectionHeader({
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Laporan Terbaru',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111111),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onViewAll,
          child: const Text(
            'Lihat Semua',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF1A6B3A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyLatestLaporan extends StatelessWidget {
  const _EmptyLatestLaporan();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: const Center(
        child: Text(
          'Belum ada laporan',
          style: TextStyle(
            color: Colors.black45,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _LatestLaporanTile extends StatelessWidget {
  final LaporanModel laporan;
  final VoidCallback onTap;

  const _LatestLaporanTile({
    required this.laporan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = laporan.status.toLowerCase();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CategoryBadge(categoryName: laporan.namaKategori),
                const Spacer(),
                StatusBadge(
                  status: laporan.status,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              laporan.judul,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(
              height: 1,
              thickness: 0.8,
              color: Color(0xFFE2E8F0),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  status == 'selesai'
                      ? Icons.calendar_today_outlined
                      : Icons.access_time_rounded,
                  size: 14,
                  color: const Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Text(
                  laporan.waktu,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String categoryName;

  const _CategoryBadge({
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        categoryName.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF64748B),
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}