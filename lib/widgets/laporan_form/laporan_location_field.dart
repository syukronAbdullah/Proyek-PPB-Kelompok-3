import 'package:flutter/material.dart';

import '../report_form/report_location_field.dart';

class LaporanLocationField extends StatelessWidget {
  final TextEditingController controller;

  const LaporanLocationField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ReportLocationField(controller: controller);
  }
}
