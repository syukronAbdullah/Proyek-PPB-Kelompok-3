import 'package:flutter/material.dart';

import '../../models/kategori_model.dart';

import 'report_title_field.dart';
import 'report_category_dropdown.dart';
import 'report_location_field.dart';
import 'report_description_field.dart';

class ReportFormCard extends StatelessWidget {
  const ReportFormCard({
    super.key,
    required this.judulController,
    required this.lokasiController,
    required this.deskripsiController,
    required this.kategoriList,
    required this.selectedKategoriId,
    required this.onKategoriChanged,
  });

  final TextEditingController judulController;
  final TextEditingController lokasiController;
  final TextEditingController deskripsiController;

  final List<KategoriModel> kategoriList;

  final int? selectedKategoriId;

  final ValueChanged<int?> onKategoriChanged;

  @override
Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      // Judul
      ReportTitleField(
        controller: judulController,
      ),

      const SizedBox(height: 16),

      // Kategori
      ReportCategoryDropdown(
        kategoriList: kategoriList,
        selectedKategoriId: selectedKategoriId,
        onChanged: onKategoriChanged,
      ),

      const SizedBox(height: 16),

      // Lokasi
      ReportLocationField(
          controller: lokasiController,
        ),

        const SizedBox(height: 16),

      // Deskripsi
      ReportDescriptionField(
        controller: deskripsiController,
      ),
      const SizedBox(height: 6),
    ],
  );
}
}