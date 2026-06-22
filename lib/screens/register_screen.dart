import 'package:flutter/material.dart';
import '../models/app_colors.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _namaController = TextEditingController();
  final _nimController = TextEditingController();
  final _prodiController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;
  bool _agreeTerms = false;
  bool _isLoading = false;

  List<dynamic> _fakultasList = [];
  int? _selectedFakultasId;
  String? _selectedFakultasNama;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    _loadFakultas();
  }

  Future<void> _loadFakultas() async {
    try {
      final data = await ApiService.getFakultas();
      setState(() => _fakultasList = data);
    } catch (e) {
      // tetap lanjut
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    _prodiController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    FocusScope.of(context).unfocus();

    if (_namaController.text.isEmpty ||
        _nimController.text.isEmpty ||
        _prodiController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _konfirmasiController.text.isEmpty) {
      _showSnackBar('Semua field harus diisi!', isError: true);
      return;
    }

    if (_selectedFakultasId == null) {
      _showSnackBar('Pilih fakultas terlebih dahulu!', isError: true);
      return;
    }

    if (_passwordController.text != _konfirmasiController.text) {
      _showSnackBar('Password dan konfirmasi password tidak sama!', isError: true);
      return;
    }

    if (_passwordController.text.length < 8) {
      _showSnackBar('Password minimal 8 karakter!', isError: true);
      return;
    }

    if (!_agreeTerms) {
      _showSnackBar('Harap setujui Syarat & Ketentuan terlebih dahulu!', isError: false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.register({
        'nama'                  : _namaController.text.trim(),
        'nim'                   : _nimController.text.trim(),
        'email'                 : _emailController.text.trim(),
        'password'              : _passwordController.text,
        'password_confirmation' : _konfirmasiController.text,
        'fakultas_id'           : _selectedFakultasId,
        'prodi'                 : _prodiController.text.trim(),
      });

      if (mounted) {
        setState(() => _isLoading = false);

        if (result['success'] == true) {
          // Register berhasil → kembali ke Login dengan pesan sukses
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Akun berhasil dibuat! Silakan login.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.darkGreen2,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        } else {
          // Tampilkan pesan error dari server
          final message = result['message'] ??
              (result['errors'] != null
                  ? result['errors'].values.first[0]
                  : 'Pendaftaran gagal!');
          _showSnackBar(message.toString(), isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Tidak bisa terhubung ke server!', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.darkGreen2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    children: [
                      _buildCard(
                        icon: Icons.person_outline_rounded,
                        title: 'Data Mahasiswa',
                        children: [
                          _buildField(
                            label: 'Nama Lengkap',
                            controller: _namaController,
                            hint: 'Masukkan nama sesuai KTM',
                            prefixIcon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            label: 'NIM (Nomor Induk Mahasiswa)',
                            controller: _nimController,
                            hint: 'Contoh: 60200124...',
                            prefixIcon: Icons.tag_rounded,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          _buildFakultasDropdown(),
                          const SizedBox(height: 16),
                          _buildField(
                            label: 'Program Studi',
                            controller: _prodiController,
                            hint: 'Masukkan program studi',
                            prefixIcon: Icons.school_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildCard(
                        icon: Icons.lock_outline_rounded,
                        title: 'Data Akun',
                        iconBg: const Color(0xFF1A5E35),
                        children: [
                          _buildField(
                            label: 'Email Mahasiswa',
                            controller: _emailController,
                            hint: 'nama@student.uin-alauddin.ac.id',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          _buildPasswordField(
                            label: 'Password',
                            controller: _passwordController,
                            hint: 'Masukkan password minimal 8 karakter',
                            obscure: _obscurePassword,
                            onToggle: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          const SizedBox(height: 16),
                          _buildPasswordField(
                            label: 'Konfirmasi Password',
                            controller: _konfirmasiController,
                            hint: 'Ulangi password Anda',
                            obscure: _obscureKonfirmasi,
                            prefixIcon: Icons.verified_user_outlined,
                            onToggle: () => setState(
                                () => _obscureKonfirmasi = !_obscureKonfirmasi),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTermsRow(),
                      const SizedBox(height: 20),
                      _buildRegisterButton(),
                      const SizedBox(height: 24),
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

  Widget _buildAppBar() {
    return Container(
      color: AppColors.darkGreen2,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Expanded(
                child: Text(
                  'Daftar Akun Baru',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
    Color iconBg = const Color(0xFF2E8B57),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
          decoration: _inputDecoration(hint: hint, prefixIcon: prefixIcon),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    IconData prefixIcon = Icons.lock_outline,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
          decoration: _inputDecoration(
            hint: hint,
            prefixIcon: prefixIcon,
            suffix: GestureDetector(
              onTap: onToggle,
              child: Icon(
                obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: const Color(0xFF999999),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFakultasDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fakultas', style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
        )),
        const SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E5E5), width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedFakultasId,
              hint: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.account_balance_outlined,
                      color: Color(0xFF999999), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _fakultasList.isEmpty ? 'Memuat...' : 'Pilih Fakultas',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.35),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              isExpanded: true,
              icon: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF666666)),
              ),
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(vertical: 4),
              items: _fakultasList.map((f) {
                return DropdownMenuItem<int>(
                  value: f['id'],
                  child: Padding(
                    padding: const EdgeInsets.only(left: 44),
                    child: Text(
                      f['nama'],
                      style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedFakultasId = val;
                  _selectedFakultasNama = _fakultasList
                      .firstWhere((f) => f['id'] == val)['nama'];
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: _agreeTerms,
            onChanged: (v) => setState(() => _agreeTerms = v ?? false),
            activeColor: AppColors.darkGreen2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            side: const BorderSide(color: Color(0xFFBBBBBB), width: 1.4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Wrap(
            children: [
              Text('Saya menyetujui ',
                  style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.55))),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Syarat & Ketentuan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGreen2,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.darkGreen2,
                  ),
                ),
              ),
              Text(' yang berlaku di lingkungan SILAPOR UIN.',
                  style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.55))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A5E35),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF1A5E35).withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Daftar Sekarang',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
      ),
    );
  }

  static const _labelStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Color(0xFF333333),
  );

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.black.withOpacity(0.35), fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF999999), size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkGreen2, width: 1.5),
      ),
    );
  }
}