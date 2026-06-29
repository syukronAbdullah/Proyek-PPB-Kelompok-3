import 'package:flutter/material.dart';
import '../models/laporan_model.dart';

class DetailLaporanScreen extends StatelessWidget {
  final LaporanModel laporan;

  const DetailLaporanScreen({super.key, required this.laporan});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBg;
    final currentStatus = laporan.status.toLowerCase();

    if (currentStatus == 'menunggu') {
      statusColor = const Color(0xFFE07B00);
      statusBg = const Color(0xFFFFF3E0);
    } else if (currentStatus == 'selesai') {
      statusColor = const Color(0xFF1A6B3A);
      statusBg = const Color(0xFFE8F5EE);
    } else {
      statusColor = const Color(0xFF1565C0);
      statusBg = const Color(0xFFE3F2FD);
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800), // Mencegah UI melebar di Desktop
        child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0D4A28),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Laporan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge Status Teratas
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          currentStatus == 'menunggu' ? 'Menunggu' : (currentStatus == 'selesai' ? 'Selesai' : 'Diproses'),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Section Foto Laporan (Horizontal Scroll)
                  _buildPhotoSection(),
                  const SizedBox(height: 16),

                  // Badge Kategori Mini
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      laporan.namaKategori,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Judul Laporan
                  Text(
                    laporan.judul,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B), height: 1.3),
                  ),
                  const SizedBox(height: 8),

                  // Lokasi Laporan
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF1A6B3A)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          laporan.lokasi,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Judul Deskripsi
                  const Text(
                    'DESKRIPSI',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 6),

                  // Isi Deskripsi
                  Text(
                    laporan.deskripsi,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.5, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            
            const Divider(thickness: 6, color: Color(0xFFF1F5F9), height: 6),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Timeline Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 20),

                  // Antrean Node Tracker Sesuai Desain Figma
                  _buildTimelineNode(
                    title: 'Laporan Dibuat',
                    subtitle: 'Laporan Anda telah berhasil masuk ke sistem SILAPOR UIN.',
                    time: laporan.waktu,
                    isDone: true,
                    isActive: currentStatus == 'menunggu',
                  ),
                  _buildTimelineNode(
                    title: 'Sedang Diproses',
                    subtitle: 'Tim IT/Sarpras sedang menuju lokasi untuk pengecekan infrastruktur.',
                    time: currentStatus != 'menunggu' ? laporan.waktu : '',
                    isDone: currentStatus == 'diproses' || currentStatus == 'selesai',
                    isActive: currentStatus == 'diproses',
                    adminNote: laporan.catatanAdmin,
                  ),
                  _buildTimelineNode(
                    title: 'Selesai',
                    subtitle: currentStatus == 'selesai' 
                        ? 'Laporan selesai diatasi oleh unit terkait.' 
                        : 'Status akan diperbarui setelah masalah berhasil diatasi oleh unit terkait.',
                    time: currentStatus == 'selesai' ? laporan.waktu : 'Belum Selesai',
                    isDone: currentStatus == 'selesai',
                    isActive: currentStatus == 'selesai',
                    isLast: true,
                  ),
                  const SizedBox(height: 12),

                  // Card Informasi Tambahan Kuning Estetik
                  _buildInfoTambahanCard(),
                ],
              ),
            )
          ],
        ),
      ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    if (laporan.foto.isEmpty) {
      return Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.image_outlined, size: 40, color: Color(0xFF94A3B8)),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: laporan.foto.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                laporan.foto[index],
                width: 160,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 160,
                    color: const Color(0xFFE2E8F0),
                    child: const Icon(Icons.broken_image_outlined, color: Color(0xFF94A3B8)),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineNode({
    required String title,
    required String subtitle,
    required String time,
    required bool isDone,
    required bool isActive,
    bool isLast = false,
    String? adminNote,
  }) {
    Color nodeColor = isDone ? (isActive ? const Color(0xFF1565C0) : const Color(0xFF1A6B3A)) : const Color(0xFFCBD5E1);
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Batang & Lingkaran Garis Tracker Kiri
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isActive ? nodeColor.withOpacity(0.2) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: nodeColor, shape: BoxShape.circle),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: const Color(0xFFE2E8F0)),
                ),
            ],
          ),
          const SizedBox(width: 14),
          
          // Konten Teks Kanan
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
                          fontWeight: isActive ? FontWeight.w800 : FontWeight.w700, 
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        time,
                        style: TextStyle(fontSize: 12, color: time == 'Belum Selesai' ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                  ),
                  
                  // Balon Teks Catatan Kustom Admin Jika Ada Data Masuk dari Backend
                  if (adminNote != null && adminNote.isNotEmpty && isDone) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.supervised_user_circle_outlined, size: 18, color: Color(0xFF1565C0)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '"$adminNote"',
                              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTambahanCard() {
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
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFB45309)),
                ),
                SizedBox(height: 4),
                Text(
                  'Estimasi waktu penyelesaian adalah 2-3 hari kerja tergantung tingkat kerusakan perangkat.',
                  style: TextStyle(fontSize: 12, color: Color(0xFFB45309), height: 1.4, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}