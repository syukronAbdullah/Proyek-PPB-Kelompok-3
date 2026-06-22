class LaporanModel {
  final int id;
  final int userId;
  final int kategoriId;
  final String judul;
  final String deskripsi;
  final String lokasi;
  final String status;
  final String? catatanAdmin;
  final String createdAt;
  final String namaKategori; // Kita ambil string nama kategorinya langsung ke sini
  final List<dynamic> foto;

  LaporanModel({
    required this.id,
    required this.userId,
    required this.kategoriId,
    required this.judul,
    required this.deskripsi,
    required this.lokasi,
    required this.status,
    this.catatanAdmin,
    required this.createdAt,
    required this.namaKategori,
    required this.foto,
  });

  // ── GETTER WAKTU UNTUK JINAKKAN HOME SCREEN ─────────────────
  String get waktu {
    if (createdAt.isEmpty) return 'Baru saja';
    try {
      // Mengambil potongan tanggal saja (YYYY-MM-DD) dari data created_at Laravel
      return createdAt.substring(0, 10);
    } catch (e) {
      return createdAt;
    }
  }

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    // Ambil objek kategori di dalam JSON
    final kategoriObj = json['kategori'] as Map<String, dynamic>?;

    return LaporanModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      kategoriId: json['kategori_id'] ?? 0,
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      lokasi: json['lokasi'] ?? '',
      status: json['status'] ?? 'menunggu',
      catatanAdmin: json['catatan_admin'],
      createdAt: json['created_at'] ?? '',
      // Ekstrak string "nama" dari objek kategori
      namaKategori: kategoriObj != null ? (kategoriObj['nama'] ?? '') : '',
      foto: json['foto'] ?? [],
    );
  }
}