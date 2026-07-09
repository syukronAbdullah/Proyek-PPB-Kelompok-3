import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/admin_notification_model.dart';
import 'login_screen.dart';
import 'admin_detail_screen.dart';
import 'admin_profile_screen.dart';
import 'package:flutter/services.dart';
import '../constants/navigation_tab.dart';
import '../widgets/admin/admin_drawer.dart';
import '../widgets/common/confirm_dialog.dart';
import '../widgets/admin/admin_bottom_nav.dart';
import '../widgets/admin/admin_stats_grid.dart';
import '../widgets/admin/admin_laporan_tab.dart';
import '../widgets/admin/admin_laporan_card.dart';
import '../widgets/admin/admin_app_bar.dart';
import '../widgets/admin/admin_welcome_card.dart';
import '../widgets/admin/admin_latest_laporan_section.dart';
import '../widgets/admin/admin_dashboard_content.dart';
import '../widgets/admin/admin_notification_tab.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedNav = NavigationTab.dashboard;
  final List<int> _tabHistory = [NavigationTab.dashboard];
  bool _isLoading = true;

  // Stats
  int _total = 0;
  int _menunggu = 0;
  int _diproses = 0;
  int _selesai = 0;
  int _ditolak = 0;
  int _totalUser = 0;

  void _handleDrawerTabChange(int index) {
    _changeTab(index);

    if (index == NavigationTab.laporan) {
      _loadSemuaLaporan();
    }

    if (index == NavigationTab.notifikasi) {
      _loadAdminNotifications();
    }

    if (index == NavigationTab.dashboard) {
      _loadDashboard();
    }
  }

  // ── Navigasi tab terpusat + history stack ──
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

  void _openLaporanWithFilter(String status) {
    _changeTab(
      NavigationTab.laporan,
    ); // pindah ke tab Laporan dan masuk history

    setState(() {
      _filterStatus = status;
    });

    _loadSemuaLaporan(status: status);
  }

  // ── Konfirmasi keluar aplikasi ──
  Future<bool> _showExitDialog() {
    return showConfirmDialog(
      context: context,
      title: 'Keluar Aplikasi',
      message: 'Apakah kamu yakin ingin keluar dari aplikasi?',
      cancelText: 'Batal',
      confirmText: 'Keluar',
      isDanger: true,
    );
  }

  // Laporan
  List<dynamic> _laporanList = [];
  String _filterStatus = 'semua';
  final _searchController = TextEditingController();

  // Notifikasi admin
  List<AdminNotificationModel> _notificationList = [];
  bool _isLoadingNotifications = false;

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
          _total = stats['total'] ?? 0;
          _menunggu = stats['menunggu'] ?? 0;
          _diproses = stats['diproses'] ?? 0;
          _selesai = stats['selesai'] ?? 0;
          _ditolak = stats['ditolak'] ?? 0;
          _totalUser = stats['total_user'] ?? 0;
          _laporanList = laporan;
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSemuaLaporan({String? status, String? search}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getAdminLaporan(
        status: status == 'semua' ? null : status,
        search: search,
      );
      if (result['success'] == true) {
        setState(() {
          _laporanList = result['laporan']['data'] ?? [];
        });
      }
    } catch (e) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAdminNotifications() async {
    if (!mounted) return;
    setState(() => _isLoadingNotifications = true);
    try {
      final result = await ApiService.getAdminNotifikasi();
      if (result['success'] == true) {
        final rawList = _extractListPayload(result, 'notifikasi');
        if (!mounted) return;
        setState(() {
          _notificationList = rawList
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .map(AdminNotificationModel.fromJson)
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat notifikasi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingNotifications = false);
    }
  }

  List<dynamic> _extractListPayload(
    Map<String, dynamic> result,
    String primaryKey,
  ) {
    final payload = result[primaryKey] ?? result['data'];

    if (payload is List) return payload;
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is List) return data;
    }

    return [];
  }

  Future<Map<String, dynamic>?> _fetchReportFromNotification(
    AdminNotificationModel notification,
  ) async {
    if (notification.laporan != null) return notification.laporan;
    if (notification.laporanId == 0) return null;

    final result = await ApiService.getAdminDetailLaporan(
      notification.laporanId,
    );
    final payload = result['laporan'] ?? result['data'];
    if (payload is Map<String, dynamic>) return payload;

    return null;
  }

  Future<void> _openNotification(AdminNotificationModel notification) async {
    try {
      if (!notification.isRead) {
        await ApiService.bacaAdminNotifikasi(notification.id);
        if (!mounted) return;
        _markNotificationRead(notification.id);
      }

      final laporan = await _fetchReportFromNotification(notification);
      if (!mounted) return;

      if (laporan == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan terkait tidak ditemukan.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AdminDetailScreen(laporan: laporan)),
      );

      if (mounted) {
        _loadAdminNotifications();
        _loadDashboard();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka notifikasi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _markNotificationRead(int id) {
    setState(() {
      _notificationList = _notificationList.map((notification) {
        if (notification.id != id) return notification;
        return notification.copyWith(isRead: true);
      }).toList();
    });
  }

  Future<void> _markAllNotificationsRead() async {
    try {
      final result = await ApiService.bacaSemuaAdminNotifikasi();
      if (!mounted) return;
      if (result['success'] == true) {
        setState(() {
          _notificationList = _notificationList
              .map((notification) => notification.copyWith(isRead: true))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menandai notifikasi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateStatus(int id, String status, {String? catatan}) async {
    try {
      final result = await ApiService.updateStatusLaporan(
        id,
        status,
        catatan: catatan,
      );
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Status laporan berhasil diperbarui!'),
              backgroundColor: const Color(0xFF1A5E35),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
        title: Text(
          'Tandai $label',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Ya, $label'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showConfirmDialog(
      context: context,
      title: 'Keluar',
      message: 'Apakah kamu yakin ingin keluar?',
      cancelText: 'Batal',
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_tabHistory.length > 1) {
          setState(() {
            _tabHistory.removeLast();
            _selectedNav = _tabHistory.last;
          });
          return;
        }

        final exit = await _showExitDialog();

        if (exit && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F4F3),
        drawer: isMobile ? _buildDrawer() : null,
        drawerEnableOpenDragGesture: false,
        body: Column(
          children: [
            _buildAppBar(isMobile),
            Expanded(
              child: IndexedStack(
                index: _selectedNav,
                children: [
                  _buildDashboardTab(),
                  _buildLaporanTab(),
                  _buildNotificationTab(),
                  const AdminProfileScreen(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: isMobile ? _buildBottomNav() : null,
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  // DRAWER (Mobile only)
  // ════════════════════════════════════════════════════════
  Widget _buildDrawer() {
    return AdminDrawer(
      onChangeTab: _handleDrawerTabChange,
      onLogout: () {
        Navigator.pop(context);
        _handleLogout();
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // APP BAR
  // ════════════════════════════════════════════════════════
  Widget _buildAppBar(bool isMobile) {
    return AdminAppBar(
      isMobile: isMobile,
      selectedIndex: _selectedNav,
      onChangeTab: _handleDrawerTabChange,
      onLogout: _handleLogout,
    );
  }

  // ════════════════════════════════════════════════════════
  // TAB 0: BERANDA / DASHBOARD
  // ════════════════════════════════════════════════════════
  Widget _buildDashboardTab() {
    return AdminDashboardContent(
      isLoading: _isLoading,
      onRefresh: _loadDashboard,
      welcomeCard: _buildWelcomeCard(),
      statsGrid: _buildStatsGrid(),
      latestLaporanSection: _buildLaporanTerbaruSection(),
    );
  }

  // ── Welcome Card ─────────────────────────────────────────
  Widget _buildWelcomeCard() {
    return const AdminWelcomeCard();
  }

  // ── Stats Grid ───────────────────────────────────────────
  Widget _buildStatsGrid() {
    return AdminStatsGrid(
      menunggu: _menunggu,
      diproses: _diproses,
      selesai: _selesai,
      total: _total,
      onTapMenunggu: () => _openLaporanWithFilter('menunggu'),
      onTapDiproses: () => _openLaporanWithFilter('diproses'),
      onTapSelesai: () => _openLaporanWithFilter('selesai'),
      onTapTotal: () => _openLaporanWithFilter('semua'),
    );
  }

  // ── Laporan Terbaru (di dashboard) ───────────────────────
  Widget _buildLaporanTerbaruSection() {
    return AdminLatestLaporanSection(
      laporanList: _laporanList,
      onViewAll: () {
        _handleDrawerTabChange(NavigationTab.laporan);
      },
      itemBuilder: (item) {
        return _buildLaporanCard(item as Map<String, dynamic>);
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // TAB 1: LAPORAN
  // ════════════════════════════════════════════════════════
  Widget _buildLaporanTab() {
    return AdminLaporanTab(
      searchController: _searchController,
      selectedFilter: _filterStatus,
      isLoading: _isLoading,
      laporanList: _laporanList,
      onSearchPressed: () {
        _loadSemuaLaporan(
          status: _filterStatus,
          search: _searchController.text,
        );
      },
      onSearchSubmitted: (value) {
        _loadSemuaLaporan(status: _filterStatus, search: value);
      },
      onFilterChanged: (value) {
        setState(() {
          _filterStatus = value;
        });
        _loadSemuaLaporan(status: value);
      },
      onRefresh: () => _loadSemuaLaporan(status: _filterStatus),
      itemBuilder: (laporan) {
        return _buildLaporanCard(laporan as Map<String, dynamic>);
      },
    );
  }

  // ════════════════════════════════════════════════════════
  // LAPORAN CARD — sesuai desain (2 tombol: Proses + Selesai)
  // ════════════════════════════════════════════════════════
  Widget _buildLaporanCard(Map<String, dynamic> item) {
    return AdminLaporanCard(
      item: item,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminDetailScreen(laporan: item)),
        );

        if (mounted) {
          _loadSemuaLaporan(status: _filterStatus);
          _loadDashboard();
        }
      },
      onUpdateStatus: _konfirmasiUpdate,
    );
  }

  Widget _buildNotificationTab() {
    return AdminNotificationTab(
      isLoading: _isLoadingNotifications,
      notifications: _notificationList,
      onRefresh: _loadAdminNotifications,
      onMarkAllRead: _markAllNotificationsRead,
      onTapNotification: _openNotification,
    );
  }

  // ════════════════════════════════════════════════════════
  // BOTTOM NAV — 4 tab sesuai desain
  // ════════════════════════════════════════════════════════
  Widget _buildBottomNav() {
    return AdminBottomNav(
      selectedIndex: _selectedNav,
      onTap: _handleDrawerTabChange,
    );
  }
}
