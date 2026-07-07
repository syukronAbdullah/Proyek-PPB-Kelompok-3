import 'package:flutter/material.dart';

import '../common/stat_card.dart';

class HomeStatsRow extends StatelessWidget {
  final int total;
  final int menunggu;
  final int selesai;
  final VoidCallback onTapTotal;
  final VoidCallback onTapMenunggu;
  final VoidCallback onTapSelesai;

  const HomeStatsRow({
    super.key,
    required this.total,
    required this.menunggu,
    required this.selesai,
    required this.onTapTotal,
    required this.onTapMenunggu,
    required this.onTapSelesai,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StatCard(
          label: 'Total',
          value: '$total',
          color: const Color(0xFF111111),
          onTap: onTapTotal,
        ),
        const SizedBox(width: 10),
        StatCard(
          label: 'Menunggu',
          value: '$menunggu',
          color: const Color(0xFFE07B00),
          onTap: onTapMenunggu,
        ),
        const SizedBox(width: 10),
        StatCard(
          label: 'Selesai',
          value: '$selesai',
          color: const Color(0xFF1A6B3A),
          onTap: onTapSelesai,
        ),
      ],
    );
  }
}