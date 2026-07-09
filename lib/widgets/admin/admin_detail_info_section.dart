import 'package:flutter/material.dart';

import '../laporan/status_badge.dart';

class AdminDetailInfoSection extends StatelessWidget {
  final String status;
  final String reportId;
  final String title;
  final String categoryName;
  final String location;
  final String description;

  const AdminDetailInfoSection({
    super.key,
    required this.status,
    required this.reportId,
    required this.title,
    required this.categoryName,
    required this.location,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            StatusBadge(
              status: status,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            ),
            const Spacer(),
            Text(
              'ID: RPT-$reportId',
              style: const TextStyle(fontSize: 11, color: Colors.black38),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.category_outlined,
              size: 14,
              color: Color(0xFF1A5E35),
            ),
            const SizedBox(width: 6),
            Text(
              categoryName,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1A5E35),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 14,
              color: Colors.black45,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                location,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        const SizedBox(height: 16),
        const Text(
          'Deskripsi Laporan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
