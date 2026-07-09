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

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _PhotoBox(photo: photos[index]),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyPhotoSection extends StatelessWidget {
  const _EmptyPhotoSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 40,
          color: Colors.grey,
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
        width: 160,
        height: 160,
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

class _BrokenPhoto extends StatelessWidget {
  const _BrokenPhoto();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
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
      width: 160,
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
