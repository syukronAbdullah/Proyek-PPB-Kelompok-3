import 'dart:io'; // 1. Perbaikan: Tambahkan import dart:io

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/kategori_model.dart';
import '../services/api_service.dart';
import '../models/photo_item.dart';
import '../config/app_config.dart';
import '../models/results/duplicate_check_result.dart';
import '../models/results/photo_selection_result.dart';
import '../widgets/photo_picker/add_photo_card.dart';
import '../widgets/photo_picker/photo_tile.dart';
import '../widgets/photo_picker/photo_picker_grid.dart';
import '../widgets/photo_picker/photo_viewer_dialog.dart';
import '../services/image_picker_service.dart';
import '../widgets/report_form/report_form_card.dart';
import '../widgets/report_form/report_submit_button.dart';

class BuatLaporanScreen extends StatefulWidget {
  const BuatLaporanScreen({super.key});

  @override
  State<BuatLaporanScreen> createState() => _BuatLaporanScreenState();
}

class _BuatLaporanScreenState extends State<BuatLaporanScreen> {
  final List<PhotoItem> _photos = [];
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  List<KategoriModel> _kategoriList = [];
  int? _selectedKategoriId;
  bool _isLoadingKategori = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchKategoriData();
  }

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

  Future<void> _submitLaporan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedKategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih kategori fasilitas terlebih dahulu!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final Map<String, dynamic> bodyData = {
      'judul': _judulController.text,
      'kategori_id': _selectedKategoriId,
      'lokasi': _lokasiController.text,
      'deskripsi': _deskripsiController.text,
      // Catatan Pengembangan: Jangan lupa di sini nanti lampirkan file '_photos' ke API multipart jika diperlukan
    };

    try {
      final response = await ApiService.buatLaporan(bodyData);
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🎉 Laporan berhasil dikirim!')),
          );
          Navigator.of(context).pop(true);
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

  // GPT Project: Fungsi penampung pencarian/pemilihan gambar
  Future<void> _pickImages() async {
    debugPrint("_pickImages dipanggil");
    final files = await ImagePickerService.pickMultipleImages();

    if (files.isEmpty) return;

    debugPrint("Jumlah file dipilih: ${files.length}");

    setState(() {
      _photos.addAll(
        files.map((file) => PhotoItem(file: file)),
      );
    });
  }

  DuplicateCheckResult _removeDuplicatePhotos(List<File> files) {
    final existingPaths = _photos.map((photo) => photo.file.path).toSet();
    final uniqueFiles = <File>[];
    var duplicateCount = 0;

    for (final file in files) {
      if (existingPaths.contains(file.path)) {
        duplicateCount++;
        continue;
      }
      existingPaths.add(file.path);
      uniqueFiles.add(file);
    }

    return DuplicateCheckResult(
      files: uniqueFiles,
      duplicateCount: duplicateCount,
    );
  }

  int _remainingPhotoSlots() {
    return AppConfig.maxReportPhotos - _photos.length;
  }

  PhotoSelectionResult _addPhotos(List<File> files) {
    final remainingSlots = _remainingPhotoSlots();

    if (remainingSlots <= 0) {
      return PhotoSelectionResult(
        addedCount: 0,
        overLimitCount: files.length,
      );
    }

    final filesToAdd = files.take(remainingSlots).toList();

    setState(() {
      _photos.addAll(
        filesToAdd.map((file) => PhotoItem(file: file)),
      );
    });

    return PhotoSelectionResult(
      addedCount: filesToAdd.length,
      overLimitCount: files.length - filesToAdd.length,
    );
  }

  void _showPhotoSelectionSummary({
    required int added,
    required int duplicate,
    required int overLimit,
  }) {
    final messages = <String>[];

    if (added > 0) messages.add("✅ $added foto berhasil ditambahkan.");
    if (duplicate > 0) messages.add("⚠️ $duplicate foto diabaikan karena sudah pernah dipilih.");
    if (overLimit > 0) messages.add("⚠️ $overLimit foto tidak ditambahkan karena batas maksimal ${AppConfig.maxReportPhotos} foto.");

    if (messages.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messages.join("\n"))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
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
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ReportFormCard(
                          judulController: _judulController,
                          lokasiController: _lokasiController,
                          deskripsiController: _deskripsiController,
                          kategoriList: _kategoriList,
                          selectedKategoriId: _selectedKategoriId,
                          onKategoriChanged: (value) {
                            setState(() {
                              _selectedKategoriId = value;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                          children: [
                            const Text('Foto Kerusakan', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            Text('Maks. 4 foto', style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.4))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        // Pemanggilan widget grid pembungkus foto yang reusable
                        PhotoPickerGrid(
                          photos: _photos,
                          onAddPhoto: _pickImages,
                          onRemovePhoto: (photo) {
                            setState(() {
                              _photos.remove(photo);
                            });
                          },
                          onTapPhoto: _previewPhoto,
                        ),
                        const SizedBox(height: 32),

                        ReportSubmitButton(
                          isLoading: _isSubmitting,
                          onPressed: _submitLaporan,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  //CHANGE REQUEST #027
  void _previewPhoto(PhotoItem photo) {
    showDialog(
      context: context,
      builder: (_) {
        return PhotoViewerDialog(
          photo: photo,
        );
      },
    );
  }
}