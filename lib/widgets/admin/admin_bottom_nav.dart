import 'package:flutter/material.dart';

import '../../constants/navigation_tab.dart';

class AdminBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const AdminBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _AdminNavItem(
        icon: Icons.home_rounded,
        label: 'Beranda',
        tabIndex: NavigationTab.dashboard,
      ),
      _AdminNavItem(
        icon: Icons.list_alt_rounded,
        label: 'Laporan',
        tabIndex: NavigationTab.laporan,
      ),
      _AdminNavItem(
        icon: Icons.notifications_outlined,
        label: 'Notifikasi',
        tabIndex: NavigationTab.notifikasi,
      ),
      _AdminNavItem(
        icon: Icons.person_outline_rounded,
        label: 'Profil',
        tabIndex: NavigationTab.profil,
      ),
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
            children: items.map((item) {
              final isActive = item.tabIndex == selectedIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(item.tabIndex),
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
                          item.icon,
                          size: 24,
                          color: isActive
                              ? const Color(0xFF1A6B3A)
                              : const Color(0xFF999999),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
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
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _AdminNavItem {
  final IconData icon;
  final String label;
  final int tabIndex;

  const _AdminNavItem({
    required this.icon,
    required this.label,
    required this.tabIndex,
  });
}