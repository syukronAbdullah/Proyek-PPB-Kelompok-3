import 'package:flutter/material.dart';

class AdminDetailTimeline extends StatelessWidget {
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminDetailTimeline({
    super.key,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  Widget build(BuildContext context) {
    final steps = status == 'ditolak'
        ? [
            _TimelineStep(
              label: 'Laporan Diterima',
              time: _formatDate(createdAt),
              isDone: true,
              color: const Color(0xFF1A5E35),
            ),
            _TimelineStep(
              label: 'Ditolak',
              time: _formatDate(updatedAt),
              isDone: true,
              color: const Color(0xFFDC2626),
            ),
          ]
        : [
            _TimelineStep(
              label: 'Laporan Diterima',
              time: _formatDate(createdAt),
              isDone: true,
              color: const Color(0xFF1A5E35),
            ),
            _TimelineStep(
              label: 'Sedang Diproses',
              time: status == 'diproses' || status == 'selesai'
                  ? _formatDate(updatedAt)
                  : null,
              isDone: status == 'diproses' || status == 'selesai',
              color: const Color(0xFF1565C0),
            ),
            _TimelineStep(
              label: 'Selesai',
              time: status == 'selesai' ? _formatDate(updatedAt) : null,
              isDone: status == 'selesai',
              color: const Color(0xFF1A5E35),
            ),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Timeline Laporan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 14),
        Column(
          children: steps.asMap().entries.map((entry) {
            return _TimelineItem(
              step: entry.value,
              isLast: entry.key == steps.length - 1,
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return '${dateTime.day} Okt ${dateTime.year}, ${dateTime.hour.toString().padLeft(2, '0')}.${dateTime.minute.toString().padLeft(2, '0')} WIB';
  }
}

class _TimelineItem extends StatelessWidget {
  final _TimelineStep step;
  final bool isLast;

  const _TimelineItem({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: step.isDone ? step.color : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: step.isDone ? step.color : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: step.isDone
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 11,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: step.isDone
                    ? step.color.withValues(alpha: 0.3)
                    : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: step.isDone
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFCBD5E1),
                  ),
                ),
                if (step.time != null)
                  Text(
                    step.time!,
                    style: const TextStyle(fontSize: 11, color: Colors.black38),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineStep {
  final String label;
  final String? time;
  final bool isDone;
  final Color color;

  const _TimelineStep({
    required this.label,
    required this.isDone,
    required this.color,
    this.time,
  });
}
