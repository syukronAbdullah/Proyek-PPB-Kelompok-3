import 'package:flutter/material.dart';

class AdminDetailAppBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback? onShare;

  const AdminDetailAppBar({
    super.key,
    required this.onBack,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D4A28),
            Color(0xFF1A6B3A),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 6,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: onBack,
              ),
              const Expanded(
                child: Text(
                  'Detail & Tindakan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.share_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: onShare ?? () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}