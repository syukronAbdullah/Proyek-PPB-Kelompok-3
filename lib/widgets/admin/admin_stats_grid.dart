import 'package:flutter/material.dart';

class AdminStatsGrid extends StatelessWidget {
  final int menunggu;
  final int diproses;
  final int selesai;
  final int total;

  final VoidCallback onTapMenunggu;
  final VoidCallback onTapDiproses;
  final VoidCallback onTapSelesai;
  final VoidCallback onTapTotal;

  const AdminStatsGrid({
    super.key,
    required this.menunggu,
    required this.diproses,
    required this.selesai,
    required this.total,
    required this.onTapMenunggu,
    required this.onTapDiproses,
    required this.onTapSelesai,
    required this.onTapTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _AdminStatCard(
              label: 'Menunggu',
              value: '$menunggu',
              color: const Color(0xFFE07B00),
              icon: Icons.hourglass_empty_rounded,
              showBadge: true,
              onTap: onTapMenunggu,
            ),
            const SizedBox(width: 10),
            _AdminStatCard(
              label: 'Diproses',
              value: '$diproses',
              color: const Color(0xFF1565C0),
              icon: Icons.settings_rounded,
              onTap: onTapDiproses,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _AdminStatCard(
              label: 'Selesai',
              value: '$selesai',
              color: const Color(0xFF1A6B3A),
              icon: Icons.check_circle_rounded,
              onTap: onTapSelesai,
            ),
            const SizedBox(width: 10),
            _AdminStatCard(
              label: 'Total',
              value: '$total',
              color: const Color(0xFF1565C0),
              icon: Icons.bar_chart_rounded,
              onTap: onTapTotal,
            ),
          ],
        ),
      ],
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool showBadge;
  final VoidCallback? onTap;

  const _AdminStatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.showBadge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withValues(alpha: 0.45),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (showBadge) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE07B00),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Text(
                              'Baru',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}