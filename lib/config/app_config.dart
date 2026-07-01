class AppConfig {
  AppConfig._();

  /// Maksimal jumlah foto per laporan
  static const int maxReportPhotos = 4;

  /// Maksimal ukuran satu foto (MB)
  static const int maxPhotoSizeMB = 3;

  /// Kualitas kompresi foto (0–100)
  static const int imageQuality = 85;
}