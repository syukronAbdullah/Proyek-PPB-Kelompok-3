import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../models/laporan_model.dart';
import 'buat_laporan_screen.dart';
import 'laporan_screen.dart';
import 'notifikasi_screen.dart';
import 'profile_screen.dart';
import 'detail_laporan_screen.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
import '../constants/navigation_tab.dart';
import '../widgets/common/stat_card.dart';
import '../widgets/home/welcome_card.dart';
import '../widgets/home/latest_laporan_section.dart';
import '../widgets/home/home_bottom_nav.dart';
import '../widgets/home/home_stats_row.dart';
import '../widgets/home/home_drawer.dart';
import '../widgets/home/home_app_bar.dart';
import '../widgets/common/confirm_dialog.dart';

// ── Home Screen ───────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedNav = NavigationTab.dashboard;
  final GlobalKey<LaporanScreenState> _laporanScreenKey =
    GlobalKey<LaporanScreenState>();
  final List<int> _tabHistory = [NavigationTab.dashboard];

  // Fungsi navigasi tab dengan history yang lebih pintar:
  // Jika user kembali ke tab sebelumnya (misalnya balik dari 1 ke 0),
  // tidak menambah entry baru, cukup "pop" dari history.
  // Jika user pindah ke tab baru, tambahkan ke history.

void _changeTab(int index) {
  if (_selectedNav == index) return;

  setState(() {
    // Kalau tab sudah pernah ada di history,
    // hapus semua history setelah tab tersebut.
    final existingIndex = _tabHistory.indexOf(index);

    if (existingIndex != -1) {
      _tabHistory.removeRange(existingIndex + 1, _tabHistory.length);
    } else {
      _tabHistory.add(index);
    }

    _selectedNav = index;
  });
}

  Future<void> _handleLogout({bool closeDrawer = false}) async {
    if (closeDrawer) {
      Navigator.pop(context);
    }

    final confirm = await showConfirmDialog(
      context: context,
      title: 'Keluar Akun?',
      message: 'Apakah Anda yakin ingin keluar dari akun SILAPOR?',
      confirmText: 'Keluar',
      isDanger: true,
    );

    if (!confirm) return;

    await ApiService.logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _openLaporanWithFilter(String status) {
    _changeTab(NavigationTab.laporan);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _laporanScreenKey.currentState?.applyFilterFromDashboard(status);
    });
  }

  //untuk konfirmasi keluar dari aplikasi
  Future<bool> _showExitDialog() {
    return showConfirmDialog(
      context: context,
      title: 'Keluar Aplikasi',
      message: 'Apakah Anda yakin ingin keluar dari SILAPOR?',
      cancelText: 'Batal',
      confirmText: 'Keluar',
      isDanger: true,
    );
  }

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool _isLoading = true;
  String _namaUser = 'Loading...';
  String _nimUser = '-';
  String _prodiUser = '-';
  int _total = 0;
  int _menunggu = 0;
  int _selesai = 0;
  List<LaporanModel> _laporanList = [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userRaw = prefs.getString('user');
      if (userRaw != null) {
        final userObj = jsonDecode(userRaw);
        setState(() {
          _namaUser = userObj['nama'] ?? 'User';
          _nimUser = userObj['nim'] ?? '-';
          final prodiCache = userObj['prodi'];
          _prodiUser = prodiCache is Map
              ? (prodiCache['nama_prodi'] ?? '-')
              : (prodiCache ?? '-');
        });
      }

      final meResult = await ApiService.getMe();
      if (meResult['success'] == true && meResult['user'] != null) {
        final user = meResult['user'];
        prefs.setString('user', jsonEncode(user));
        setState(() {
          _namaUser = user['nama'] ?? _namaUser;
          _nimUser = user['nim'] ?? _nimUser;
          final prodiData = user['prodi'];
          _prodiUser = prodiData is Map
              ? (prodiData['nama_prodi'] ?? _prodiUser)
              : (prodiData ?? _prodiUser);
        });
      }

      final response = await ApiService.getLaporan();
      if (response['success'] == true) {
        final stats = response['stats'];
        final List<dynamic> listRaw = response['laporan'] ?? [];

        setState(() {
          _total = stats['total'] ?? 0;
          _menunggu = stats['menunggu'] ?? 0;
          _selesai = stats['selesai'] ?? 0;
          _laporanList = listRaw
              .whereType<Map<String, dynamic>>()
              .map((item) => LaporanModel.fromJson(item))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _animController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cek lebar layar untuk menentukan mode responsif
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return PopScope(
      canPop: false, // Mencegah pop otomatis, kita tangani sendiri
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Masih ada history → kembali ke tab sebelumnya
        if (_tabHistory.length > 1) {
          setState(() {
            _tabHistory.removeLast();
            _selectedNav = _tabHistory.last;
          });
          return;
        }

        // Sudah di Dashboard → tampilkan dialog keluar
        final exit = await _showExitDialog();

        if (exit && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F4F3),

        // Drawer hanya dipasang jika di layar hp/mobile
        drawer: isMobile ? _buildDrawer() : null,
        drawerEnableOpenDragGesture: false,

        body: Column(
          children: [
            // Bar atas selalu tampil konsisten di semua tab
            _buildAppBar(isMobile),

            Expanded(
              child: IndexedStack(
                index: _selectedNav,
                children: [
                  _buildMainDashboardContent(isMobile),
                  LaporanScreen(key: _laporanScreenKey),
                  const NotifikasiScreen(),
                  const ProfileScreen(),
                ],
              ),
            ),
          ],
        ),

        // Navigasi bawah hanya muncul di HP/Mobile
        bottomNavigationBar: isMobile ? _buildBottomNav() : null,
      ),
    );
  }

  Widget _buildMainDashboardContent(bool isMobile) {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: const Color(0xFF1A5E35),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF1A5E35)),
              ),
            )
          : FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeCard(),
                      const SizedBox(height: 14),
                      _buildStatsRow(),
                      const SizedBox(height: 14),
                      _buildBuatLaporanButton(),
                      const SizedBox(height: 22),
                      _buildLaporanTerbaru(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildAppBar(bool isMobile) {
    return HomeAppBar(
      isMobile: isMobile,
      selectedIndex: _selectedNav,
      onChangeTab: _changeTab,
      onLogout: _handleLogout,
    );
  }

  Widget _buildWelcomeCard() {
    return WelcomeCard(
      namaUser: _namaUser,
      nimUser: _nimUser,
      prodiUser: _prodiUser,
    );
  }

  Widget _buildStatsRow() {
    return HomeStatsRow(
      total: _total,
      menunggu: _menunggu,
      selesai: _selesai,
      onTapTotal: () => _openLaporanWithFilter('semua'),
      onTapMenunggu: () => _openLaporanWithFilter('menunggu'),
      onTapSelesai: () => _openLaporanWithFilter('selesai'),
    );
  }

  Widget _buildBuatLaporanButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () async {
          final bool? isUploaded = await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => const BuatLaporanScreen()),
          );
          if (isUploaded == true) _loadDashboardData();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A5E35),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 20),
            SizedBox(width: 6),
            Text('Buat Laporan Baru',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildLaporanTerbaru() {
    return LatestLaporanSection(
      laporanList: _laporanList,
      onViewAll: () {
        _changeTab(NavigationTab.laporan);
      },
      onTapItem: (item) async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailLaporanScreen(laporan: item),
          ),
        );

        if (mounted) {
          _loadDashboardData();
        }
      },
    );
  }

  Widget _buildBottomNav() {
    return HomeBottomNav(
      selectedIndex: _selectedNav,
      onTap: _changeTab,
    );
  }

  Widget _buildDrawer() {
    return HomeDrawer(
      namaUser: _namaUser,
      nimUser: _nimUser,
      prodiUser: _prodiUser,
      onChangeTab: _changeTab,
      onLogout: () => _handleLogout(closeDrawer: true),
    );
  }
}