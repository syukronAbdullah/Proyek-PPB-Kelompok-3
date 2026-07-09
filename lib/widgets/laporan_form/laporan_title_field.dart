import 'package:flutter/material.dart';

import '../report_form/report_title_field.dart';

class LaporanTitleField extends StatelessWidget {
  final TextEditingController controller;

  const LaporanTitleField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ReportTitleField(controller: controller);
  }
}
