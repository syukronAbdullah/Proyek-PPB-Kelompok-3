class ProdiModel {
  final int id;
  final int fakultasId;
  final String namaProdi;

  ProdiModel({
    required this.id,
    required this.fakultasId,
    required this.namaProdi,
  });

  factory ProdiModel.fromJson(Map<String, dynamic> json) {
    return ProdiModel(
      id: json['id'] ?? 0,
      fakultasId: json['fakultas_id'] ?? 0,
      namaProdi: json['nama_prodi'] ?? '',
    );
  }
}