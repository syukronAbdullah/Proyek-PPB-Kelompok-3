import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../theme/app_colors.dart';

class DetailLaporanPhotoSection extends StatelessWidget {
  final List<String> fotoUrls;

  const DetailLaporanPhotoSection({super.key, required this.fotoUrls});

  @override
  Widget build(BuildContext context) {
    if (fotoUrls.isEmpty) {
      return Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.mutedBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            size: 40,
            color: AppColors.slateTextMuted,
          ),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: fotoUrls.length,
        itemBuilder: (context, index) {
          final imageUrl = _resolveImageUrl(fotoUrls[index]);

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => _PhotoPreviewDialog(imageUrl: imageUrl),
                  );
                },
                child: Image.network(
                  imageUrl,
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 160,
                      color: AppColors.borderSoft,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.slateTextMuted,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _resolveImageUrl(String fotoUrl) {
    if (fotoUrl.startsWith('http')) {
      return fotoUrl;
    }

    return '${ApiConfig.baseUrl.replaceFirst('/api', '')}$fotoUrl';
  }
}

class _PhotoPreviewDialog extends StatelessWidget {
  final String imageUrl;

  const _PhotoPreviewDialog({required this.imageUrl});

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
            child: Center(child: Image.network(imageUrl, fit: BoxFit.contain)),
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
  }
}
