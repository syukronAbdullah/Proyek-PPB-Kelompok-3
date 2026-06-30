class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Auth
  static const String login    = '$baseUrl/login';
  static const String register = '$baseUrl/register';
  static const String logout   = '$baseUrl/logout';
  static const String me       = '$baseUrl/me';

  // Data umum
  static const String fakultas = '$baseUrl/fakultas';
  static const String kategori = '$baseUrl/kategori';

  // Laporan
  static const String laporan  = '$baseUrl/laporan';

  // Notifikasi
  static const String notifikasi = '$baseUrl/notifikasi';
  static const String bacaSemua  = '$baseUrl/notifikasi/baca-semua';

  // Profil
  static const String profil       = '$baseUrl/profil';
  static const String updateProfil = '$baseUrl/profil/update';

  // Admin
  static const String adminDashboard = '$baseUrl/admin/dashboard';
  static const String adminLaporan   = '$baseUrl/admin/laporan';

  // Ganti Password
  //static const String gantiPassword = '$baseUrl/ganti-password';
  static const String gantiPassword = '$baseUrl/profil/password';
  // static const String gantiPassword = '$baseUrl/password';

  // ambl prodi dari fakultas tertentu
  static const String prodi = '$baseUrl/prodi';
}