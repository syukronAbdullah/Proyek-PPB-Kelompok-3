import 'package:flutter/material.dart';

import '../../models/kategori_model.dart';
import '../common/app_input_decoration.dart';
import 'report_title_field.dart';
import 'report_category_dropdown.dart';
import 'report_location_field.dart';

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

      TextFormField(
        controller: judulController,
        decoration: appInputDecoration('Contoh: Kran Air Patah'),
        validator: (v) =>
            v == null || v.isEmpty
                ? 'Judul tidak boleh kosong'
                : null,
      ),

      const SizedBox(height: 16),

      // Kategori
      ReportCategoryDropdown(
        kategoriList: kategoriList,
        selectedKategoriId: selectedKategoriId,
        onChanged: onKategoriChanged,
      ),

      const SizedBox(height: 16),

      DropdownButtonFormField<int>(
        value: selectedKategoriId,
        hint: const Text(
          'Pilih Kategori',
          style: TextStyle(
            color: Colors.black38,
            fontSize: 14,
          ),
        ),
        decoration: appInputDecoration(''),
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        items: kategoriList.map((kat) {
          return DropdownMenuItem<int>(
            value: kat.id,
            child: Text(kat.nama),
          );
        }).toList(),
        onChanged: onKategoriChanged,
      ),

      const SizedBox(height: 16),

      // Lokasi
      ReportLocationField(
          controller: lokasiController,
        ),

        const SizedBox(height: 16),

      TextFormField(
        controller: lokasiController,
        decoration: appInputDecoration(
          'Gedung IT Lantai 2, Ruang 204',
        ).copyWith(
          prefixIcon: const Icon(Icons.location_on_outlined),
        ),
        validator: (v) =>
            v == null || v.isEmpty
                ? 'Lokasi tidak boleh kosong'
                : null,
      ),

      const SizedBox(height: 16),

      // Deskripsi
      const Text(
        'Deskripsi Kerusakan',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 6),

      TextFormField(
        controller: deskripsiController,
        maxLines: 4,
        decoration: appInputDecoration(
          'Ceritakan detail kerusakan yang terjadi agar petugas dapat memahami masalah dengan jelas...',
        ),
        validator: (v) =>
            v == null || v.isEmpty
                ? 'Deskripsi tidak boleh kosong'
                : null,
      ),
    ],
  );
}
}