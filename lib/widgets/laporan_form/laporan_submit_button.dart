import 'package:flutter/material.dart';

import '../report_form/report_submit_button.dart';

class LaporanSubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String label;

  const LaporanSubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    this.label = 'Kirim Laporan',
  });

  @override
  Widget build(BuildContext context) {
    return ReportSubmitButton(
      isLoading: isLoading,
      onPressed: onPressed,
      label: label,
    );
  }
}
