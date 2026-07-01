import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../config/app_config.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Pilih gambar sesuai platform
  static Future<File?> pickImage() async {
    try {
      // ==========================
      // Android / iOS
      // ==========================
      if (!kIsWeb &&
          (Platform.isAndroid || Platform.isIOS)) {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );

        if (image == null) return null;

        return File(image.path);
      }

      // ==========================
      // Windows / macOS / Linux
      // ==========================
      if (!kIsWeb &&
          (Platform.isWindows ||
              Platform.isLinux ||
              Platform.isMacOS)) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
        );

        if (result == null) return null;

        final path = result.files.single.path;

        if (path == null) return null;

        return File(path);
      }

      return null;
    } catch (e) {
      debugPrint("ImagePickerService Error: $e");
      return null;
    }
  }

  /// Ambil foto dari kamera (khusus Android/iOS)
  static Future<File?> pickFromCamera() async {
    try {
      if (!kIsWeb &&
          (Platform.isAndroid || Platform.isIOS)) {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );

        if (image == null) return null;

        return File(image.path);
      }

      return null;
    } catch (e) {
      debugPrint("Camera Error: $e");
      return null;
    }
  }

    /// Pilih banyak gambar sesuai platform
  static Future<List<File>> pickMultipleImages() async {
    try {
      // ==========================
      // Android / iOS
      // ==========================
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final List<XFile> images = await _picker.pickMultiImage(
          imageQuality: AppConfig.imageQuality,
        );

        return images.map((e) => File(e.path)).toList();
      }

      // ==========================
      // Windows / macOS / Linux
      // ==========================
      if (!kIsWeb &&
          (Platform.isWindows ||
              Platform.isLinux ||
              Platform.isMacOS)) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: true,
        );

        if (result == null) return [];

        return result.paths
            .whereType<String>()
            .map(File.new)
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint("Multiple Image Error: $e");
      return [];
    }
  }
}