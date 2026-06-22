enum OnboardingIllustration { report, monitor, check }

class OnboardingData {
  final String title;
  final String description;
  final OnboardingIllustration illustration;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.illustration,
  });

  static const List<OnboardingData> pages = [
    OnboardingData(
      title: 'Laporkan Masalah\nFasilitas',
      description:
          'Temukan kerusakan fasilitas di kampus? Laporkan langsung melalui aplikasi dengan mudah dan cepat.',
      illustration: OnboardingIllustration.report,
    ),
    OnboardingData(
      title: 'Dipantau Tim\nKampus',
      description:
          'Setiap laporan langsung diterima dan ditindaklanjuti oleh tim sarana prasarana UIN',
      illustration: OnboardingIllustration.monitor,
    ),
    OnboardingData(
      title: 'Pantau Status\nLaporan',
      description:
          'Lacak perkembangan laporan Anda secara real-time hingga masalah terselesaikan.',
      illustration: OnboardingIllustration.check,
    ),
  ];
}
