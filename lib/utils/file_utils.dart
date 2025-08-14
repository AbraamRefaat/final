import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;

class FileUtils {
  /// Check if a document exists at the given file path
  static Future<bool> checkDocument({required String filePath}) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Extract a ZIP file to the specified directory
  static Future<bool> extractZip({
    required String zipPath,
    String? destinationPath,
    Function? updateFilesList,
  }) async {
    try {
      final file = File(zipPath);
      if (!await file.exists()) {
        return false;
      }

      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Use the same directory as the ZIP file if no destination is specified
      final destPath = destinationPath ?? path.dirname(zipPath);
      
      for (final file in archive) {
        final filename = file.name;
        final filePath = path.join(destPath, filename);
        
        if (file.isFile) {
          final data = file.content as List<int>;
          await File(filePath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          await Directory(filePath).create(recursive: true);
        }
      }

      // Call the update callback if provided
      if (updateFilesList != null) {
        updateFilesList();
      }

      return true;
    } catch (e) {
      print('Error extracting ZIP: $e');
      return false;
    }
  }

  /// Get file size in a human-readable format
  static String getFileSize(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Get file extension
  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase();
  }

  /// Check if file is a ZIP file
  static bool isZipFile(String filePath) {
    final extension = getFileExtension(filePath);
    return extension == '.zip';
  }

  /// Delete a file or directory
  static Future<bool> deleteFileOrDirectory(String filePath, {bool recursive = true}) async {
    try {
      final fileSystemEntity = FileSystemEntity.typeSync(filePath);
      
      if (fileSystemEntity == FileSystemEntityType.file) {
        await File(filePath).delete();
      } else if (fileSystemEntity == FileSystemEntityType.directory) {
        await Directory(filePath).delete(recursive: recursive);
      }
      
      return true;
    } catch (e) {
      print('Error deleting file/directory: $e');
      return false;
    }
  }
}
