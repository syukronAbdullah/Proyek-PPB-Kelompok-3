import 'package:flutter/material.dart';

import '../../models/kategori_model.dart';
import '../report_form/report_category_dropdown.dart';

class LaporanCategoryDropdown extends StatelessWidget {
  final List<KategoriModel> kategoriList;
  final int? selectedKategoriId;
  final ValueChanged<int?> onChanged;

  const LaporanCategoryDropdown({
    super.key,
    required this.kategoriList,
    required this.selectedKategoriId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ReportCategoryDropdown(
      kategoriList: kategoriList,
      selectedKategoriId: selectedKategoriId,
      onChanged: onChanged,
    );
  }
}
