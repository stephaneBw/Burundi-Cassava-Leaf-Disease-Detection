// Handles image picking, capture, and persistent scan-image storage.

import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();
  String? _documentsDirectoryPath;

  Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    _documentsDirectoryPath = directory.path;
  }

  Future<File?> pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source);
    if (picked == null) return null;
    return File(picked.path);
  }

  Future<String> saveToPermanentStorage(File tempImage) async {
    await _ensureInitialized();
    // Persist scans under generated names so separate captures never overwrite each other.
    final extension = path.extension(tempImage.path);
    final fileName = '${const Uuid().v4()}$extension';
    final savedImage = await tempImage.copy(path.join(_documentsDirectoryPath!, fileName));
    return path.basename(savedImage.path);
  }

  File getFileFromStorage(String fileNameOrPath) {
    final documentsDirectoryPath = _requireInitialized();
    if (path.isAbsolute(fileNameOrPath)) {
      final fileName = path.basename(fileNameOrPath);
      return File(path.join(documentsDirectoryPath, fileName));
    }
    return File(path.join(documentsDirectoryPath, fileNameOrPath));
  }

  Future<void> _ensureInitialized() async {
    if (_documentsDirectoryPath == null) {
      await initialize();
    }
  }

  String _requireInitialized() {
    final documentsDirectoryPath = _documentsDirectoryPath;
    if (documentsDirectoryPath == null) {
      throw StateError('MediaService must be initialized before reading stored files.');
    }
    return documentsDirectoryPath;
  }
}
