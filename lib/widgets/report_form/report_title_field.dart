import 'package:flutter/material.dart';

import '../common/app_input_decoration.dart';
import '../../theme/app_colors.dart';

class ReportTitleField extends StatelessWidget {
  final TextEditingController controller;

  const ReportTitleField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Judul Laporan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 6),

        TextFormField(
          controller: controller,
          decoration: appInputDecoration(
            'Contoh: Kran Air Patah',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Judul tidak boleh kosong';
            }

            return null;
          },
        ),
      ],
    );
  }
}