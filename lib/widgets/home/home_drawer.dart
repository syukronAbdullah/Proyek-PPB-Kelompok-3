import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../constants/navigation_tab.dart';
import '../common/profile_photo_avatar.dart';

class HomeDrawer extends StatelessWidget {
  final String namaUser;
  final String nimUser;
  final String prodiUser;
  final String? fotoProfil;
  final ImageProvider? localProfileImage;
  final int selectedIndex;
  final ValueChanged<int> onChangeTab;
  final VoidCallback onLogout;

  const HomeDrawer({
    super.key,
    required this.namaUser,
    required this.nimUser,
    required this.prodiUser,
    required this.selectedIndex,
    this.fotoProfil,
    this.localProfileImage,
    required this.onChangeTab,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final profileImage = localProfileImage ?? _networkProfileImage();

    return Drawer(
      backgroundColor: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          _DrawerHeader(
            name: namaUser,
            primaryInfo: 'NIM $nimUser',
            secondaryInfo: prodiUser,
            badge: 'MAHASISWA',
            profileImage: profileImage,
            fallbackIcon: Icons.person_rounded,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
              children: [
                _DrawerMenuItem(
                  icon: Icons.home_rounded,
                  title: 'Beranda',
                  isSelected: selectedIndex == NavigationTab.dashboard,
                  onTap: () => _selectTab(context, NavigationTab.dashboard),
                ),
                _DrawerMenuItem(
                  icon: Icons.description_outlined,
                  title: 'Daftar Laporan',
                  isSelected: selectedIndex == NavigationTab.laporan,
                  onTap: () => _selectTab(context, NavigationTab.laporan),
                ),
                _DrawerMenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifikasi',
                  isSelected: selectedIndex == NavigationTab.notifikasi,
                  onTap: () => _selectTab(context, NavigationTab.notifikasi),
                ),
                _DrawerMenuItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Profil Saya',
                  isSelected: selectedIndex == NavigationTab.profil,
                  onTap: () => _selectTab(context, NavigationTab.profil),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
            child: _LogoutTile(onTap: onLogout),
          ),
        ],
      ),
    );
  }

  void _selectTab(BuildContext context, int tabIndex) {
    Navigator.pop(context);
    onChangeTab(tabIndex);
  }

  ImageProvider? _networkProfileImage() {
    final photoUrl = _resolveProfilePhotoUrl(fotoProfil);
    if (photoUrl == null) return null;

    return NetworkImage(photoUrl);
  }

  String? _resolveProfilePhotoUrl(String? foto) {
    if (foto == null || foto.isEmpty) return null;
    if (foto.startsWith('http')) return foto;

    return '${ApiConfig.baseUrl.replaceFirst('/api', '')}$foto';
  }
}

class _DrawerHeader extends StatelessWidget {
  final String name;
  final String primaryInfo;
  final String secondaryInfo;
  final String badge;
  final ImageProvider? profileImage;
  final IconData fallbackIcon;

  const _DrawerHeader({
    required this.name,
    required this.primaryInfo,
    required this.secondaryInfo,
    required this.badge,
    required this.profileImage,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        22,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B3B24),
            Color(0xFF1A6B3A),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.45)),
                ),
                child: ProfilePhotoAvatar(
                  image: profileImage,
                  radius: 35,
                  fallbackIcon: fallbackIcon,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.24)),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          _HeaderInfo(icon: Icons.badge_outlined, text: primaryInfo),
          const SizedBox(height: 5),
          _HeaderInfo(icon: Icons.school_outlined, text: secondaryInfo),
        ],
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground =
        isSelected ? const Color(0xFF0F4F2D) : const Color(0xFF334155);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        minLeadingWidth: 0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileColor: isSelected ? const Color(0xFFE8F5EE) : Colors.transparent,
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: foreground, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: foreground,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        trailing: isSelected
            ? const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF0F4F2D),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

class _HeaderInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeaderInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.78), size: 15),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.84),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _LogoutTile extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF1F2),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 20),
              SizedBox(width: 12),
              Text(
                'Keluar Akun',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
