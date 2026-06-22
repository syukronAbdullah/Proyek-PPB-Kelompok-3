import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;

  String _nama = '-';
  String _nim = '-';
  String _email = '-';
  String _fakultas = '-';
  String _prodi = '-';
  String _role = 'mahasiswa';
  String? _fotoProfil;

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Ambil dari SharedPreferences dulu (cepat)
      final prefs = await SharedPreferences.getInstance();
      final userRaw = prefs.getString('user');
      if (userRaw != null) {
        final u = jsonDecode(userRaw);
        _setUserData(u);
      }

      // Ambil data terbaru dari API
      final result = await ApiService.getProfil();
      if (result['success'] == true && result['user'] != null) {
        final u = result['user'];
        // Simpan ke SharedPreferences
        prefs.setString('user', jsonEncode(u));
        _setUserData(u);
      }
    } catch (e) {
      debugPrint('Error load profil: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _setUserData(Map<String, dynamic> u) {
    if (!mounted) return;
    setState(() {
      _nama       = u['nama'] ?? '-';
      _nim        = u['nim'] ?? '-';
      _email      = u['email'] ?? '-';
      _role       = u['role'] ?? 'mahasiswa';
      _prodi      = u['prodi'] ?? '-';
      _fotoProfil = u['foto_profil'];

      // Fakultas bisa berupa object atau string
      if (u['fakultas'] != null) {
        if (u['fakultas'] is Map) {
          _fakultas = u['fakultas']['nama'] ?? '-';
        } else {
          _fakultas = u['fakultas'].toString();
        }
      }
    });
  }

  String _getInisial(String nama) {
    if (nama.isEmpty || nama == '-') return '?';
    final kata = nama.trim().split(RegExp(r'\s+'));
    if (kata.length > 1) return (kata[0][0] + kata[1][0]).toUpperCase();
    return kata[0][0].toUpperCase();
  }

  void _handleLogout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D4A28)),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadProfil,
              color: const Color(0xFF0D4A28),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildAvatarSection(),
                    const SizedBox(height: 16),
                    Text(_nama,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    Text('NIM: $_nim',
                        style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(_email,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _role == 'admin' ? 'Admin' : 'Mahasiswa',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16A34A)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit_outlined,
                            size: 16, color: Color(0xFF0D4A28)),
                        label: const Text('Edit Profil',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0D4A28))),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 45),
                          side: const BorderSide(
                              color: Color(0xFF0D4A28), width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildAcademicSection(),
                    _buildSettingsSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Row(
        children: [
          Icon(Icons.account_balance_rounded,
              color: Color(0xFF0D4A28), size: 24),
          SizedBox(width: 10),
          Text('SILAPOR UIN',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0D4A28),
                  letterSpacing: 0.5)),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFFE2E8F0), height: 1),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0D4A28),
              image: _fotoProfil != null
                  ? DecorationImage(
                      image: NetworkImage(_fotoProfil!),
                      fit: BoxFit.cover)
                  : null,
            ),
            child: _fotoProfil == null
                ? Center(
                    child: Text(
                      _getInisial(_nama),
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1),
                    ),
                  )
                : null,
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
                color: Color(0xFFFFB300), shape: BoxShape.circle),
            child: const Icon(Icons.check_rounded,
                color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informasi Akademik',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 12),
          _buildInfoCard(Icons.business_rounded, 'Fakultas', _fakultas),
          const SizedBox(height: 10),
          _buildInfoCard(Icons.school_outlined, 'Program Studi', _prodi),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF0D4A28), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pengaturan',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildSettingTile(
                    Icons.lock_outline_rounded, 'Ubah Password'),
                const Divider(
                    height: 1,
                    thickness: 0.8,
                    color: Color(0xFFE2E8F0)),
                _buildSettingTile(
                    Icons.info_outline_rounded, 'Tentang Aplikasi'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout_rounded,
                  size: 18, color: Color(0xFFDC2626)),
              label: const Text('Keluar',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDC2626))),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEF2F2),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(
                      color: Color(0xFFFCA5A5), width: 1.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title) {
    return ListTile(
      onTap: () {},
      leading: Icon(icon, color: const Color(0xFF64748B), size: 20),
      title: Text(title,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155))),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 12, color: Color(0xFF94A3B8)),
      dense: true,
    );
  }
}