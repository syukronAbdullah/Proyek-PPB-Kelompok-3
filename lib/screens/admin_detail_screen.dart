import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/admin/admin_action_card.dart';
import '../widgets/admin/admin_detail_app_bar.dart';
import '../widgets/admin/admin_detail_info_section.dart';
import '../widgets/admin/admin_detail_photo_section.dart';
import '../widgets/admin/admin_detail_timeline.dart';

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

  final List<String> _statusOptions = [
    'menunggu',
    'diproses',
    'selesai',
    'ditolak',
  ];

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

    // Konfirmasi jika akan mengubah ke status final
    if (_selectedStatus == 'selesai' || _selectedStatus == 'ditolak') {
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              _selectedStatus == 'selesai'
                  ? 'Selesaikan Laporan?'
                  : 'Tolak Laporan?',
            ),
            content: Text(
              _selectedStatus == 'selesai'
                  ? 'Setelah laporan diselesaikan, status tidak dapat diubah lagi.'
                  : 'Setelah laporan ditolak, status tidak dapat diubah lagi.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  _selectedStatus == 'selesai' ? 'Selesaikan' : 'Tolak',
                ),
              ),
            ],
          );
        },
      );

      if (confirm != true) return;
    }

    if (_selectedStatus == 'ditolak' &&
        _catatanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan penolakan wajib diisi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.updateStatusLaporan(
        _laporan['id'],
        _selectedStatus!,
        catatan: _catatanController.text.isEmpty
            ? null
            : _catatanController.text,
      );
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Status berhasil diperbarui!'),
              backgroundColor: const Color(0xFF1A5E35),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
    final status = (_laporan['status'] ?? 'menunggu').toLowerCase();
    final judul = _laporan['judul'] ?? '-';
    final lokasi = _laporan['lokasi'] ?? '-';
    final deskripsi = _laporan['deskripsi'] ?? '-';
    final namaKategori =
        _laporan['kategori']?['nama'] ?? _laporan['kategori'] ?? '-';
    final idLaporan = _laporan['id']?.toString() ?? '-';
    final List<dynamic> fotos = _laporan['fotos'] ?? _laporan['foto'] ?? [];
    final createdAt = DateTime.tryParse(_laporan['created_at'] ?? '');
    final updatedAt = DateTime.tryParse(_laporan['updated_at'] ?? '');

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
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
                      _buildFotoSection(fotos),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AdminDetailInfoSection(
                              status: status,
                              reportId: idLaporan,
                              title: judul,
                              categoryName: namaKategori,
                              location: lokasi,
                              description: deskripsi,
                            ),
                            const SizedBox(height: 20),
                            _buildDivider(),
                            const SizedBox(height: 16),
                            AdminDetailTimeline(
                              status: status,
                              createdAt: createdAt,
                              updatedAt: updatedAt,
                            ),
                            const SizedBox(height: 20),
                            _buildDivider(),
                            const SizedBox(height: 16),
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

  Widget _buildAppBar() {
    return AdminDetailAppBar(onBack: () => Navigator.pop(context));
  }

  Widget _buildFotoSection(List<dynamic> fotos) {
    return AdminDetailPhotoSection(photos: fotos);
  }

  Widget _buildTindakanAdmin() {
    return AdminActionCard(
      currentStatus: _laporan['status'] ?? 'menunggu',
      selectedStatus: _selectedStatus,
      statusOptions: _statusOptions,
      catatanController: _catatanController,
      isLoading: _isLoading,
      onStatusChanged: (value) {
        setState(() {
          _selectedStatus = value;
        });
      },
      onSave: _simpanPerubahan,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Color(0xFFE2E8F0));
  }
}
