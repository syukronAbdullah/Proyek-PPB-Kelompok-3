import 'dart:io';

import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../config/app_config.dart';
import '../models/kategori_model.dart';
import '../models/laporan_model.dart';
import '../models/photo_item.dart';
import '../models/results/duplicate_check_result.dart';
import '../models/results/photo_selection_result.dart';
import '../services/api_service.dart';
import '../services/image_picker_service.dart';
import '../theme/app_colors.dart';
import '../widgets/laporan_form/laporan_category_dropdown.dart';
import '../widgets/laporan_form/laporan_description_field.dart';
import '../widgets/laporan_form/laporan_form_header.dart';
import '../widgets/laporan_form/laporan_location_field.dart';
import '../widgets/laporan_form/laporan_photo_picker_section.dart';
import '../widgets/laporan_form/laporan_submit_button.dart';
import '../widgets/laporan_form/laporan_title_field.dart';
import '../widgets/photo_picker/photo_viewer_dialog.dart';

class BuatLaporanScreen extends StatefulWidget {
  final LaporanModel? laporan;

  const BuatLaporanScreen({super.key, this.laporan});

  @override
  State<BuatLaporanScreen> createState() => _BuatLaporanScreenState();
}

class _BuatLaporanScreenState extends State<BuatLaporanScreen> {
  final List<PhotoItem> _photos = [];
  final List<String> _existingPhotoUrls = [];
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  List<KategoriModel> _kategoriList = [];
  int? _selectedKategoriId;
  bool _isLoadingKategori = true;
  bool _isSubmitting = false;

  bool get _isEditMode => widget.laporan != null;

  @override
  void initState() {
    super.initState();
    _prefillEditData();
    _fetchKategoriData();
  }

  void _prefillEditData() {
    final laporan = widget.laporan;
    if (laporan == null) return;

    _judulController.text = laporan.judul;
    _lokasiController.text = laporan.lokasi;
    _deskripsiController.text = laporan.deskripsi;
    _selectedKategoriId = laporan.kategoriId == 0 ? null : laporan.kategoriId;
    _existingPhotoUrls
      ..clear()
      ..addAll(laporan.fotoUrls);
  }

  Future<void> _fetchKategoriData() async {
    try {
      final response = await ApiService.getKategori();
      if (response['success'] == true) {
        final List<dynamic> data = response['kategori'] ?? [];
        setState(() {
          _kategoriList = data
              .map((json) => KategoriModel.fromJson(json))
              .toList();
          _isLoadingKategori = false;
        });
      } else {
        setState(() => _isLoadingKategori = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingKategori = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil kategori: $e')));
    }
  }

  Future<void> _submitLaporan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedKategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih kategori fasilitas terlebih dahulu!'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final Map<String, dynamic> bodyData = {
      'judul': _judulController.text.trim(),
      'kategori_id': _selectedKategoriId,
      'lokasi': _lokasiController.text.trim(),
      'deskripsi': _deskripsiController.text.trim(),
    };

    try {
      final newPhotos = _photos.map((photo) => photo.file).toList();
      final response = _isEditMode
          ? await ApiService.updateLaporan(
              widget.laporan!.id,
              bodyData,
              photos: newPhotos,
            )
          : await ApiService.buatLaporan(bodyData, newPhotos);

      if (!mounted) return;

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Laporan berhasil diperbarui!'
                  : 'Laporan berhasil dikirim!',
            ),
            backgroundColor: const Color(0xFF1A5E35),
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal: ${response['message'] ?? 'Terjadi kesalahan'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error koneksi: $e'),
          backgroundColor: Colors.red,
        ),
      );
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

  Future<void> _pickImages() async {
    // Guard tambahan agar kuota tetap aman meskipun tombol ditekan berulang.
    if (_remainingPhotoSlots() <= 0) {
      _showPhotoSelectionSummary(added: 0, duplicate: 0, overLimit: 1);
      return;
    }

    final files = await ImagePickerService.pickMultipleImages();

    if (files.isEmpty) return;

    final duplicateResult = _removeDuplicatePhotos(files);
    final selectionResult = _addPhotos(duplicateResult.files);

    if (!mounted) return;

    _showPhotoSelectionSummary(
      added: selectionResult.addedCount,
      duplicate: duplicateResult.duplicateCount,
      overLimit: selectionResult.overLimitCount,
    );
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
    return AppConfig.maxReportPhotos - _existingPhotoUrls.length - _photos.length;
  }

  PhotoSelectionResult _addPhotos(List<File> files) {
    final remainingSlots = _remainingPhotoSlots();

    if (remainingSlots <= 0) {
      return PhotoSelectionResult(addedCount: 0, overLimitCount: files.length);
    }

    final filesToAdd = files.take(remainingSlots).toList();

    setState(() {
      _photos.addAll(filesToAdd.map((file) => PhotoItem(file: file)));
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

    if (added > 0) messages.add('$added foto berhasil ditambahkan.');
    if (duplicate > 0) {
      messages.add('$duplicate foto diabaikan karena sudah pernah dipilih.');
    }
    if (overLimit > 0) {
      messages.add(
        '$overLimit foto tidak ditambahkan karena batas maksimal ${AppConfig.maxReportPhotos} foto.',
      );
    }

    if (messages.isEmpty) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(messages.join('\n'))));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: LaporanFormHeader(
            onBack: () => Navigator.of(context).pop(),
            onHelp: () {},
          ),
          body: _isLoadingKategori
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LaporanTitleField(controller: _judulController),
                        const SizedBox(height: 16),
                        LaporanCategoryDropdown(
                          kategoriList: _kategoriList,
                          selectedKategoriId: _selectedKategoriId,
                          onChanged: (value) {
                            setState(() {
                              _selectedKategoriId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        LaporanLocationField(controller: _lokasiController),
                        const SizedBox(height: 16),
                        LaporanDescriptionField(
                          controller: _deskripsiController,
                        ),
                        const SizedBox(height: 22),
                        if (_existingPhotoUrls.isNotEmpty) ...[
                          _buildExistingPhotosPreview(),
                          const SizedBox(height: 18),
                        ],
                        LaporanPhotoPickerSection(
                          photos: _photos,
                          existingPhotoCount: _existingPhotoUrls.length,
                          onAddPhoto: _pickImages,
                          onRemovePhoto: (photo) {
                            setState(() {
                              _photos.remove(photo);
                            });
                          },
                          onTapPhoto: _previewPhoto,
                        ),
                        const SizedBox(height: 32),
                        LaporanSubmitButton(
                          isLoading: _isSubmitting,
                          onPressed: _submitLaporan,
                          label: _isEditMode
                              ? 'Simpan Perubahan'
                              : 'Kirim Laporan',
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildExistingPhotosPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto Lama',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _existingPhotoUrls.length,
            itemBuilder: (context, index) {
              final imageUrl = _resolveImageUrl(_existingPhotoUrls[index]);

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _previewNetworkPhoto(imageUrl),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              width: 96,
                              height: 96,
                              color: AppColors.mutedBackground,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 96,
                              height: 96,
                              color: AppColors.mutedBackground,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                color: AppColors.slateTextMuted,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _existingPhotoUrls.removeAt(index);
                          });
                        },
                        borderRadius: BorderRadius.circular(99),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Foto baru yang dipilih akan dikirim saat laporan diperbarui.',
          style: TextStyle(color: AppColors.slateTextMuted, fontSize: 12),
        ),
      ],
    );
  }

  void _previewPhoto(PhotoItem photo) {
    showDialog(
      context: context,
      builder: (_) {
        return PhotoViewerDialog(photo: photo);
      },
    );
  }

  void _previewNetworkPhoto(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _resolveImageUrl(String fotoUrl) {
    if (fotoUrl.startsWith('http')) {
      return fotoUrl;
    }

    return '${ApiConfig.baseUrl.replaceFirst('/api', '')}$fotoUrl';
  }
}
