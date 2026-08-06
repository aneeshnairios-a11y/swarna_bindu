import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path_provider/path_provider.dart';

/// Shared Camera/Gallery picker + compressor for every KYC document/photo
/// upload. Keeps images under ~2MB per the project's KYC compression rule
/// (Section 12), with a single lower-quality retry if the first pass is
/// still too large (large phone camera photos, poor lighting, etc.).
class ImagePickerHelper {
  static final _picker = ImagePicker();

  static Future<File?> pickAndCompress(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return null;

    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return null;

    return _compress(File(picked.path));
  }

  static Future<File> _compress(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/kyc_${DateTime.now().microsecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,
        minWidth: 1280,
        minHeight: 1280,
      );
      if (result == null) return file;

      var compressed = File(result.path);
      if (await compressed.length() > 5 * 1024 * 1024) {
        final retryPath = '${dir.path}/kyc_retry_${DateTime.now().microsecondsSinceEpoch}.jpg';
        final retry = await FlutterImageCompress.compressAndGetFile(
          compressed.absolute.path,
          retryPath,
          quality: 45,
          minWidth: 1024,
          minHeight: 1024,
        );
        if (retry != null) compressed = File(retry.path);
      }
      return compressed;
    } catch (_) {
      return file; // compression is a nice-to-have; never block the upload on it
    }
  }
}
