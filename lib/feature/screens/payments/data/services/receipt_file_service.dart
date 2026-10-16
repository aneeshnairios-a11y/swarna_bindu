import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

/// Result of saving a receipt to the device.
class SavedReceiptFile {
  const SavedReceiptFile({required this.localPath, required this.inPublicDownloads});

  /// A readable local copy (used for "Open" / "Share").
  final String localPath;

  /// true  → the PDF is in the user's public Downloads folder (Android).
  /// false → saved inside the app's documents (iOS has no public Downloads).
  final bool inPublicDownloads;
}

/// Device-side file handling for receipts: save to Downloads + share sheet.
/// Kept out of the repository because it has nothing to do with the API.
class ReceiptFileService {
  static const String _downloadsSubfolder = 'Swarna Bindu';

  /// Android: copies the PDF into `Downloads/Swarna Bindu/` via MediaStore
  /// (no storage permission needed on Android 10+; on Android 9 and below the
  /// legacy WRITE_EXTERNAL_STORAGE permission is requested first).
  /// iOS: copies into the app documents directory.
  Future<SavedReceiptFile> saveToDownloads(String sourcePath) async {
    if (Platform.isAndroid) {
      final store = MediaStore();
      await MediaStore.ensureInitialized();
      MediaStore.appFolder = _downloadsSubfolder;

      final sdk = await store.getPlatformSDKInt();
      if (sdk <= 29) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw const FileSystemException('Storage permission denied');
        }
      }

      final saved = await store.saveFile(
        tempFilePath: sourcePath,
        dirType: DirType.download,
        dirName: DirName.download,
      );
      if (saved == null) {
        throw const FileSystemException('Could not write to Downloads');
      }
      return SavedReceiptFile(localPath: sourcePath, inPublicDownloads: true);
    }

    final docs = await getApplicationDocumentsDirectory();
    final name = sourcePath.split(Platform.pathSeparator).last;
    final copy = await File(sourcePath).copy('${docs.path}/$name');
    return SavedReceiptFile(localPath: copy.path, inPublicDownloads: false);
  }

  /// Opens the OS share sheet with the PDF attached.
  Future<void> share(String path, {String? subject, String? text}) async {
    await Share.shareXFiles(
      [XFile(path, mimeType: 'application/pdf')],
      subject: subject,
      text: text,
    );
  }
}

final receiptFileServiceProvider = Provider<ReceiptFileService>((ref) => ReceiptFileService());