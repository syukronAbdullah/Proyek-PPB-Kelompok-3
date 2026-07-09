import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class DetailLaporanAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showOwnerActions;

  const DetailLaporanAppBar({
    super.key,
    required this.onBack,
    required this.onShare,
    this.onEdit,
    this.onDelete,
    this.showOwnerActions = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: onBack,
      ),
      title: const Text(
        'Detail Laporan',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      actions: [
        if (showOwnerActions)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit?.call();
              } else if (value == 'delete') {
                onDelete?.call();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 10),
                    Text('Edit Laporan'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Hapus Laporan',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.white, size: 22),
          onPressed: onShare,
        ),
      ],
    );
  }
}
