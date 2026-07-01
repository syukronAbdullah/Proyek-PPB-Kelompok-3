import 'dart:io';

class DuplicateCheckResult {
  final List<File> files;
  final int duplicateCount;

  const DuplicateCheckResult({
    required this.files,
    required this.duplicateCount,
  });
}