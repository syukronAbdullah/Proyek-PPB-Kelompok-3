import 'package:flutter/material.dart';

import '../report_form/report_description_field.dart';

class LaporanDescriptionField extends StatelessWidget {
  final TextEditingController controller;

  const LaporanDescriptionField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ReportDescriptionField(controller: controller);
  }
}
