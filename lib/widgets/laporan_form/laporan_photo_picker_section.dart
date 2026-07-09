import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../models/photo_item.dart';
import '../../theme/app_colors.dart';
import '../photo_picker/photo_picker_grid.dart';

class LaporanPhotoPickerSection extends StatelessWidget {
  final List<PhotoItem> photos;
  final int existingPhotoCount;
  final VoidCallback onAddPhoto;
  final ValueChanged<PhotoItem> onRemovePhoto;
  final ValueChanged<PhotoItem> onTapPhoto;

  const LaporanPhotoPickerSection({
    super.key,
    required this.photos,
    this.existingPhotoCount = 0,
    required this.onAddPhoto,
    required this.onRemovePhoto,
    required this.onTapPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final uploadedPhotoCount = existingPhotoCount + photos.length;
    final canAddPhoto = uploadedPhotoCount < AppConfig.maxReportPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Foto Kerusakan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '$uploadedPhotoCount/${AppConfig.maxReportPhotos} foto',
              style: TextStyle(
                fontSize: 11,
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        PhotoPickerGrid(
          photos: photos,
          maxPhotos: AppConfig.maxReportPhotos - existingPhotoCount,
          // Picker disembunyikan saat kuota penuh supaya user tidak melihat aksi yang tidak tersedia.
          showAddPhoto: canAddPhoto,
          onAddPhoto: onAddPhoto,
          onRemovePhoto: onRemovePhoto,
          onTapPhoto: onTapPhoto,
        ),
      ],
    );
  }
}
