import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../Models/laporan_model.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  bool _isLoading = true;
  List<LaporanModel> _allLaporan = [];
  String? _fotoProfilAsli;

  @override
  void initState() {
    super.initState();
    _loadDataDinamis();
  }

  // Mengambil data laporan asli dan profil mahasiswa dari database backend
 Future<void> _loadDataDinamis() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Kita panggil satu fungsi ApiService.getLaporan() yang sudah pasti sukses terdefinisi!
      final response = await ApiService.getLaporan();
      if (response != null && response['success'] == true) {
        
        // 1. Ambil data foto profil yang biasanya ikut dikirim di dalam response objek user/laporan
        if (response['user'] != null) {
          _fotoProfilAsli = response['user']['foto'];
        }

        // 2. Olah data list laporan seperti biasa
        final List<dynamic> listRaw = response['laporan'] ?? [];
        final List<LaporanModel> temp = [];
        for (var item in listRaw) {
          if (item is Map<String, dynamic>) {
            temp.add(LaporanModel.fromJson(item));
          }
        }
        _allLaporan = temp;
      }
    } catch (e) {
      debugPrint('Gagal memuat data dinamis SILAPOR: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildCustomAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadDataDinamis,
        color: const Color(0xFF0D4A28),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D4A28)),
                ),
              )
            : _allLaporan.isEmpty
                ? _buildEmptyNotifikasi()
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubHeaderSection(),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                          itemCount: _allLaporan.length,
                          itemBuilder: (context, index) {
                            return _buildDynamicNotifikasiCard(_allLaporan[index]);
                          },
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  // AppBar Pintar dengan Tombol Kembali Otomatis Jika Dibuka Lewat Lonceng Atas
  PreferredSizeWidget _buildCustomAppBar() {
    final canPop = Navigator.canPop(context);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      // Deteksi: Jika halaman ditumpuk (Navigator.push), munculkan panah back hijau tua
      leading: canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0D4A28)),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: Row(
        children: [
          if (!canPop) const Icon(Icons.account_balance_rounded, color: Color(0xFF0D4A28), size: 24),
          if (!canPop) const SizedBox(width: 10),
          const Text(
            'SILAPOR UIN',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0D4A28), letterSpacing: 0.5),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF475569), size: 22),
          onPressed: () {},
        ),
        Container(
          margin: const EdgeInsets.only(right: 16, left: 8),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFE2E8F0),
            image: _fotoProfilAsli != null
                ? DecorationImage(
                    image: NetworkImage(_fotoProfilAsli!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _fotoProfilAsli == null
              ? const Icon(Icons.person_rounded, color: Color(0xFF94A3B8), size: 18)
              : null,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFFE2E8F0), height: 1),
      ),
    );
  }

  Widget _buildSubHeaderSection() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifikasi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          SizedBox(height: 4),
          Text(
            'Update terbaru untuk laporan Anda',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Pembuat Teks Notifikasi Otomatis Berdasarkan Logika Status Laporan Real Database
  Widget _buildDynamicNotifikasiCard(LaporanModel laporan) {
    String notifTitle;
    String statusBadge = laporan.status.toUpperCase();
    String suffixText;
    IconData iconData;
    Color iconColor;
    Color iconBg;
    Color borderLeftColor;
    Color badgeColor;
    Color badgeBg;

    final currentStatus = laporan.status.toLowerCase();

    if (currentStatus == 'menunggu') {
      notifTitle = 'Laporan Berhasil Dikirim';
      suffixText = ' telah sukses masuk ke antrean sistem ';
      iconData = Icons.notifications_none_rounded;
      iconColor = const Color(0xFF0D4A28);
      iconBg = const Color(0xFFE2E8F0);
      borderLeftColor = const Color(0xFFFFB300);
      badgeColor = const Color(0xFFE07B00);
      badgeBg = const Color(0xFFFFF3E0);
    } else if (currentStatus == 'selesai') {
      notifTitle = 'Laporan Selesai';
      suffixText = ' telah selesai diperbaiki dan berstatus ';
      iconData = Icons.assignment_turned_in_outlined;
      iconColor = const Color(0xFF16A34A);
      iconBg = const Color(0xFFDCFCE7);
      borderLeftColor = const Color(0xFF16A34A);
      badgeColor = const Color(0xFF16A34A);
      badgeBg = const Color(0xFFDCFCE7);
    } else { // diproses
      notifTitle = 'Status laporan diperbarui';
      suffixText = ' beralih penanganan ke status ';
      iconData = Icons.notifications_none_rounded;
      iconColor = const Color(0xFF1565C0);
      iconBg = const Color(0xFFE3F2FD);
      borderLeftColor = const Color(0xFF1E88E5);
      badgeColor = const Color(0xFF1565C0);
      badgeBg = const Color(0xFFE3F2FD);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 4, color: borderLeftColor),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                  child: Icon(iconData, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              notifTitle,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                            ),
                          ),
                          Text(
                            laporan.waktu,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4, fontFamily: 'Roboto'),
                          children: [
                            const TextSpan(text: "Laporan '"),
                            TextSpan(text: laporan.judul, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                            TextSpan(text: "'$suffixText"),
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