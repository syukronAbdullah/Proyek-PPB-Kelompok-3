import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../services/image_picker_service.dart';
import '../services/api_service.dart';
import '../services/profile_photo_service.dart';
import 'login_screen.dart';
import 'change_password_screen.dart'; // Sesuaikan relative path jika berbeda folder
import '../widgets/common/confirm_dialog.dart';
import '../widgets/common/profile_photo_avatar.dart';

enum _ProfilePhotoAction { replace, crop }

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onProfileChanged;

  const ProfileScreen({super.key, this.onProfileChanged});

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
  File? _fotoProfilLokal;
  bool _isUploadingPhoto = false;
  bool _isDeletingAccount = false;

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
        await _loadLocalProfilePhoto();
      }

      final result = await ApiService.getProfil();
      if (result['success'] == true && result['user'] != null) {
        final user = result['user'];
        prefs.setString('user', jsonEncode(user));
        _setUserData(user);
        await _loadLocalProfilePhoto();
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadLocalProfilePhoto() async {
    final photo = await ProfilePhotoService.loadPhoto(
      ProfilePhotoService.mahasiswaRole,
    );
    if (!mounted) return;

    setState(() => _fotoProfilLokal = photo);
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

  Future<void> _showProfilePhotoActions() async {
    if (_isUploadingPhoto) return;

    final action = await showModalBottomSheet<_ProfilePhotoAction>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                _PhotoActionTile(
                  icon: Icons.image_outlined,
                  title: 'Pilih Foto',
                  subtitle: 'Pilih foto dari galeri, crop 1:1, lalu simpan.',
                  onTap: () => Navigator.pop(
                    context,
                    _ProfilePhotoAction.replace,
                  ),
                ),
                _PhotoActionTile(
                  icon: Icons.crop_rounded,
                  title: 'Edit Foto',
                  subtitle: 'Crop ulang foto profil yang sedang dipakai.',
                  onTap: () => Navigator.pop(
                    context,
                    _ProfilePhotoAction.crop,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (action == null) return;
    if (action == _ProfilePhotoAction.replace) {
      await _pickAndSaveProfilePhoto();
    } else {
      await _cropCurrentProfilePhoto();
    }
  }

  Future<void> _pickAndSaveProfilePhoto() async {
    final photo = await ImagePickerService.pickImage();
    if (photo == null) return;

    final cropped = await ProfilePhotoService.cropSquare(
      context: context,
      source: photo,
    );
    if (cropped == null) return;

    await _saveProfilePhoto(cropped);
  }

  Future<void> _cropCurrentProfilePhoto() async {
    File? source;
    try {
      source = await _currentProfilePhotoFile();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat foto profil: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (source == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Belum ada foto profil untuk diedit.'),
          backgroundColor: Colors.orange.shade700,
        ),
      );
      return;
    }

    final cropped = await ProfilePhotoService.cropSquare(
      context: context,
      source: source,
    );
    if (cropped == null) return;

    await _saveProfilePhoto(cropped);
  }

  Future<File?> _currentProfilePhotoFile() async {
    if (_fotoProfilLokal != null && await _fotoProfilLokal!.exists()) {
      return _fotoProfilLokal;
    }

    final photoUrl = _resolveProfilePhotoUrl(_fotoProfil);
    if (photoUrl == null) return null;

    return ProfilePhotoService.cacheRemotePhoto(
      photoUrl,
      ProfilePhotoService.mahasiswaRole,
    );
  }

  Future<void> _saveProfilePhoto(File photoToSave) async {
    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      final savedPhoto = await ProfilePhotoService.savePhoto(
        source: photoToSave,
        role: ProfilePhotoService.mahasiswaRole,
      );
      if (!mounted) return;

      setState(() => _fotoProfilLokal = savedPhoto);
      widget.onProfileChanged?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Foto profil berhasil disimpan di perangkat.'),
          backgroundColor: const Color(0xFF1A5E35),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _fotoProfilLokal = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan foto profil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  ImageProvider? _profileImageProvider() {
    if (_fotoProfilLokal != null) return FileImage(_fotoProfilLokal!);

    final photoUrl = _resolveProfilePhotoUrl(_fotoProfil);
    if (photoUrl == null) return null;

    return NetworkImage(photoUrl);
  }

  String? _resolveProfilePhotoUrl(String? foto) {
    if (foto == null || foto.isEmpty) return null;
    if (foto.startsWith('http')) return foto;

    return '${ApiConfig.baseUrl.replaceFirst('/api', '')}$foto';
  }

  Future<void> _handleLogout() async {
    final confirm = await showConfirmDialog(
      context: context,
      title: 'Keluar Aplikasi?',
      message: 'Apakah Anda yakin ingin keluar dari akun SILAPOR UIN Anda?',
      confirmText: 'Keluar',
      isDanger: true,
    );

    if (!confirm) return;

    await ApiService.logout();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _handleDeleteAccount() async {
    await _showDeleteAccountDialog(context);
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final isDeleted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _DeleteAccountDialog(),
    );

    if (isDeleted != true || !mounted) return;

    setState(() => _isDeletingAccount = true);
    await ApiService.clearSession();
    if (!mounted) return;

    setState(() => _isDeletingAccount = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Akun berhasil dihapus.'),
        backgroundColor: Color(0xFF1A5E35),
      ),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
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
    final profileImage = _profileImageProvider();

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
          Stack(
            clipBehavior: Clip.none,
            children: [
              ProfilePhotoAvatar(
                image: profileImage,
                radius: 42,
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: InkWell(
                  onTap: _isUploadingPhoto ? null : _showProfilePhotoActions,
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A5E35),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: _isUploadingPhoto
                        ? const Padding(
                            padding: EdgeInsets.all(7),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                  ),
                ),
              ),
            ],
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
            onTap: _isDeletingAccount ? null : _handleDeleteAccount,
            leading: _isDeletingAccount
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFDC2626),
                      ),
                    ),
                  )
                : const Icon(
                    Icons.delete_forever_outlined,
                    color: Color(0xFFDC2626),
                    size: 22,
                  ),
            title: Text(
              _isDeletingAccount ? 'Menghapus Akun...' : 'Hapus Akun',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFFDC2626),
              ),
            ),
          ),
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

class _PhotoActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PhotoActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5EE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF1A5E35), size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
      ),
      onTap: onTap,
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _passwordError;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitDeleteAccount() async {
    final password = _passwordController.text.trim();

    // Validasi lokal sebelum request backend.
    if (password.isEmpty) {
      setState(() => _passwordError = 'Kata sandi wajib diisi.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _passwordError = null;
    });

    var shouldResetLoading = true;
    try {
      final result = await ApiService.deleteAccount(password);
      if (!mounted) return;

      if (result['success'] == true) {
        shouldResetLoading = false;
        Navigator.pop(context, true);
        return;
      }

      if (result['statusCode'] == 422) {
        // Password salah tetap di dialog supaya user bisa mencoba lagi.
        setState(() {
          _passwordError = result['message']?.toString() ?? 'Kata sandi salah.';
        });
        return;
      }

      _showGenericError();
    } catch (_) {
      if (!mounted) return;
      _showGenericError();
    } finally {
      if (shouldResetLoading && mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showGenericError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terjadi kesalahan, coba lagi nanti'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Konfirmasi Hapus Akun'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tindakan ini tidak bisa dibatalkan. Masukkan kata sandi Anda untuk melanjutkan.',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            autofocus: true,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              labelText: 'Kata Sandi',
              hintText: 'Masukkan kata sandi',
              errorText: _passwordError,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: _isSubmitting ? null : _submitDeleteAccount,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Hapus Akun'),
        ),
      ],
    );
  }
}
