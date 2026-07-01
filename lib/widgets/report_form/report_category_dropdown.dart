import 'package:flutter/material.dart';

import '../../models/kategori_model.dart';
import '../../theme/app_colors.dart';
import '../common/app_input_decoration.dart';

class ReportCategoryDropdown extends StatelessWidget {
  final List<KategoriModel> kategoriList;
  final int? selectedKategoriId;
  final ValueChanged<int?> onChanged;

  const ReportCategoryDropdown({
    super.key,
    required this.kategoriList,
    required this.selectedKategoriId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori Fasilitas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 6),

        DropdownButtonFormField<int>(
          value: selectedKategoriId,
          decoration: appInputDecoration(''),
          hint: const Text(
            'Pilih Kategori',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
          ),
          items: kategoriList.map((kategori) {
            return DropdownMenuItem<int>(
              value: kategori.id,
              child: Text(kategori.nama),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}