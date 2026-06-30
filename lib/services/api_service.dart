import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

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
    await prefs.remove('token');
    await prefs.remove('user');
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

  // ── LOGIN ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
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
      Map<String, dynamic> body) async {
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
      Map<String, dynamic> body) async {
    // Memanggil API ganti password dengan membawa header token keamanan login
    final res = await http.post(
      Uri.parse(ApiConfig.gantiPassword), // Pastikan variabel ini ada di ApiConfig
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
      Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse(ApiConfig.laporan),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }

  // ── DELETE LAPORAN ─────────────────────────────────────────
  static Future<Map<String, dynamic>> hapusLaporan(int id) async {
    final res = await http.delete(
      Uri.parse('${ApiConfig.laporan}/$id'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
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
    await http.post(
      Uri.parse(ApiConfig.bacaSemua),
      headers: await _headers(),
    );
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
  static Future<Map<String, dynamic>> getAdminLaporan(
      {String? status, String? search}) async {
    var url = ApiConfig.adminLaporan;
    final params = <String>[];
    if (status != null) params.add('status=$status');
    if (search != null) params.add('search=$search');
    if (params.isNotEmpty) url += '?${params.join('&')}';

    final res = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ── ADMIN: UPDATE STATUS LAPORAN ───────────────────────────
  static Future<Map<String, dynamic>> updateStatusLaporan(
      int id, String status, {String? catatan}) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.adminLaporan}/$id/status'),
      headers: await _headers(),
      body: jsonEncode({
        'status': status,
        'catatan_admin': catatan,
      }),
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