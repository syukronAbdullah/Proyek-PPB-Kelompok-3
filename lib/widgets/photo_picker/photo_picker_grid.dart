import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../models/photo_item.dart';
import 'add_photo_card.dart';
import 'photo_tile.dart';

class PhotoPickerGrid extends StatelessWidget {
  final List<PhotoItem> photos;
  final int maxPhotos;
  final bool readOnly;
  final bool showAddPhoto;
  final VoidCallback? onAddPhoto;
  final ValueChanged<PhotoItem>? onRemovePhoto;
  final ValueChanged<PhotoItem>? onTapPhoto;

  const PhotoPickerGrid({
    super.key,
    required this.photos,
    this.maxPhotos = AppConfig.maxReportPhotos,
    this.readOnly = false,
    this.showAddPhoto = true,
    this.onAddPhoto,
    this.onRemovePhoto,
    this.onTapPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1,
      children: [
        ...photos.map(
          (photo) => PhotoTile(
            photo: photo,
            showRemoveButton: !readOnly,
            onTap: () {
              if (onTapPhoto != null) {
                onTapPhoto!(photo);
              }
            },
            onRemove: () {
              if (onRemovePhoto != null) {
                onRemovePhoto!(photo);
              }
            },
          ),
        ),

        if (!readOnly &&
            showAddPhoto &&
            photos.length < maxPhotos &&
            onAddPhoto != null)
          AddPhotoCard(
            onTap: onAddPhoto!,
          ),
      ],
    );
  }
}
