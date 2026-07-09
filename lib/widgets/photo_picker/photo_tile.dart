import 'package:flutter/material.dart';

import '../../models/photo_item.dart';

class PhotoTile extends StatelessWidget {
  final PhotoItem photo;
  final VoidCallback onRemove;
  final bool showRemoveButton;
  final VoidCallback? onTap;

  const PhotoTile({
    super.key,
    required this.photo,
    required this.onRemove,
    this.onTap,
    this.showRemoveButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              photo.file,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Perbaikan di sini: Kurung kurawal dihapus
        if (showRemoveButton)
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
