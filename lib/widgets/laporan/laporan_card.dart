import 'package:flutter/material.dart';

import '../../models/laporan_model.dart';
import 'status_badge.dart';

class LaporanCard extends StatelessWidget {
  final LaporanModel laporan;
  final VoidCallback? onTap;

  const LaporanCard({
    super.key,
    required this.laporan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 10),
              Text(
                laporan.judul,
                style: const TextStyle(
                  fontSize: 15,
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
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    laporan.waktu,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Detail ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A6B3A),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: Color(0xFF1A6B3A),
                  ),
                ],
              ),
            ],
          ),
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
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        categoryName.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }
}