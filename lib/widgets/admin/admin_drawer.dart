import 'package:flutter/material.dart';

import '../../constants/navigation_tab.dart';

class AdminDrawer extends StatelessWidget {
  final ValueChanged<int> onChangeTab;
  final VoidCallback onLogout;

  const AdminDrawer({
    super.key,
    required this.onChangeTab,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D4A28),
                  Color(0xFF1A6B3A),
                ],
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.admin_panel_settings_rounded,
                color: Color(0xFF1A5E35),
                size: 36,
              ),
            ),
            accountName: Text(
              'Panel Admin',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            accountEmail: Text('Sarana & Prasarana UIN'),
          ),
          ...items.map((item) {
            return ListTile(
              leading: Icon(
                item.icon,
                color: const Color(0xFF1A5E35),
              ),
              title: Text(
                item.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onChangeTab(item.tabIndex);
              },
            );
          }),
          const Divider(),
          const Spacer(),
          ListTile(
            leading: const Icon(
              Icons.logout_rounded,
              color: Colors.red,
            ),
            title: const Text(
              'Keluar',
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