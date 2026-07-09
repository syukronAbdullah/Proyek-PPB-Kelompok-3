import 'package:flutter/material.dart';

import '../../config/api_config.dart';

class AdminDetailPhotoSection extends StatelessWidget {
  final List<dynamic> photos;

  const AdminDetailPhotoSection({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const _EmptyPhotoSection();
    }

    final visiblePhotos = photos.take(4).toList();
    final remainingPhotos = photos.length - 4;

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: visiblePhotos.length == 1
                ? _PhotoBox(photo: visiblePhotos[0])
                : Column(
                    children: [
                      Expanded(child: _PhotoBox(photo: visiblePhotos[0])),
                      const SizedBox(height: 2),
                      if (visiblePhotos.length > 2)
                        Expanded(child: _PhotoBox(photo: visiblePhotos[2])),
                    ],
                  ),
          ),
          if (visiblePhotos.length > 1) ...[
            const SizedBox(width: 2),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: _PhotoBox(photo: visiblePhotos[1])),
                  if (visiblePhotos.length > 3) ...[
                    const SizedBox(height: 2),
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _PhotoBox(photo: visiblePhotos[3]),
                          if (remainingPhotos > 0)
                            _RemainingPhotoOverlay(count: remainingPhotos),
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
}

class _EmptyPhotoSection extends StatelessWidget {
  const _EmptyPhotoSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      color: const Color(0xFFE2E8F0),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 40,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'Tidak ada foto',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoBox extends StatelessWidget {
  final dynamic photo;

  const _PhotoBox({required this.photo});

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl(photo);

    return GestureDetector(
      onTap: imageUrl.isEmpty
          ? null
          : () {
              showDialog(
                context: context,
                builder: (_) => _PhotoPreviewDialog(imageUrl: imageUrl),
              );
            },
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, error, __) {
          return const _BrokenPhoto();
        },
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;

          return const _LoadingPhoto();
        },
      ),
    );
  }

  String _resolveImageUrl(dynamic photo) {
    String imageUrl = '';

    if (photo is String) {
      imageUrl = photo;
    } else if (photo is Map && photo['url_foto'] != null) {
      imageUrl = photo['url_foto'].toString();
    }

    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = '${ApiConfig.baseUrl.replaceFirst('/api', '')}$imageUrl';
    }

    return imageUrl;
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

class _RemainingPhotoOverlay extends StatelessWidget {
  final int count;

  const _RemainingPhotoOverlay({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Text(
          '+$count Foto',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _BrokenPhoto extends StatelessWidget {
  const _BrokenPhoto();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE2E8F0),
      child: const Icon(
        Icons.broken_image_outlined,
        color: Colors.grey,
        size: 28,
      ),
    );
  }
}

class _LoadingPhoto extends StatelessWidget {
  const _LoadingPhoto();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE2E8F0),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF1A5E35),
        ),
      ),
    );
  }
}
