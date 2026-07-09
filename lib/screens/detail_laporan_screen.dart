import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/status_helper.dart';
import '../models/laporan_model.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/laporan/detail_laporan_app_bar.dart';
import '../widgets/laporan/detail_laporan_info_section.dart';
import '../widgets/laporan/detail_laporan_photo_section.dart';
import '../widgets/laporan/detail_laporan_timeline.dart';
import 'buat_laporan_screen.dart';

class DetailLaporanScreen extends StatefulWidget {
  final LaporanModel laporan;

  const DetailLaporanScreen({super.key, required this.laporan});

  @override
  State<DetailLaporanScreen> createState() => _DetailLaporanScreenState();
}

class _DetailLaporanScreenState extends State<DetailLaporanScreen> {
  int? _currentUserId;
  bool _isDeleting = false;

  bool get _isOwner =>
      _currentUserId != null && _currentUserId == widget.laporan.userId;

  bool get _canEditOrDelete =>
      StatusHelper.canEdit(widget.laporan.status) &&
      StatusHelper.canDelete(widget.laporan.status);

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userRaw = prefs.getString('user');
    if (userRaw == null) return;

    try {
      final user = jsonDecode(userRaw);
      if (!mounted) return;
      setState(() {
        _currentUserId = int.tryParse(user['id'].toString());
      });
    } catch (_) {}
  }

  Future<void> _handleEdit() async {
    // Defense in depth: status tetap dicek walaupun menu edit disembunyikan.
    if (!_canEditOrDelete) {
      _showProcessedReportMessage();
      return;
    }

    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BuatLaporanScreen(laporan: widget.laporan),
      ),
    );

    if (!mounted) return;
    if (updated == true) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _handleDelete() async {
    // Defense in depth: status tetap dicek walaupun menu hapus disembunyikan.
    if (!_canEditOrDelete) {
      _showProcessedReportMessage();
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Hapus Laporan?'),
          content: const Text('Yakin ingin menghapus laporan ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);
    try {
      final result = await ApiService.deleteLaporan(widget.laporan.id);
      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil dihapus.'),
            backgroundColor: Color(0xFF1A5E35),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal menghapus laporan.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _showProcessedReportMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Laporan sudah diproses, tidak bisa diubah.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = widget.laporan.status.toLowerCase();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.white,
              appBar: DetailLaporanAppBar(
                onBack: () => Navigator.pop(context),
                onShare: () {},
                // Aksi disembunyikan agar mahasiswa tidak melihat opsi yang sudah tidak valid.
                showOwnerActions: _isOwner && _canEditOrDelete,
                onEdit: _handleEdit,
                onDelete: _handleDelete,
              ),
              body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DetailLaporanInfoSection(
                            status: currentStatus,
                            categoryName: widget.laporan.namaKategori,
                            title: widget.laporan.judul,
                            location: widget.laporan.lokasi,
                            description: widget.laporan.deskripsi,
                            photoSection: DetailLaporanPhotoSection(
                              fotoUrls: widget.laporan.fotoUrls,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      thickness: 6,
                      color: AppColors.mutedBackground,
                      height: 6,
                    ),
                    DetailLaporanTimeline(
                      laporan: widget.laporan,
                      currentStatus: currentStatus,
                    ),
                  ],
                ),
              ),
            ),
            if (_isDeleting)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.25),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryAction,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
