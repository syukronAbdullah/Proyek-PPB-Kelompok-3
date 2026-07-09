import 'package:flutter/material.dart';

import '../report_form/report_submit_button.dart';

class LaporanSubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const LaporanSubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ReportSubmitButton(isLoading: isLoading, onPressed: onPressed);
  }
}
