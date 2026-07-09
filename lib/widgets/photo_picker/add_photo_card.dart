import 'package:flutter/material.dart';

class AddPhotoCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddPhotoCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD2D2D2)),
      ),
      child: InkWell(
        onTap: () {
          debugPrint("AddPhotoCard ditekan");
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              color: Colors.black.withValues(alpha: 0.4),
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              "Tambah Foto",
              style: TextStyle(
                fontSize: 11,
                color: Colors.black.withValues(alpha: 0.4),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
