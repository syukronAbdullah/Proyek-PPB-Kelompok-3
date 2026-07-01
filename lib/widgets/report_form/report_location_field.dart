import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../common/app_input_decoration.dart';

class ReportLocationField extends StatelessWidget {
  final TextEditingController controller;

  const ReportLocationField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lokasi Kejadian',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 6),

        TextFormField(
          controller: controller,
          decoration: appInputDecoration(
            'Gedung IT Lantai 2, Ruang 204',
          ).copyWith(
            prefixIcon: const Icon(
              Icons.location_on_outlined,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Lokasi tidak boleh kosong';
            }

            return null;
          },
        ),
      ],
    );
  }
}