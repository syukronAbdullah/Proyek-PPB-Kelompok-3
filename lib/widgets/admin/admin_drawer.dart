import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../constants/navigation_tab.dart';
import '../common/profile_photo_avatar.dart';

class AdminDrawer extends StatelessWidget {
  final String namaAdmin;
  final String emailAdmin;
  final String roleAdmin;
  final String unitKerja;
  final String? fotoProfil;
  final ImageProvider? localProfileImage;
  final int selectedIndex;
  final ValueChanged<int> onChangeTab;
  final VoidCallback onLogout;

  const AdminDrawer({
    super.key,
    required this.namaAdmin,
    required this.emailAdmin,
    required this.roleAdmin,
    required this.unitKerja,
    required this.selectedIndex,
    this.fotoProfil,
    this.localProfileImage,
    required this.onChangeTab,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final profileImage = localProfileImage ?? _networkProfileImage();
    final items = [
      _AdminDrawerItem(
        icon: Icons.home_rounded,
        label: 'Beranda',
        tabIndex: NavigationTab.dashboard,
      ),
      _AdminDrawerItem(
        icon: Icons.list_alt_rounded,
        label: 'Laporan',
        tabIndex: NavigationTab.laporan,
      ),
      _AdminDrawerItem(
        icon: Icons.notifications_outlined,
        label: 'Notifikasi',
        tabIndex: NavigationTab.notifikasi,
      ),
      _AdminDrawerItem(
        icon: Icons.person_outline_rounded,
        label: 'Profil',
        tabIndex: NavigationTab.profil,
      ),
    ];

    return Drawer(
      backgroundColor: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          _AdminDrawerHeader(
            name: namaAdmin,
            email: emailAdmin,
            unitKerja: unitKerja,
            role: roleAdmin,
            profileImage: profileImage,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
              children: items.map((item) {
                return _AdminDrawerMenuTile(
                  icon: item.icon,
                  label: item.label,
                  isSelected: selectedIndex == item.tabIndex,
                  onTap: () {
                    Navigator.pop(context);
                    onChangeTab(item.tabIndex);
                  },
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
            child: _AdminLogoutTile(onTap: onLogout),
          ),
        ],
      ),
    );
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

class _AdminDrawerHeader extends StatelessWidget {
  final String name;
  final String email;
  final String unitKerja;
  final String role;
  final ImageProvider? profileImage;

  const _AdminDrawerHeader({
    required this.name,
    required this.email,
    required this.unitKerja,
    required this.role,
    required this.profileImage,
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
                  fallbackIcon: Icons.admin_panel_settings_rounded,
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
                  role.toUpperCase(),
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
          _AdminHeaderInfo(icon: Icons.mail_outline_rounded, text: email),
          const SizedBox(height: 5),
          _AdminHeaderInfo(icon: Icons.apartment_outlined, text: unitKerja),
        ],
      ),
    );
  }
}

class _AdminDrawerMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AdminDrawerMenuTile({
    required this.icon,
    required this.label,
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
          label,
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

class _AdminHeaderInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AdminHeaderInfo({required this.icon, required this.text});

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

class _AdminLogoutTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AdminLogoutTile({required this.onTap});

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
                'Keluar',
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

class _AdminDrawerItem {
  final IconData icon;
  final String label;
  final int tabIndex;

  const _AdminDrawerItem({
    required this.icon,
    required this.label,
    required this.tabIndex,
  });
}
