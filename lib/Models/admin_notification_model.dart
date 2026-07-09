class AdminNotificationModel {
  final int id;
  final int laporanId;
  final String title;
  final String body;
  final bool isRead;
  final String createdAt;
  final Map<String, dynamic>? laporan;

  const AdminNotificationModel({
    required this.id,
    required this.laporanId,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.laporan,
  });

  AdminNotificationModel copyWith({
    bool? isRead,
    Map<String, dynamic>? laporan,
  }) {
    return AdminNotificationModel(
      id: id,
      laporanId: laporanId,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      laporan: laporan ?? this.laporan,
    );
  }

  factory AdminNotificationModel.fromJson(Map<String, dynamic> json) {
    final laporanData = json['laporan'];
    final laporan = laporanData is Map
        ? Map<String, dynamic>.from(laporanData)
        : null;
    final data = json['data'];
    final dataLaporanId = data is Map ? data['laporan_id'] : null;
    final laporanId = _asInt(
      json['laporan_id'] ??
          json['report_id'] ??
          dataLaporanId ??
          laporan?['id'],
    );

    final title = (json['title'] ?? json['judul'] ?? '').toString();
    final body =
        (json['body'] ??
                json['subtitle'] ??
                json['pesan'] ??
                json['message'] ??
                '')
            .toString();

    return AdminNotificationModel(
      id: _asInt(json['id']),
      laporanId: laporanId,
      title: title.isNotEmpty ? title : 'Laporan baru',
      body: body,
      isRead: _asRead(json),
      createdAt: (json['created_at'] ?? '').toString(),
      laporan: laporan,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _asRead(Map<String, dynamic> json) {
    final raw =
        json['is_read'] ?? json['dibaca'] ?? json['read'] ?? json['status'];
    if (raw is bool) return raw;
    if (raw is num) return raw == 1;
    final value = raw?.toString().toLowerCase();
    return json['read_at'] != null ||
        value == 'read' ||
        value == 'dibaca' ||
        value == '1';
  }
}
