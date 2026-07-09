import 'package:flutter/material.dart';

class ProfilePhotoAvatar extends StatelessWidget {
  final ImageProvider? image;
  final double radius;
  final IconData fallbackIcon;
  final bool enablePreview;

  const ProfilePhotoAvatar({
    super.key,
    required this.image,
    required this.radius,
    this.fallbackIcon = Icons.person_rounded,
    this.enablePreview = true,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE8F5EE),
      backgroundImage: image,
      child: image == null
          ? Icon(
              fallbackIcon,
              size: radius * 1.1,
              color: const Color(0xFF1A5E35),
            )
          : null,
    );

    if (!enablePreview || image == null) return avatar;

    return GestureDetector(
      onTap: () => showProfilePhotoPreview(context: context, image: image!),
      child: avatar,
    );
  }
}

Future<void> showProfilePhotoPreview({
  required BuildContext context,
  required ImageProvider image,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Tutup foto profil',
    barrierColor: Colors.black.withValues(alpha: 0.88),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Image(
                        image: image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.14),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
