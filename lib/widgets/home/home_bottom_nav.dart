import 'package:flutter/material.dart';

// import '../../config/app_colors.dart';

class HomeBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _HomeNavItem(icon: Icons.home_rounded, label: 'Beranda'),
      _HomeNavItem(icon: Icons.description_outlined, label: 'Laporan'),
      _HomeNavItem(icon: Icons.notifications_outlined, label: 'Notifikasi'),
      _HomeNavItem(icon: Icons.person_outline_rounded, label: 'Profil'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(items.length, (index) {
              final isActive = index == selectedIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFE8F5EE)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          items[index].icon,
                          size: 24,
                          color: isActive
                              ? const Color(0xFF1A6B3A)
                              : const Color(0xFF999999),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[index].label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w400,
                          color: isActive
                              ? const Color(0xFF1A6B3A)
                              : const Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _HomeNavItem {
  final IconData icon;
  final String label;

  const _HomeNavItem({
    required this.icon,
    required this.label,
  });
}