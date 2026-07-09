import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'dart:io';

class ApiService {
  // ── Simpan token setelah login ─────────────────────────────
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // ── Ambil token ────────────────────────────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ── Hapus token saat logout ────────────────────────────────
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> clearSession() async {
    await clearToken();
  }

  // ── Header dengan token ────────────────────────────────────
  static Future<Map<String, String>> _headers({bool withToken = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withToken) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Map<String, dynamic> _decodeJsonResponse(http.Response response) {
    if (response.body.trim().isEmpty) {
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'statusCode': response.statusCode,
      };
    }

    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic>) {
      data['statusCode'] = response.statusCode;
      data['success'] ??= response.statusCode >= 200 && response.statusCode < 300;
      return data;
    }

    return {
      'success': response.statusCode >= 200 && response.statusCode < 300,
      'statusCode': response.statusCode,
      'data': data,
    };
  }

  // ── LOGIN ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse(ApiConfig.login),
      headers: await _headers(withToken: false),
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (data['success'] == true) {
      await saveToken(data['token']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(data['user']));
    }
    return data;
  }

  // ── REGISTER ───────────────────────────────────────────────
  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> body,
  ) async {
    final res = await http.post(
      Uri.parse(ApiConfig.register),
      headers: await _headers(withToken: false),
      body: jsonEncode(body),
    );
    final data = jsonDecode(res.body);
    if (data['success'] == true) {
      await saveToken(data['token']);
    }
    return data;
  }

  // ── LOGOUT ─────────────────────────────────────────────────
  static Future<void> logout() async {
    try {
      final headers = await _headers();
      await http.post(Uri.parse(ApiConfig.logout), headers: headers);
    } catch (_) {}
    await clearToken();
  }

  // ── UBAH KATA SANDI (BARU TAMBAHAN) ────────────────────────
  static Future<Map<String, dynamic>> changePassword(
    Map<String, dynamic> body,
  ) async {
    // Memanggil API ganti password dengan membawa header token keamanan login
    final res = await http.post(
      Uri.parse(
        ApiConfig.gantiPassword,
      ), // Pastikan variabel ini ada di ApiConfig
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }

  // ── GET ME (data user yang sedang login) ───────────────────
  static Future<Map<String, dynamic>> getMe() async {
    final res = await http.get(
      Uri.parse(ApiConfig.me),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ── GET PROFIL ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> getProfil() async {
    final res = await http.get(
      Uri.parse(ApiConfig.profil),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ── GET FAKULTAS ───────────────────────────────────────────
  static Future<List<dynamic>> getFakultas() async {
    final res = await http.get(Uri.parse(ApiConfig.fakultas));
    final data = jsonDecode(res.body);
    return data['fakultas'] ?? [];
  }

  // ── GET KATEGORI ───────────────────────────────────────────
  static Future<Map<String, dynamic>> getKategori() async {
    final res = await http.get(
      Uri.parse(ApiConfig.kategori),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ── GET LAPORAN ────────────────────────────────────────────
  static Future<Map<String, dynamic>> getLaporan() async {
    final res = await http.get(
      Uri.parse(ApiConfig.laporan),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ── GET DETAIL LAPORAN ─────────────────────────────────────
  static Future<Map<String, dynamic>> getDetailLaporan(int id) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.laporan}/$id'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ── POST BUAT LAPORAN BARU ─────────────────────────────────
  static Future<Map<String, dynamic>> buatLaporan(
    Map<String, dynamic> body,
    List<File> photos,
  ) async {
    final token = await getToken();

    final request = http.MultipartRequest('POST', Uri.parse(ApiConfig.laporan));

    request.headers['Accept'] = 'application/json';

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    body.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    for (final photo in photos) {
      request.files.add(
        await http.MultipartFile.fromPath('foto[]', photo.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return jsonDecode(response.body);
  }

  // EDIT LAPORAN
  static Future<Map<String, dynamic>> updateLaporan(
    int laporanId,
    Map<String, dynamic> body, {
    List<File> photos = const [],
  }) async {
    final token = await getToken();

    if (photos.isEmpty) {
      final response = await http.put(
        Uri.parse('${ApiConfig.laporan}/$laporanId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      return _decodeJsonResponse(response);
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.laporan}/$laporanId'),
    );

    request.headers['Accept'] = 'application/json';
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['_method'] = 'PUT';
    body.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    for (final photo in photos) {
      request.files.add(
        await http.MultipartFile.fromPath('foto[]', photo.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _decodeJsonResponse(response);
  }

  // ── DELETE LAPORAN ─────────────────────────────────────────
  static Future<Map<String, dynamic>> hapusLaporan(int id) async {
    final res = await http.delete(
      Uri.parse('${ApiConfig.laporan}/$id'),
      headers: await _headers(),
    );
    return _decodeJsonResponse(res);
  }

  static Future<Map<String, dynamic>> deleteLaporan(int id) async {
    return hapusLaporan(id);
  }

  static Future<Map<String, dynamic>> deleteAccount(String password) async {
    final res = await http.delete(
      Uri.parse(ApiConfig.deleteAccount),
      headers: await _headers(),
      body: jsonEncode({'password': password}),
    );
    return _decodeJsonResponse(res);
  }

  // ── GET NOTIFIKASI ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getNotifikasi() async {
    final res = await http.get(
      Uri.parse(ApiConfig.notifikasi),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ── BACA NOTIFIKASI ────────────────────────────────────────
  static Future<void> bacaNotifikasi(int id) async {
    await http.post(
      Uri.parse('${ApiConfig.notifikasi}/$id/baca'),
      headers: await _headers(),
    );
  }

  // ── BACA SEMUA NOTIFIKASI ──────────────────────────────────
  static Future<void> bacaSemuaNotifikasi() async {
    await http.post(Uri.parse(ApiConfig.bacaSemua), headers: await _headers());
  }

  // ── ADMIN: GET DASHBOARD ───────────────────────────────────
  static Future<Map<String, dynamic>> getAdminDashboard() async {
    final res = await http.get(
      Uri.parse(ApiConfig.adminDashboard),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ── ADMIN: GET SEMUA LAPORAN ───────────────────────────────
  static Future<Map<String, dynamic>> getAdminLaporan({
    String? status,
    String? search,
  }) async {
    var url = ApiConfig.adminLaporan;
    final params = <String>[];
    if (status != null) params.add('status=$status');
    if (search != null) params.add('search=$search');
    if (params.isNotEmpty) url += '?${params.join('&')}';

    final res = await http.get(Uri.parse(url), headers: await _headers());
    return jsonDecode(res.body);
  }

  // ADMIN: GET DETAIL LAPORAN
  static Future<Map<String, dynamic>> getAdminDetailLaporan(int id) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.adminLaporan}/$id'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ADMIN: GET NOTIFIKASI LAPORAN BARU
  static Future<Map<String, dynamic>> getAdminNotifikasi() async {
    final res = await http.get(
      Uri.parse(ApiConfig.adminNotifikasi),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ADMIN: TANDAI NOTIFIKASI SUDAH DIBACA
  static Future<Map<String, dynamic>> bacaAdminNotifikasi(int id) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.adminNotifikasi}/$id/baca'),
      headers: await _headers(),
    );
    return _decodeJsonResponse(res);
  }

  // ADMIN: TANDAI SEMUA NOTIFIKASI SUDAH DIBACA
  static Future<Map<String, dynamic>> bacaSemuaAdminNotifikasi() async {
    final res = await http.post(
      Uri.parse(ApiConfig.adminBacaSemuaNotifikasi),
      headers: await _headers(),
    );
    return _decodeJsonResponse(res);
  }

  // ── ADMIN: UPDATE STATUS LAPORAN ───────────────────────────
  static Future<Map<String, dynamic>> updateStatusLaporan(
    int id,
    String status, {
    String? catatan,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.adminLaporan}/$id/status'),
      headers: await _headers(),
      body: jsonEncode({'status': status, 'catatan_admin': catatan}),
    );
    return jsonDecode(res.body);
  }

  // ── GET PRODI BERDASARKAN FAKULTAS ─────────────────────────
  static Future<List<dynamic>> getProdi(int? fakultasId) async {
    // Jika fakultasId diisi, tembak ke URL: /api/prodi?fakultas_id=1
    final url = fakultasId != null
        ? '${ApiConfig.prodi}?fakultas_id=$fakultasId'
        : ApiConfig.prodi;

    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);
    return data['prodi'] ?? [];
  }
}
