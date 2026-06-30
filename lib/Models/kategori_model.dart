class KategoriModel {
  final int id;
  final String nama;
  final String icon;

  KategoriModel({
    required this.id,
    required this.nama,
    required this.icon,
  });

  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    return KategoriModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      icon: json['icon'] ?? '',
    );
  }
}