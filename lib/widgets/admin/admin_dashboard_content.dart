import 'package:flutter/material.dart';

class AdminDashboardContent extends StatelessWidget {
  final bool isLoading;
  final Future<void> Function() onRefresh;
  final Widget welcomeCard;
  final Widget statsGrid;
  final Widget latestLaporanSection;

  const AdminDashboardContent({
    super.key,
    required this.isLoading,
    required this.onRefresh,
    required this.welcomeCard,
    required this.statsGrid,
    required this.latestLaporanSection,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1A5E35),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: onRefresh,
                  color: const Color(0xFF1A5E35),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        welcomeCard,
                        const SizedBox(height: 16),
                        statsGrid,
                        const SizedBox(height: 20),
                        latestLaporanSection,
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}