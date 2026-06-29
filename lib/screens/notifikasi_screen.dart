import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/laporan_model.dart'; // Jika file asli Anda huruf kapital, silakan sesuaikan folder '../Models/' Anda jika error

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  bool _isLoading = true;
  List<LaporanModel> _allLaporan = [];
  String? _fotoProfilAsli; // Kode asli Anda aman kembali di sini

  @override
  void initState() {
    super.initState();
    _loadDataDinamis();
  }

  Future<void> _loadDataDinamis() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getLaporan();
      if (response != null && response['success'] == true) {
        
        // Mengembalikan penanganan foto profil asli Anda
        if (response['user'] != null) {
          _fotoProfilAsli = response['user']['foto'];
        }

        final List<dynamic> listRaw = response['laporan'] ?? [];
        final List<LaporanModel> temp = [];
        for (var item in listRaw) {
          if (item is Map<String, dynamic>) {
            temp.add(LaporanModel.fromJson(item));
          }
        }
        setState(() {
          _allLaporan = temp;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC),
      child: Column(
          children: [
            _buildSectionTitle(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A5E35))))
                  : _allLaporan.isEmpty
                      ? _buildEmptyNotifikasi()
                      : RefreshIndicator(
                          onRefresh: _loadDataDinamis,
                          color: const Color(0xFF1A5E35),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            itemCount: _allLaporan.length,
                            itemBuilder: (context, index) => _buildNotificationTile(_allLaporan[index]),
                          ),
                        ),
            ),
          ],
        ),
    );
  }

  Widget _buildSectionTitle() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: const Text(
        'Notifikasi & Status',
        style: TextStyle(color: Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildNotificationTile(LaporanModel item) {
    String statusBadge = 'MENUNGGU';
    Color badgeColor = const Color(0xFFE07B00);
    Color badgeBg = const Color(0xFFFFF3E0);
    String pesanInfo = 'Laporan Anda sedang berada dalam antrean peninjauan operator.';

    final s = item.status.toLowerCase();
    if (s == 'selesai') {
      statusBadge = 'SELESAI';
      badgeColor = const Color(0xFF1A6B3A);
      badgeBg = const Color(0xFFE8F5EE);
      pesanInfo = 'Selamat! Laporan Anda telah diselesaikan oleh tim teknis lapangan.';
    } else if (s == 'ditolak') {
      statusBadge = 'DITOLAK';
      badgeColor = const Color(0xFFDC2626);
      badgeBg = const Color(0xFFFEF2F2);
      pesanInfo = 'Maaf, laporan Anda ditolak karena data kurang valid atau salah kategori.';
    } else if (s == 'proses') {
      statusBadge = 'PROSES';
      badgeColor = const Color(0xFF1565C0);
      badgeBg = const Color(0xFFE3F2FD);
      pesanInfo = 'Laporan Anda disetujui dan saat ini sedang ditindaklanjuti.';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: badgeBg,
            radius: 18,
            child: Icon(Icons.mail_outline_rounded, color: badgeColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.judul,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                Text(
                  pesanInfo,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    text: '${item.waktu}  •  Status: ',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            statusBadge,
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: badgeColor, letterSpacing: 0.2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyNotifikasi() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            SizedBox(height: 100),
            Icon(Icons.notifications_off_outlined, size: 70, color: Color(0xFF94A3B8)),
            SizedBox(height: 16),
            Text(
              'Belum ada riwayat update laporan untuk Anda.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}