import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Tambahan FocusNode sesuai poin 1
  final _oldPasswordFocus = FocusNode();
  final _newPasswordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _isLoading = false;

  // Variabel state untuk visibility password
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Pembersihan FocusNode di dispose() sesuai poin 2
  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    _oldPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();

    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showSnackBar('Semua field harus diisi!', isError: true);
      return;
    }

    if (_oldPasswordController.text == _newPasswordController.text) {
      _showSnackBar(
        'Kata sandi baru tidak boleh sama dengan kata sandi lama!',
        isError: true,
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('Konfirmasi kata sandi baru tidak cocok!', isError: true);
      return;
    }

    if (_newPasswordController.text.length < 8) {
      _showSnackBar('Kata sandi baru minimal 8 karakter!', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.changePassword({
        'current_password': _oldPasswordController.text,
        'new_password': _newPasswordController.text,
        'new_password_confirmation': _confirmPasswordController.text,
      });

      if (!mounted) return;

      if (response['success'] == true) {
        _showSnackBar(response['message'] ?? 'Kata sandi berhasil diperbarui!', isError: false);
        Navigator.pop(context);
      } else {
        _showSnackBar(response['message'] ?? 'Gagal memperbarui kata sandi!', isError: true);
      }
    } catch (_) {
      _showSnackBar('Tidak bisa terhubung ke server!', isError: true);
    } finally { 
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF1A5E35),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Ubah Kata Sandi', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D4A28),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Amankan akun Anda dengan menggunakan kombinasi kata sandi yang kuat.', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 24),
            
            // Poin 3: Update pemanggilan field Kata Sandi Lama
            _buildPasswordField(
              'Kata Sandi Lama',
              _oldPasswordController,
              _oldPasswordFocus,
              _obscureOld,
              () => setState(() => _obscureOld = !_obscureOld),
              textInputAction: TextInputAction.next,
              onSubmitted: () => FocusScope.of(context).requestFocus(_newPasswordFocus),
            ),
            const SizedBox(height: 16),
            
            // Poin 3: Update pemanggilan field Kata Sandi Baru
            _buildPasswordField(
              'Kata Sandi Baru',
              _newPasswordController,
              _newPasswordFocus,
              _obscureNew,
              () => setState(() => _obscureNew = !_obscureNew),
              textInputAction: TextInputAction.next,
              onSubmitted: () => FocusScope.of(context).requestFocus(_confirmPasswordFocus),
            ),
            const SizedBox(height: 16),
            
            // Poin 3: Update pemanggilan field Konfirmasi Kata Sandi Baru
            _buildPasswordField(
              'Konfirmasi Kata Sandi Baru',
              _confirmPasswordController,
              _confirmPasswordFocus,
              _obscureConfirm,
              () => setState(() => _obscureConfirm = !_obscureConfirm),
              textInputAction: TextInputAction.done,
              onSubmitted: _handleChangePassword,
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleChangePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A5E35),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                    : const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Poin 4: Update struktur method _buildPasswordField()
  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    FocusNode focusNode,
    bool obscureText,
    VoidCallback onToggle, {
    TextInputAction textInputAction = TextInputAction.done,
    VoidCallback? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          textInputAction: textInputAction,
          onSubmitted: (_) {
            if (onSubmitted != null) {
              onSubmitted();
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
          ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF1A5E35),
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF64748B),
                size: 20,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}