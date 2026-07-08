import 'package:flutter/material.dart';

class AdminLatestLaporanSection extends StatelessWidget {
  final List<dynamic> laporanList;
  final VoidCallback onViewAll;
  final Widget Function(dynamic laporan) itemBuilder;

  const AdminLatestLaporanSection({
    super.key,
    required this.laporanList,
    required this.onViewAll,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final latestItems = laporanList.take(5).toList();

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
                    padding: const EdgeInsets.only(bottom: 10),
                    child: itemBuilder(item),
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
      ),
      child: const Center(
        child: Text(
          'Belum ada laporan masuk',
          style: TextStyle(
            color: Colors.black45,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}