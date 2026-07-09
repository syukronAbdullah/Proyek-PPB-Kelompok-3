import 'package:flutter/material.dart';

import '../../constants/navigation_tab.dart';
import '../common/account_detail_popup.dart';
import '../common/profile_photo_avatar.dart';

class AdminAppBar extends StatelessWidget {
  final bool isMobile;
  final int selectedIndex;
  final ValueChanged<int> onChangeTab;
  final String namaAdmin;
  final String emailAdmin;
  final String roleAdmin;
  final String unitKerja;
  final ImageProvider? profileImage;

  const AdminAppBar({
    super.key,
    required this.isMobile,
    required this.selectedIndex,
    required this.onChangeTab,
    required this.namaAdmin,
    required this.emailAdmin,
    required this.roleAdmin,
    required this.unitKerja,
    this.profileImage,
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
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              if (isMobile)
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                )
              else
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.account_balance_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),

              const SizedBox(width: 10),

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
                _AdminDesktopNavItem(
                  index: NavigationTab.dashboard,
                  icon: Icons.home_rounded,
                  label: 'Beranda',
                  selectedIndex: selectedIndex,
                  onTap: onChangeTab,
                ),
                _AdminDesktopNavItem(
                  index: NavigationTab.laporan,
                  icon: Icons.list_alt_rounded,
                  label: 'Laporan',
                  selectedIndex: selectedIndex,
                  onTap: onChangeTab,
                ),
                _AdminDesktopNavItem(
                  index: NavigationTab.notifikasi,
                  icon: Icons.notifications_outlined,
                  label: 'Notifikasi',
                  selectedIndex: selectedIndex,
                  onTap: onChangeTab,
                ),
                _AdminDesktopNavItem(
                  index: NavigationTab.profil,
                  icon: Icons.person_outline_rounded,
                  label: 'Profil',
                  selectedIndex: selectedIndex,
                  onTap: onChangeTab,
                ),
                const SizedBox(width: 16),
              ],

              GestureDetector(
                onTap: () => showAccountDetailPopup(
                  context: context,
                  name: namaAdmin,
                  identity: emailAdmin,
                  subtitle: unitKerja,
                  profileImage: profileImage,
                  role: roleAdmin,
                  identityLabel: 'Email',
                  subtitleLabel: 'Unit Kerja',
                  avatarIcon: Icons.admin_panel_settings_rounded,
                  identityIcon: Icons.mail_outline_rounded,
                  subtitleIcon: Icons.apartment_outlined,
                ),
                child: Container(
                  width: 42,
                  height: 42,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: ProfilePhotoAvatar(
                    image: profileImage,
                    radius: 19,
                    fallbackIcon: Icons.admin_panel_settings_rounded,
                    enablePreview: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminDesktopNavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _AdminDesktopNavItem({
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
