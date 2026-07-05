import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../common/app_input_decoration.dart';

class ReportDescriptionField extends StatelessWidget {
  final TextEditingController controller;

  const ReportDescriptionField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deskripsi Kerusakan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: 4,
          decoration: appInputDecoration(
            'Ceritakan detail kerusakan yang terjadi agar petugas dapat memahami masalah dengan jelas...',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Deskripsi tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }
}