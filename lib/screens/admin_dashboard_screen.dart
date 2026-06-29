import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'admin_detail_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedNav = 1; // default ke tab Laporan seperti di desain
  bool _isLoading = true;

  // Stats
  int _total = 0;
  int _menunggu = 0;
  int _diproses = 0;
  int _selesai = 0;
  int _ditolak = 0;
  int _totalUser = 0;

  // Laporan
  List<dynamic> _laporanList = [];
  String _filterStatus = 'semua';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getAdminDashboard();
      if (result['success'] == true) {
        final stats = result['stats'];
        final List<dynamic> laporan = result['laporan_terbaru'] ?? [];
        setState(() {
          _total     = stats['total'] ?? 0;
          _menunggu  = stats['menunggu'] ?? 0;
          _diproses  = stats['diproses'] ?? 0;
          _selesai   = stats['selesai'] ?? 0;
          _ditolak   = stats['ditolak'] ?? 0;
          _totalUser = stats['total_user'] ?? 0;
          _laporanList = laporan;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSemuaLaporan({String? status, String? search}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getAdminLaporan(
          status: status == 'semua' ? null : status,
          search: search);
      if (result['success'] == true) {
        setState(() {
          _laporanList = result['laporan']['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(int id, String status, {String? catatan}) async {
    try {
      final result = await ApiService.updateStatusLaporan(id, status, catatan: catatan);
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Status laporan berhasil diperbarui!'),
              backgroundColor: const Color(0xFF1A5E35),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          _loadDashboard();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal update status'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ── Konfirmasi update status langsung (tanpa bottom sheet) ──
  void _konfirmasiUpdate(Map<String, dynamic> item, String status) {
    final label = status == 'diproses' ? 'Diproses' : 'Selesai';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Tandai $label',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text(
          'Ubah status "${item['judul'] ?? ''}" menjadi $label?',
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _updateStatus(item['id'], status);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A5E35),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Ya, $label'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ApiService.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      drawer: isMobile ? _buildDrawer() : null,
      body: Column(
        children: [
          // Bar atas selalu tampil konsisten di semua tab (Beranda/Laporan/Notifikasi/Profil)
          _buildAppBar(isMobile),
          Expanded(
            child: IndexedStack(
              index: _selectedNav,
              children: [
                _buildDashboardTab(),  // index 0 = Beranda
                _buildLaporanTab(),    // index 1 = Laporan
                _buildPlaceholderTab(Icons.notifications_outlined, 'Notifikasi'),
                _buildPlaceholderTab(Icons.person_outline_rounded, 'Profil'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile ? _buildBottomNav() : null,
    );
  }

  // ════════════════════════════════════════════════════════
  // DRAWER (Mobile only)
  // ════════════════════════════════════════════════════════
  Widget _buildDrawer() {
    final items = [
      _NavItem(icon: Icons.home_rounded, label: 'Beranda'),
      _NavItem(icon: Icons.list_alt_rounded, label: 'Laporan'),
      _NavItem(icon: Icons.notifications_outlined, label: 'Notifikasi'),
      _NavItem(icon: Icons.person_outline_rounded, label: 'Profil'),
    ];

    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D4A28), Color(0xFF1A6B3A)],
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings_rounded,
                  color: Color(0xFF1A5E35), size: 36),
            ),
            accountName: Text('Panel Admin',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            accountEmail: Text('Sarana & Prasarana UIN'),
          ),
          ...List.generate(items.length, (i) {
            return ListTile(
              leading: Icon(items[i].icon, color: const Color(0xFF1A5E35)),
              title: Text(items[i].label,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedNav = i);
                if (i == 1) _loadSemuaLaporan();
                if (i == 0) _loadDashboard();
              },
            );
          }),
          const Divider(),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('Keluar',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              _handleLogout();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // APP BAR
  // ════════════════════════════════════════════════════════
  Widget _buildAppBar(bool isMobile) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D4A28), Color(0xFF1A6B3A)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Hamburger hanya di mobile, logo ikon di desktop
              if (isMobile)
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                )
              else
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_balance_rounded,
                      color: Colors.white, size: 20),
                ),
              const SizedBox(width: 10),
              const Text('SILAPOR UIN',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5)),
              const Spacer(),

              // Navigasi horizontal (hanya di Desktop/Web)
              if (!isMobile) ...[
                _buildDesktopNavItem(0, Icons.home_rounded, 'Beranda'),
                _buildDesktopNavItem(1, Icons.list_alt_rounded, 'Laporan'),
                _buildDesktopNavItem(2, Icons.notifications_outlined, 'Notifikasi'),
                _buildDesktopNavItem(3, Icons.person_outline_rounded, 'Profil'),
                const SizedBox(width: 16),
              ],

              // Avatar admin
              GestureDetector(
                onTap: _handleLogout,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tombol navigasi atas versi desktop/tablet
  Widget _buildDesktopNavItem(int index, IconData icon, String label) {
    final isActive = _selectedNav == index;
    return InkWell(
      onTap: () {
        setState(() => _selectedNav = index);
        if (index == 1) _loadSemuaLaporan();
        if (index == 0) _loadDashboard();
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // TAB 0: BERANDA / DASHBOARD
  // ════════════════════════════════════════════════════════
  Widget _buildDashboardTab() {
    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A5E35)),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDashboard,
                  color: const Color(0xFF1A5E35),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeCard(),
                        const SizedBox(height: 16),
                        _buildStatsGrid(),
                        const SizedBox(height: 20),
                        _buildLaporanTerbaruSection(),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // ── Welcome Card ─────────────────────────────────────────
  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D4A28), Color(0xFF1A6B3A)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D4A28).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sesuai desain: "Panel Admin" besar, "Sarana & Prasarana UIN" kecil
                const Text('Panel Admin',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 4),
                const Text('Sarana & Prasarana UIN',
                    style: TextStyle(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 10),
                Text('Selamat datang, Admin! 👋',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.admin_panel_settings_rounded,
                color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  // ── Stats Grid ───────────────────────────────────────────
  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildStatCard('Menunggu', '$_menunggu',
                const Color(0xFFE07B00), Icons.hourglass_empty_rounded,
                showBadge: true),
            const SizedBox(width: 10),
            _buildStatCard('Diproses', '$_diproses',
                const Color(0xFF1565C0), Icons.settings_rounded),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildStatCard('Selesai', '$_selesai',
                const Color(0xFF1A6B3A), Icons.check_circle_rounded),
            const SizedBox(width: 10),
            _buildStatCard('Total', '$_total',
                const Color(0xFF1565C0), Icons.bar_chart_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon,
      {bool showBadge = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(label,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.45),
                              fontWeight: FontWeight.w500)),
                      if (showBadge) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE07B00),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Text('Baru',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                  Text(value,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Laporan Terbaru (di dashboard) ───────────────────────
  Widget _buildLaporanTerbaruSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Laporan Terbaru',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111111))),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _selectedNav = 1),
              child: const Text('Lihat Semua',
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1A6B3A),
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _laporanList.isEmpty
            ? Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('Belum ada laporan masuk',
                      style: TextStyle(color: Colors.black45, fontSize: 14)),
                ),
              )
            : Column(
                children: _laporanList
                    .take(5)
                    .map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildLaporanCard(item),
                        ))
                    .toList(),
              ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  // TAB 1: LAPORAN
  // ════════════════════════════════════════════════════════
  Widget _buildLaporanTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari laporan...',
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1A5E35), width: 1.5),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, color: Color(0xFF1A5E35)),
                onPressed: () => _loadSemuaLaporan(
                  status: _filterStatus,
                  search: _searchController.text,
                ),
              ),
            ),
            onSubmitted: (val) => _loadSemuaLaporan(
              status: _filterStatus,
              search: val,
            ),
          ),
        ),
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Row(
            children: ['semua', 'menunggu', 'diproses', 'selesai', 'ditolak']
                .map((s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _filterStatus = s);
                          _loadSemuaLaporan(status: s);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _filterStatus == s
                                ? const Color(0xFF1A5E35)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _filterStatus == s
                                  ? const Color(0xFF1A5E35)
                                  : const Color(0xFFE5E5E5),
                            ),
                          ),
                          child: Text(
                            s[0].toUpperCase() + s.substring(1),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _filterStatus == s
                                  ? Colors.white
                                  : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A5E35)),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadSemuaLaporan(status: _filterStatus),
                  color: const Color(0xFF1A5E35),
                  child: _laporanList.isEmpty
                      ? const Center(
                          child: Text('Tidak ada laporan',
                              style: TextStyle(color: Colors.black45)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: _laporanList.length,
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildLaporanCard(_laporanList[i]),
                          ),
                        ),
                ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  // LAPORAN CARD — sesuai desain (2 tombol: Proses + Selesai)
  // ════════════════════════════════════════════════════════
  Widget _buildLaporanCard(Map<String, dynamic> item) {
    final status = (item['status'] ?? 'menunggu').toLowerCase();

    Color statusColor;
    Color statusBg;
    if (status == 'menunggu') {
      statusColor = const Color(0xFFE07B00);
      statusBg    = const Color(0xFFFFF3E0);
    } else if (status == 'selesai') {
      statusColor = const Color(0xFF1A6B3A);
      statusBg    = const Color(0xFFE8F5EE);
    } else if (status == 'ditolak') {
      statusColor = const Color(0xFFDC2626);
      statusBg    = const Color(0xFFFEF2F2);
    } else {
      statusColor = const Color(0xFF1565C0);
      statusBg    = const Color(0xFFE3F2FD);
    }

    final statusLabel = status == 'menunggu' ? 'Menunggu'
        : status == 'selesai'  ? 'Selesai'
        : status == 'ditolak'  ? 'Ditolak'
        : 'Diproses';

    // Hitung waktu relatif
    final createdAt = DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now();
    final diff = DateTime.now().difference(createdAt);
    String waktu;
    if (diff.inMinutes < 60) {
      waktu = '${diff.inMinutes} menit yang lalu';
    } else if (diff.inHours < 24) {
      waktu = '${diff.inHours} jam yang lalu';
    } else if (diff.inDays == 1) {
      waktu = 'Kemarin';
    } else {
      waktu = '${diff.inDays} hari yang lalu';
    }

    final namaUser     = item['user']?['nama']     ?? item['user']?['name'] ?? '-';
    final nimUser      = item['user']?['nim']       ?? '';
    final namaKategori = item['kategori']?['nama']  ?? item['kategori'] ?? '-';

    // Tentukan apakah laporan ini masih bisa diproses/diselesaikan
    final bisaProses   = status == 'menunggu';
    final bisaSelesai  = status == 'menunggu' || status == 'diproses';

    return GestureDetector(
  onTap: () async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminDetailScreen(laporan: item),
      ),
    );
    if (updated == true) _loadDashboard();
  },
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris 1: status badge + waktu
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(statusLabel,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor)),
                    ),
                    const Spacer(),
                    Text(waktu,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black38)),
                  ],
                ),
                const SizedBox(height: 10),

                // Judul laporan
                Text(item['judul'] ?? '-',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B))),
                const SizedBox(height: 6),

                // Nama + NIM
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 13, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Text(
                      nimUser.isNotEmpty ? '$namaUser • $nimUser' : namaUser,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Kategori + lokasi
                Row(
                  children: [
                    const Icon(Icons.category_outlined,
                        size: 13, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Text(namaKategori,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF94A3B8))),
                    const SizedBox(width: 10),
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(item['lokasi'] ?? '-',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF94A3B8))),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Tombol aksi — sesuai desain: Proses + Selesai berdampingan ──
          if (status != 'selesai' && status != 'ditolak') ...[
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: status == 'diproses'
                  // Kalau sudah diproses → hanya 1 tombol "Tandai Selesai"
                  ? SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () => _konfirmasiUpdate(item, 'selesai'),
                        icon: const Icon(Icons.check_rounded, size: 16),
                        label: const Text('Tandai Selesai',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A5E35),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    )
                  // Kalau menunggu → 2 tombol: Proses + Selesai
                  : Row(
                      children: [
                        // Tombol Proses (biru outline)
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: OutlinedButton.icon(
                              onPressed: () => _konfirmasiUpdate(item, 'diproses'),
                              icon: const Icon(Icons.play_arrow_rounded, size: 16),
                              label: const Text('Proses',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1565C0),
                                side: const BorderSide(
                                    color: Color(0xFF1565C0), width: 1.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Tombol Selesai (hijau solid)
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton.icon(
                              onPressed: () => _konfirmasiUpdate(item, 'selesai'),
                              icon: const Icon(Icons.check_rounded, size: 16),
                              label: const Text('Selesai',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A5E35),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
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

  // ════════════════════════════════════════════════════════
  // TAB PLACEHOLDER (Notifikasi & Profil)
  // ════════════════════════════════════════════════════════
  Widget _buildPlaceholderTab(IconData icon, String label) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 56, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(label,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade400)),
                const SizedBox(height: 6),
                Text('Segera hadir',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade400)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  // BOTTOM NAV — 4 tab sesuai desain
  // ════════════════════════════════════════════════════════
  Widget _buildBottomNav() {
    final items = [
      _NavItem(icon: Icons.home_rounded,           label: 'Beranda'),
      _NavItem(icon: Icons.list_alt_rounded,        label: 'Laporan'),
      _NavItem(icon: Icons.notifications_outlined,  label: 'Notifikasi'),
      _NavItem(icon: Icons.person_outline_rounded,  label: 'Profil'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(items.length, (i) {
              final isActive = i == _selectedNav;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedNav = i);
                    if (i == 1) _loadSemuaLaporan();
                    if (i == 0) _loadDashboard();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFE8F5EE)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(items[i].icon,
                            size: 24,
                            color: isActive
                                ? const Color(0xFF1A6B3A)
                                : const Color(0xFF999999)),
                      ),
                      const SizedBox(height: 2),
                      Text(items[i].label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isActive
                                ? const Color(0xFF1A6B3A)
                                : const Color(0xFF999999),
                          )),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}