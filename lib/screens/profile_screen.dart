import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'change_password_screen.dart'; // Sesuaikan relative path jika berbeda folder

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
  String? _fotoProfil; // Variabel asli Anda aman terpasang kembali

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userRaw = prefs.getString('user');
      if (userRaw != null) {
        final u = jsonDecode(userRaw);
        _setUserData(u);
      }

      final result = await ApiService.getProfil();
      if (result['success'] == true && result['user'] != null) {
        final user = result['user'];
        prefs.setString('user', jsonEncode(user));
        _setUserData(user);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _setUserData(Map<String, dynamic> u) {
  setState(() {
    _nama = u['nama'] ?? '-';
    _nim = u['nim'] ?? '-';
    _email = u['email'] ?? '-';

    // Fakultas: handle baik bentuk objek maupun string lama
    final fakultasData = u['fakultas'];
    if (fakultasData is Map) {
      _fakultas = fakultasData['nama_fakultas'] ?? fakultasData['nama'] ?? '-';
    } else {
      _fakultas = u['nama_fakultas'] ?? fakultasData ?? '-';
    }

    // Prodi: handle baik bentuk objek maupun string lama
    final prodiData = u['prodi'];
    if (prodiData is Map) {
      _prodi = prodiData['nama_prodi'] ?? '-';
    } else {
      _prodi = u['nama_prodi'] ?? prodiData ?? '-';
    }

    _role = u['role'] ?? 'mahasiswa';
    _fotoProfil = u['foto'];
  });
}

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Aplikasi?'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun SILAPOR UIN Anda?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ApiService.logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600), // Agar kartu profil tetap mudah dibaca di desktop lebar
                        child: Column(
                          children: [
                            _buildHeaderCard(),
                            const SizedBox(height: 16),
                            _buildInfoSection(),
                            const SizedBox(height: 24),
                            _buildActionSection(),
                          ],
                        ),
                      ),
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
      color: const Color(0xFF0D4A28),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: const Text(
        'Profil Pengguna',
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFFE8F5EE),
            child: const Icon(Icons.person, size: 46, color: Color(0xFF1A5E35)),
          ),
          const SizedBox(height: 12),
          Text(_nama, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(12)),
            child: Text(_role.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        children: [
          _buildInfoRow(Icons.badge_outlined, 'Nomor Induk Mahasiswa', _nim),
          const Divider(height: 1, indent: 50),
          _buildInfoRow(Icons.mail_outline_rounded, 'Email Institusi', _email),
          const Divider(height: 1, indent: 50),
          _buildInfoRow(Icons.account_balance_outlined, 'Fakultas', _fakultas),
          const Divider(height: 1, indent: 50),
          _buildInfoRow(Icons.school_outlined, 'Program Studi', _prodi),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1A5E35), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        children: [
          _buildSettingTile(Icons.lock_outline_rounded, 'Ubah Kata Sandi'),
          const Divider(height: 1, indent: 50),
          _buildSettingTile(Icons.verified_user_outlined, 'Kebijakan Privasi'),
          const Divider(height: 1, indent: 50),
          ListTile(
            onTap: _handleLogout,
            leading: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 20),
            title: const Text('Keluar Akun', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.verified_user_outlined, color: Color(0xFF1A5E35)),
            SizedBox(width: 10),
            Text('Kebijakan Privasi'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            'Aplikasi SILAPOR UIN berkomitmen untuk melindungi seluruh data pribadi pengguna. '
            'Data yang Anda masukkan saat pendaftaran (Nama, NIM, Email, Fakultas, dan Program Studi) '
            'hanya digunakan untuk keperluan validasi identitas laporan fasilitas di lingkungan kampus '
            'dan tidak akan disebarluaskan kepada pihak ketiga tanpa persetujuan Anda.',
            style: TextStyle(height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: Color(0xFF1A5E35), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title) {
    return ListTile(
      onTap: () {
        if (title == 'Kebijakan Privasi') {
          _showPrivacyPolicy(); 
        } else if (title == 'Ubah Kata Sandi') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
          );
        }
      },
      leading: Icon(icon, color: const Color(0xFF64748B), size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFFCBD5E1)),
    );
  }
}