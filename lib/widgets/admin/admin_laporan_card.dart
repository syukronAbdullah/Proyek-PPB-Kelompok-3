import 'package:flutter/material.dart';

import '../laporan/status_badge.dart';

class AdminLaporanCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final void Function(Map<String, dynamic> item, String status) onUpdateStatus;

  const AdminLaporanCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final status = (item['status'] ?? 'menunggu').toString().toLowerCase();

    final createdAt =
        DateTime.tryParse(item['created_at']?.toString() ?? '') ??
            DateTime.now();

    final waktu = _formatRelativeTime(createdAt);

    final namaUser = item['user']?['nama'] ?? item['user']?['name'] ?? '-';
    final nimUser = item['user']?['nim'] ?? '';
    final namaKategori = item['kategori']?['nama'] ?? item['kategori'] ?? '-';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusBadge(
                        status: status,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        waktu,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item['judul'] ?? '-',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          nimUser.isNotEmpty ? '$namaUser • $nimUser' : namaUser,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.category_outlined,
                        size: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        namaKategori,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item['lokasi'] ?? '-',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (status != 'selesai' && status != 'ditolak') ...[
              const Divider(
                height: 1,
                color: Color(0xFFE2E8F0),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: status == 'diproses'
                    ? _FinishButton(
                        onPressed: () => onUpdateStatus(item, 'selesai'),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _ProcessButton(
                              onPressed: () =>
                                  onUpdateStatus(item, 'diproses'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _FinishButton(
                              label: 'Selesai',
                              onPressed: () => onUpdateStatus(item, 'selesai'),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit yang lalu';
    }

    if (diff.inHours < 24) {
      return '${diff.inHours} jam yang lalu';
    }

    if (diff.inDays == 1) {
      return 'Kemarin';
    }

    return '${diff.inDays} hari yang lalu';
  }
}

class _ProcessButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ProcessButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(
          Icons.play_arrow_rounded,
          size: 16,
        ),
        label: const Text(
          'Proses',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1565C0),
          side: const BorderSide(
            color: Color(0xFF1565C0),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class _FinishButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _FinishButton({
    this.label = 'Tandai Selesai',
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(
          Icons.check_rounded,
          size: 16,
        ),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A5E35),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}