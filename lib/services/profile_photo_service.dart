import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/profile_photo_crop_screen.dart';

class ProfilePhotoService {
  static const String mahasiswaRole = 'mahasiswa';
  static const String adminRole = 'admin';

  static String _pathKey(String role) => '${role}_profile_photo_path';
  static String _legacyDataKey(String role) => '${role}_profile_photo_data';

  static Future<File?> loadPhoto(String role) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString(_pathKey(role));

    if (savedPath != null && savedPath.isNotEmpty) {
      final file = File(savedPath);
      if (await file.exists()) return file;
      await prefs.remove(_pathKey(role));
    }

    return _migrateLegacyBase64Photo(role, prefs);
  }

  static Future<File> cacheRemotePhoto(String photoUrl, String role) async {
    final response = await http.get(Uri.parse(photoUrl));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Foto profil tidak dapat dimuat.');
    }

    final directory = await getTemporaryDirectory();
    final profileDirectory = Directory('${directory.path}/profile_photos');
    if (!await profileDirectory.exists()) {
      await profileDirectory.create(recursive: true);
    }

    final extension = _extensionFromPath(Uri.parse(photoUrl).path);
    final cachedFile = File(
      '${profileDirectory.path}/${role}_current_${DateTime.now().millisecondsSinceEpoch}$extension',
    );
    await cachedFile.writeAsBytes(response.bodyBytes, flush: true);

    return cachedFile;
  }

  static Future<File> savePhoto({
    required File source,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final oldPath = prefs.getString(_pathKey(role));
    await _deleteIfExists(oldPath);

    final directory = await getApplicationDocumentsDirectory();
    final profileDirectory = Directory('${directory.path}/profile_photos');
    if (!await profileDirectory.exists()) {
      await profileDirectory.create(recursive: true);
    }

    final extension = _extensionFromPath(source.path);
    final destination = File(
      '${profileDirectory.path}/${role}_${DateTime.now().millisecondsSinceEpoch}$extension',
    );
    final savedFile = await source.copy(destination.path);

    await prefs.setString(_pathKey(role), savedFile.path);
    await prefs.remove(_legacyDataKey(role));

    return savedFile;
  }

  static Future<File?> cropSquare({
    required BuildContext context,
    required File source,
  }) async {
    return Navigator.of(context).push<File>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ProfilePhotoCropScreen(source: source),
      ),
    );
  }

  static Future<File?> _migrateLegacyBase64Photo(
    String role,
    SharedPreferences prefs,
  ) async {
    final legacyData = prefs.getString(_legacyDataKey(role));
    if (legacyData == null || legacyData.isEmpty) return null;

    try {
      final bytes = base64Decode(legacyData);
      final directory = await getApplicationDocumentsDirectory();
      final profileDirectory = Directory('${directory.path}/profile_photos');
      if (!await profileDirectory.exists()) {
        await profileDirectory.create(recursive: true);
      }

      final migratedFile = File('${profileDirectory.path}/${role}_legacy.jpg');
      await migratedFile.writeAsBytes(bytes, flush: true);
      await prefs.setString(_pathKey(role), migratedFile.path);
      await prefs.remove(_legacyDataKey(role));

      return migratedFile;
    } catch (_) {
      await prefs.remove(_legacyDataKey(role));
      return null;
    }
  }

  static Future<void> _deleteIfExists(String? filePath) async {
    if (filePath == null || filePath.isEmpty) return;

    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static String _extensionFromPath(String filePath) {
    final dotIndex = filePath.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == filePath.length - 1) return '.jpg';

    return filePath.substring(dotIndex);
  }
}
