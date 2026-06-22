import 'package:flutter/material.dart';
import '../Models/app_colors.dart';
import '../Models/kategori_model.dart';
import '../services/api_service.dart';

class BuatLaporanScreen extends StatefulWidget {
  const BuatLaporanScreen({super.key});

  @override
  State<BuatLaporanScreen> createState() => _BuatLaporanScreenState();
}

class _BuatLaporanScreenState extends State<BuatLaporanScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller untuk menangkap inputan text
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  // State untuk data kategori dari API
  List<KategoriModel> _kategoriList = [];
  int? _selectedKategoriId;
  bool _isLoadingKategori = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchKategoriData();
  }

  // Fungsi mengambil list kategori langsung dari Backend Laravel kamu
  Future<void> _fetchKategoriData() async {
    try {
      final response = await ApiService.getKategori();
      if (response['success'] == true) {
        final List<dynamic> data = response['kategori'] ?? [];
        setState(() {
          _kategoriList = data.map((json) => KategoriModel.fromJson(json)).toList();
          _isLoadingKategori = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingKategori = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil kategori: $e')),
      );
    }
  }

  // Fungsi kirim data ke API saat tombol 'Kirim Laporan' diklik
  Future<void> _submitLaporan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedKategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih kategori fasilitas terlebih dahulu!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Bungkus semua data teks sesuai struktur database/API Laravel
    final Map<String, dynamic> bodyData = {
      'judul': _judulController.text,
      'kategori_id': _selectedKategoriId,
      'lokasi': _lokasiController.text,
      'deskripsi': _deskripsiController.text,
    };

    try {
      final response = await ApiService.buatLaporan(bodyData);
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🎉 Laporan berhasil dikirim!')),
          );
          Navigator.of(context).pop(true); // Kembali ke Home dan beri tanda sukses reload
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: ${response['message'] ?? 'Terjadi kesalahan'}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error koneksi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D4A28),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Buat Laporan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoadingKategori
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D4A28)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── JUDUL LAPORAN ──
                    const Text('Judul Laporan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _judulController,
                      decoration: _inputDecoration('Contoh: Kran Air Patah'),
                      validator: (v) => v == null || v.isEmpty ? 'Judul tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),

                    // ── KATEGORI DROPDOWN (LIVE DARI API) ──
                    const Text('Kategori Fasilitas', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      value: _selectedKategoriId,
                      hint: const Text('Pilih Kategori', style: TextStyle(color: Colors.black38, fontSize: 14)),
                      decoration: _inputDecoration(''),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black45),
                      items: _kategoriList.map((kat) {
                        return DropdownMenuItem<int>(
                          value: kat.id,
                          child: Text(kat.nama),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedKategoriId = value),
                    ),
                    const SizedBox(height: 16),

                    // ── LOKASI KEJADIAN ──
                    const Text('Lokasi Kejadian', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _lokasiController,
                      decoration: _inputDecoration('Gedung IT Lantai 2, Ruang 204').copyWith(
                        prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.black45, size: 20),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Lokasi tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),

                    // ── DESKRIPSI KERUSAKAN ──
                    const Text('Deskripsi Kerusakan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _deskripsiController,
                      maxLines: 4,
                      decoration: _inputDecoration(
                        'Ceritakan detail kerusakan yang terjadi agar petugas dapat memahami masalah dengan jelas...',
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),

                    // ── FOTO KERUSAKAN (VISUAL DUMMY SESUAI MOCKUP) ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                      children: [
                        const Text('Foto Kerusakan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        Text('Maks. 4 foto', style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.4))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    // Grid Foto Sesuai Mockup Kamu
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                      children: [
                        _buildDummyPhotoTile('https://via.placeholder.com/150'), // Contoh Foto Air
                        _buildDummyPhotoTile('https://via.placeholder.com/150'), // Contoh Foto Lorong
                        _buildAddPhotoCard(),
                        _buildAddPhotoCard(),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ── TOMBOL KIRIM LAPORAN ──
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitLaporan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D4A28),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline, size: 18),
                                  SizedBox(width: 8),
                                  Text('Kirim Laporan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper style dekorasi textfield biar seragam sama mockup kamu
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 13, height: 1.3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF0D4A28), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  // Widget dummy render foto mockup
  Widget _buildDummyPhotoTile(String url) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
            image: const DecorationImage(
              image: AssetImage('assets/images/placeholder_mockup.png'), // Jika ada asset gambar lokal
            fit: BoxFit.cover,
            ),
          ),
          child: const Center(child: Icon(Icons.image, color: Colors.black12, size: 40)),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
            child: const Icon(Icons.close, color: Colors.white, size: 14),
          ),
        )
      ],
    );
  }

  // Widget Tombol + Tambah Foto
  Widget _buildAddPhotoCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD2D2D2), width: 1, style: BorderStyle.solid),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur kamera akan diaktifkan di tahap selanjutnya!')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: Colors.black.withOpacity(0.4), size: 26),
            const SizedBox(height: 6),
            Text(
              'Tambah Foto',
              style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.4), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}