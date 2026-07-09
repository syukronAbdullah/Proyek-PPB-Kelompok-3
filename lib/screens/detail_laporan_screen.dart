import 'package:flutter/material.dart';

import '../models/laporan_model.dart';
import '../theme/app_colors.dart';
import '../widgets/laporan/detail_laporan_app_bar.dart';
import '../widgets/laporan/detail_laporan_info_section.dart';
import '../widgets/laporan/detail_laporan_photo_section.dart';
import '../widgets/laporan/detail_laporan_timeline.dart';

class DetailLaporanScreen extends StatelessWidget {
  final LaporanModel laporan;

  const DetailLaporanScreen({super.key, required this.laporan});

  @override
  Widget build(BuildContext context) {
    final currentStatus = laporan.status.toLowerCase();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: DetailLaporanAppBar(
            onBack: () => Navigator.pop(context),
            onShare: () {},
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DetailLaporanInfoSection(
                        status: currentStatus,
                        categoryName: laporan.namaKategori,
                        title: laporan.judul,
                        location: laporan.lokasi,
                        description: laporan.deskripsi,
                        photoSection: DetailLaporanPhotoSection(
                          fotoUrls: laporan.fotoUrls,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  thickness: 6,
                  color: AppColors.mutedBackground,
                  height: 6,
                ),
                DetailLaporanTimeline(
                  laporan: laporan,
                  currentStatus: currentStatus,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
