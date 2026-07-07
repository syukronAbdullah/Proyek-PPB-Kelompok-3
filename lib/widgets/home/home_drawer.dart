import 'package:flutter/material.dart';

import '../../constants/navigation_tab.dart';

class HomeDrawer extends StatelessWidget {
  final String namaUser;
  final String nimUser;
  final String prodiUser;
  final ValueChanged<int> onChangeTab;
  final VoidCallback onLogout;

  const HomeDrawer({
    super.key,
    required this.namaUser,
    required this.nimUser,
    required this.prodiUser,
    required this.onChangeTab,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
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
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Color(0xFF1A5E35),
                size: 40,
              ),
            ),
            accountName: Text(
              namaUser,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            accountEmail: Text(
              'NIM: $nimUser\n$prodiUser',
              style: const TextStyle(
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
          _DrawerMenuItem(
            icon: Icons.home_rounded,
            title: 'Beranda',
            onTap: () {
              Navigator.pop(context);
              onChangeTab(NavigationTab.dashboard);
            },
          ),
          _DrawerMenuItem(
            icon: Icons.description_outlined,
            title: 'Daftar Laporan',
            onTap: () {
              Navigator.pop(context);
              onChangeTab(NavigationTab.laporan);
            },
          ),
          _DrawerMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifikasi',
            onTap: () {
              Navigator.pop(context);
              onChangeTab(NavigationTab.notifikasi);
            },
          ),
          _DrawerMenuItem(
            icon: Icons.person_outline_rounded,
            title: 'Profil Saya',
            onTap: () {
              Navigator.pop(context);
              onChangeTab(NavigationTab.profil);
            },
          ),
          const Divider(),
          const Spacer(),
          ListTile(
            leading: const Icon(
              Icons.logout_rounded,
              color: Colors.red,
            ),
            title: const Text(
              'Keluar Akun',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: onLogout,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF1A5E35),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }
}