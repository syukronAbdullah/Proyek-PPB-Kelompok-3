import 'package:flutter/material.dart';
import '../../models/photo_item.dart';

class PhotoViewerDialog extends StatelessWidget {
  final PhotoItem photo;

  const PhotoViewerDialog({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Image.file(photo.file, fit: BoxFit.contain),
          ),

          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
