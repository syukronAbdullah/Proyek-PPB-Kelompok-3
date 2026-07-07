import 'package:flutter/material.dart';

import '../../constants/navigation_tab.dart';

class HomeAppBar extends StatelessWidget {
  final bool isMobile;
  final int selectedIndex;
  final ValueChanged<int> onChangeTab;
  final VoidCallback onLogout;

  const HomeAppBar({
    super.key,
    required this.isMobile,
    required this.selectedIndex,
    required this.onChangeTab,
    required this.onLogout,
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
            horizontal: 12,
            vertical: 8,
          ),
          child: Row(
            children: [
              if (isMobile)
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(left: 8, right: 16),
                  child: Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

              const Text(
                'SILAPOR UIN',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),

              const Spacer(),

              if (!isMobile) ...[
                _DesktopNavItem(
                  index: NavigationTab.dashboard,
                  icon: Icons.home_rounded,
                  label: 'Beranda',
                  selectedIndex: selectedIndex,
                  onTap: onChangeTab,
                ),
                _DesktopNavItem(
                  index: NavigationTab.laporan,
                  icon: Icons.description_outlined,
                  label: 'Laporan',
                  selectedIndex: selectedIndex,
                  onTap: onChangeTab,
                ),
                _DesktopNavItem(
                  index: NavigationTab.notifikasi,
                  icon: Icons.notifications_outlined,
                  label: 'Notifikasi',
                  selectedIndex: selectedIndex,
                  onTap: onChangeTab,
                ),
                _DesktopNavItem(
                  index: NavigationTab.profil,
                  icon: Icons.person_outline_rounded,
                  label: 'Profil',
                  selectedIndex: selectedIndex,
                  onTap: onChangeTab,
                ),
                const SizedBox(width: 16),
              ],

              IconButton(
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: onLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopNavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _DesktopNavItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = selectedIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}