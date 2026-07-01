import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiController = TextEditingController();

  final _namaFocus = FocusNode();
  final _nimFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _konfirmasiFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;
  bool _agreeTerms = false;
  bool _isLoading = false;

  List<dynamic> _fakultasList = [];
  int? _selectedFakultasId;
  String? _selectedFakultasNama;

  List<dynamic> _listProdi = [];
  int? _selectedProdiId;
  bool _isLoadingProdi = false;

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
      // tetap lanjut, fakultas akan kosong & user bisa retry
    }
  }

  Future<void> _loadProdi(int fakultasId) async {
    setState(() {
      _isLoadingProdi = true;
      _listProdi = [];
      _selectedProdiId = null;
    });
    try {
      final data = await ApiService.getProdi(fakultasId);
      setState(() => _listProdi = data);
    } catch (e) {
      // tetap lanjut, prodi akan kosong & user bisa retry
    } finally {
      if (mounted) setState(() => _isLoadingProdi = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    _namaFocus.dispose();
    _nimFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _konfirmasiFocus.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    FocusScope.of(context).unfocus();

    // 1. Validasi: Semua field tidak boleh kosong
    if (_namaController.text.isEmpty ||
        _nimController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _konfirmasiController.text.isEmpty) {
      _showSnackBar('Semua field harus diisi!', isError: true);
      return;
    }

    // 2. Validasi: WAJIB menggunakan email kampus UIN Alauddin
    final emailText = _emailController.text.trim().toLowerCase();
    if (!emailText.endsWith('@uin-alauddin.ac.id')) {
      _showSnackBar(
        'Pendaftaran gagal! Anda harus menggunakan email resmi mahasiswa (@uin-alauddin.ac.id)',
        isError: true,
      );
      return;
    }

    if (_selectedFakultasId == null) {
      _showSnackBar('Pilih fakultas terlebih dahulu!', isError: true);
      return;
    }

    if (_selectedProdiId == null) {
      _showSnackBar('Pilih program studi terlebih dahulu!', isError: true);
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
      _showSnackBar('Harap setujui Syarat & Ketentuan terlebih dahulu!', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.register({
        'nama': _namaController.text.trim(),
        'nim': _nimController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'password_confirmation': _konfirmasiController.text,
        'fakultas_id': _selectedFakultasId,
        'prodi_id': _selectedProdiId,
      });

      if (!mounted) return;
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Tidak bisa terhubung ke server!', isError: true);
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
                            focusNode: _namaFocus,
                            hint: 'Masukkan nama sesuai KTM',
                            prefixIcon: Icons.badge_outlined,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) =>
                                FocusScope.of(context).requestFocus(_nimFocus),
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            label: 'NIM (Nomor Induk Mahasiswa)',
                            controller: _nimController,
                            focusNode: _nimFocus,
                            hint: 'Contoh: 60200124...',
                            prefixIcon: Icons.tag_rounded,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) =>
                                FocusScope.of(context).requestFocus(_emailFocus),
                          ),
                          const SizedBox(height: 16),
                          _buildFakultasDropdown(),
                          const SizedBox(height: 16),
                          _buildProdiDropdown(),
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
                            focusNode: _emailFocus,
                            hint: 'nama@uin-alauddin.ac.id',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) =>
                                FocusScope.of(context).requestFocus(_passwordFocus),
                          ),
                          const SizedBox(height: 16),
                          _buildPasswordField(
                            label: 'Password',
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            hint: 'Masukkan password minimal 8 karakter',
                            obscure: _obscurePassword,
                            onToggle: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_konfirmasiFocus),
                          ),
                          const SizedBox(height: 16),
                          _buildPasswordField(
                            label: 'Konfirmasi Password',
                            controller: _konfirmasiController,
                            focusNode: _konfirmasiFocus,
                            hint: 'Ulangi password Anda',
                            obscure: _obscureKonfirmasi,
                            prefixIcon: Icons.verified_user_outlined,
                            onToggle: () => setState(
                                () => _obscureKonfirmasi = !_obscureKonfirmasi),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleRegister(),
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
                onPressed: _showHelpDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.darkGreen2,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.help_center_rounded, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pusat Bantuan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mengalami kendala saat mendaftar? Jangan khawatir, silakan hubungi tim teknis kami melalui jalur berikut:',
                    style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  _buildHelpCard(
                    icon: Icons.account_balance_rounded,
                    title: 'Layanan Offline (Fisik)',
                    subtitle: 'Gedung PUSTIPD UIN Alauddin Makassar, Kampus 2 Samata.',
                  ),
                  _buildHelpCard(
                    icon: Icons.alternate_email_rounded,
                    title: 'Layanan Online (Email)',
                    subtitle: 'support@uin-alauddin.ac.id',
                    isLink: true,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '*Catatan: Lampirkan Nama, NIM, dan tangkapan layar (screenshot) kendala Anda untuk mempercepat proses penanganan.',
                    style: TextStyle(fontSize: 11, color: Colors.redAccent, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen2,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpCard({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isLink = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.darkGreen2.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.darkGreen2, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isLink ? AppColors.darkGreen2 : const Color(0xFF555555),
                    fontWeight: isLink ? FontWeight.w600 : FontWeight.normal,
                    decoration: isLink ? TextDecoration.underline : TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    FocusNode? focusNode,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    ValueChanged<String>? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
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
    FocusNode? focusNode,
    IconData prefixIcon = Icons.lock_outline,
    TextInputAction textInputAction = TextInputAction.next,
    ValueChanged<String>? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscure,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
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
        const Text(
          'Fakultas',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
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
                  const Icon(Icons.account_balance_outlined, color: Color(0xFF999999), size: 20),
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
                child: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF666666)),
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
                  _selectedFakultasNama =
                      _fakultasList.firstWhere((f) => f['id'] == val)['nama'];
                });
                if (val != null) {
                  _loadProdi(val);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProdiDropdown() {
    final bool isEnabled = _selectedFakultasId != null && !_isLoadingProdi;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Program Studi',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E5E5), width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedProdiId,
              hint: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.school_outlined, color: Color(0xFF999999), size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _selectedFakultasId == null
                        ? 'Pilih fakultas terlebih dahulu'
                        : (_isLoadingProdi ? 'Memuat prodi...' : 'Pilih Program Studi'),
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
                child: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF666666)),
              ),
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(vertical: 4),
              items: !isEnabled
                  ? null
                  : _listProdi.map((p) {
                      return DropdownMenuItem<int>(
                        value: p['id'],
                        child: Padding(
                          padding: const EdgeInsets.only(left: 44),
                          child: Text(
                            p['nama_prodi'] ?? 'Program Studi tidak tersedia',
                            style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
                          ),
                        ),
                      );
                    }).toList(),
              onChanged: !isEnabled
                  ? null
                  : (val) {
                      setState(() => _selectedProdiId = val);
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
              Text(
                'Saya menyetujui ',
                style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.55)),
              ),
              GestureDetector(
                onTap: _showTermsDialog,
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
              Text(
                ' yang berlaku di lingkungan SILAPOR UIN.',
                style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.55)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.darkGreen2,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.gavel_rounded, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Syarat & Ketentuan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sebelum mendaftar di sistem SILAPOR UIN, pastikan Anda memahami poin-poin berikut:',
                    style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  _buildSkItem('1', 'Akun ini hanya diperuntukkan bagi mahasiswa aktif UIN Alauddin Makassar.'),
                  _buildSkItem('2', 'Pengguna wajib memberikan data pendaftaran yang valid (Nama asli, NIM, dan Fakultas).'),
                  _buildSkItem('3', 'Penyalahgunaan akun atau pembuatan laporan palsu akan ditindaklanjuti secara disiplin oleh pihak kampus.'),
                  _buildSkItem('4', 'Jaga kerahasiaan password Anda demi keamanan data pribadi mahasiswa.'),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen2,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Saya Mengerti',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSkItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: AppColors.darkGreen2.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.darkGreen2,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF333333),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
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
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Daftar Sekarang',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                  ),
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