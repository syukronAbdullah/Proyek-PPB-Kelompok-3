// lib/screens/admin_detail_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminDetailScreen extends StatefulWidget {
  final Map<String, dynamic> laporan;

  const AdminDetailScreen({super.key, required this.laporan});

  @override
  State<AdminDetailScreen> createState() => _AdminDetailScreenState();
}

class _AdminDetailScreenState extends State<AdminDetailScreen> {
  late Map<String, dynamic> _laporan;
  bool _isLoading = false;
  String? _selectedStatus;
  final _catatanController = TextEditingController();

  final List<String> _statusOptions = ['menunggu', 'diproses', 'selesai', 'ditolak'];

  @override
  void initState() {
    super.initState();
    _laporan = widget.laporan;
    _selectedStatus = _laporan['status'] ?? 'menunggu';
    _catatanController.text = _laporan['catatan_admin'] ?? '';
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _simpanPerubahan() async {
    if (_selectedStatus == null) return;
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.updateStatusLaporan(
        _laporan['id'],
        _selectedStatus!,
        catatan: _catatanController.text.isEmpty ? null : _catatanController.text,
      );
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Status berhasil diperbarui!'),
              backgroundColor: const Color(0xFF1A5E35),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          // Update data lokal
          setState(() {
            _laporan = {
              ..._laporan,
              'status': _selectedStatus,
              'catatan_admin': _catatanController.text,
            };
          });
          Navigator.pop(context, true); // true = ada perubahan
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal menyimpan'),
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status      = (_laporan['status'] ?? 'menunggu').toLowerCase();
    final judul       = _laporan['judul'] ?? '-';
    final lokasi      = _laporan['lokasi'] ?? '-';
    final deskripsi   = _laporan['deskripsi'] ?? '-';
    final namaKategori = _laporan['kategori']?['nama'] ?? _laporan['kategori'] ?? '-';
    final idLaporan   = _laporan['id']?.toString() ?? '-';

    // Foto
    final List<dynamic> fotos = _laporan['fotos'] ?? _laporan['foto'] ?? [];

    // Timeline
    final createdAt  = DateTime.tryParse(_laporan['created_at'] ?? '');
    final updatedAt  = DateTime.tryParse(_laporan['updated_at'] ?? '');

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800), // Mencegah UI melebar di Desktop
        child: Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Foto Grid ──
                  _buildFotoSection(fotos),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Status badge + ID ──
                        Row(
                          children: [
                            _buildStatusBadge(status),
                            const Spacer(),
                            Text(
                              'ID: RPT-$idLaporan',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.black38),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ── Judul ──
                        Text(judul,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                                height: 1.3)),
                        const SizedBox(height: 8),

                        // ── Kategori ──
                        Row(
                          children: [
                            const Icon(Icons.category_outlined,
                                size: 14, color: Color(0xFF1A5E35)),
                            const SizedBox(width: 6),
                            Text(namaKategori,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF1A5E35),
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // ── Lokasi ──
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: Colors.black45),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(lokasi,
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black54)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        _buildDivider(),
                        const SizedBox(height: 16),

                        // ── Deskripsi ──
                        const Text('Deskripsi Laporan',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B))),
                        const SizedBox(height: 8),
                        Text(deskripsi,
                            style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                height: 1.6)),

                        const SizedBox(height: 20),
                        _buildDivider(),
                        const SizedBox(height: 16),

                        // ── Timeline ──
                        const Text('Timeline Laporan',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B))),
                        const SizedBox(height: 14),
                        _buildTimeline(status, createdAt, updatedAt),

                        const SizedBox(height: 20),
                        _buildDivider(),
                        const SizedBox(height: 16),

                        // ── Tindakan Admin ──
                        _buildTindakanAdmin(),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
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

  // ── App Bar ──────────────────────────────────────────────
  Widget _buildAppBar() {
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
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text('Detail & Tindakan',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined,
                    color: Colors.white, size: 20),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Foto Grid ────────────────────────────────────────────
  Widget _buildFotoSection(List<dynamic> fotos) {
    if (fotos.isEmpty) {
      return Container(
        height: 180,
        color: const Color(0xFFE2E8F0),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported_outlined,
                  size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text('Tidak ada foto',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    // Layout foto sesuai desain: 2 besar kiri, 2 kecil kanan
    final tampil  = fotos.take(4).toList();
    final sisanya = fotos.length - 4;

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          // Kiri: foto besar (atau 2 foto vertikal)
          Expanded(
            child: tampil.length == 1
                ? _fotoBox(tampil[0], isLarge: true)
                : Column(
                    children: [
                      Expanded(child: _fotoBox(tampil[0])),
                      const SizedBox(height: 2),
                      if (tampil.length > 2)
                        Expanded(child: _fotoBox(tampil[2])),
                    ],
                  ),
          ),
          if (tampil.length > 1) ...[
            const SizedBox(width: 2),
            // Kanan: foto kecil (1 atau 2)
            Expanded(
              child: Column(
                children: [
                  Expanded(child: _fotoBox(tampil[1])),
                  if (tampil.length > 3) ...[
                    const SizedBox(height: 2),
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _fotoBox(tampil[3]),
                          if (sisanya > 0)
                            Container(
                              color: Colors.black.withOpacity(0.5),
                              child: Center(
                                child: Text('+$sisanya Foto',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _fotoBox(dynamic url, {bool isLarge = false}) {
    return Image.network(
      url.toString(),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFE2E8F0),
        child: const Icon(Icons.broken_image_outlined,
            color: Colors.grey, size: 28),
      ),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          color: const Color(0xFFE2E8F0),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF1A5E35),
            ),
          ),
        );
      },
    );
  }

  // ── Status Badge ─────────────────────────────────────────
  Widget _buildStatusBadge(String status) {
    Color bg, text;
    String label;

    switch (status) {
      case 'menunggu':
        bg = const Color(0xFFFFF3E0); text = const Color(0xFFE07B00);
        label = 'Menunggu'; break;
      case 'diproses':
        bg = const Color(0xFFE3F2FD); text = const Color(0xFF1565C0);
        label = 'Diproses'; break;
      case 'selesai':
        bg = const Color(0xFFE8F5EE); text = const Color(0xFF1A6B3A);
        label = 'Selesai'; break;
      case 'ditolak':
        bg = const Color(0xFFFEF2F2); text = const Color(0xFFDC2626);
        label = 'Ditolak'; break;
      default:
        bg = const Color(0xFFFFF3E0); text = const Color(0xFFE07B00);
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: text)),
    );
  }

  // ── Timeline ─────────────────────────────────────────────
  Widget _buildTimeline(String status, DateTime? createdAt, DateTime? updatedAt) {
    String _fmt(DateTime? dt) {
      if (dt == null) return '-';
      return '${dt.day} Okt ${dt.year}, ${dt.hour.toString().padLeft(2,'0')}.${dt.minute.toString().padLeft(2,'0')} WIB';
    }

    final steps = [
      _TimelineStep(
        label: 'Laporan Diterima',
        time: _fmt(createdAt),
        isDone: true,
        color: const Color(0xFF1A5E35),
      ),
      _TimelineStep(
        label: 'Sedang Diproses',
        time: status == 'diproses' || status == 'selesai'
            ? _fmt(updatedAt)
            : null,
        isDone: status == 'diproses' || status == 'selesai',
        color: const Color(0xFF1565C0),
      ),
      _TimelineStep(
        label: 'Selesai',
        time: status == 'selesai' ? _fmt(updatedAt) : null,
        isDone: status == 'selesai',
        color: const Color(0xFF1A5E35),
      ),
    ];

    return Column(
      children: steps.asMap().entries.map((e) {
        final i    = e.key;
        final step = e.value;
        final isLast = i == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dot + garis
            Column(
              children: [
                Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    color: step.isDone
                        ? step.color
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: step.isDone
                          ? step.color
                          : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                  ),
                  child: step.isDone
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 11)
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2, height: 36,
                    color: step.isDone
                        ? step.color.withOpacity(0.3)
                        : const Color(0xFFE2E8F0),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Label + waktu
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.label,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: step.isDone
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFCBD5E1))),
                    if (step.time != null)
                      Text(step.time!,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black38)),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // ── Tindakan Admin ───────────────────────────────────────
  Widget _buildTindakanAdmin() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A5E35).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.settings_rounded,
                    color: Color(0xFF1A5E35), size: 16),
              ),
              const SizedBox(width: 8),
              const Text('Tindakan Admin',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 16),

          // Update Status dropdown
          const Text('Update Status',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E5E5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStatus,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                borderRadius: BorderRadius.circular(10),
                items: _statusOptions.map((s) {
                  final label = s[0].toUpperCase() + s.substring(1);
                  return DropdownMenuItem(
                    value: s,
                    child: Text(label,
                        style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedStatus = v),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Catatan
          const Text('Catatan Penanganan',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155))),
          const SizedBox(height: 8),
          TextField(
            controller: _catatanController,
            maxLines: 4,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Tambahkan catatan penanganan untuk mahasiswa...',
              hintStyle: TextStyle(
                  fontSize: 13, color: Colors.black.withOpacity(0.35)),
              filled: true,
              fillColor: const Color(0xFFF7F7F7),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: Color(0xFF1A5E35), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tombol simpan
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _simpanPerubahan,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_rounded, size: 18),
              label: Text(
                _isLoading ? 'Menyimpan...' : 'Simpan Perubahan',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A5E35),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFF1A5E35).withOpacity(0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Color(0xFFE2E8F0));
  }
}

class _TimelineStep {
  final String label;
  final String? time;
  final bool isDone;
  final Color color;

  const _TimelineStep({
    required this.label,
    required this.isDone,
    required this.color,
    this.time,
  });
}