import 'dart:io';
import 'package:flutter/material.dart';

/// Style configuration for file management UI
class StyleMyFile {
  final Color? backgroundColor;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? textColor;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final double? heightHeader;
  final Color? textColorHeader;
  final String? myFileDialogAlertFolder;
  final String? myFileDialogAlertFile;
  final String? textActionCancel;
  final String? textActionDelete;
  final TextStyle? elevatedButtonTextStyleEnable;
  final TextStyle? elevatedButtonTextStyleDisable;

  const StyleMyFile({
    this.backgroundColor,
    this.primaryColor,
    this.secondaryColor,
    this.textColor,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.padding,
    this.borderRadius,
    this.heightHeader,
    this.textColorHeader,
    this.myFileDialogAlertFolder,
    this.myFileDialogAlertFile,
    this.textActionCancel,
    this.textActionDelete,
    this.elevatedButtonTextStyleEnable,
    this.elevatedButtonTextStyleDisable,
  });

  /// Default style configuration
  static StyleMyFile get defaultStyle => const StyleMyFile(
    backgroundColor: Colors.white,
    primaryColor: Colors.blue,
    secondaryColor: Colors.grey,
    textColor: Colors.black87,
    padding: EdgeInsets.all(16.0),
    heightHeader: 56.0,
    textColorHeader: Colors.black87,
    myFileDialogAlertFolder: "Are you sure you want to delete this folder?",
    myFileDialogAlertFile: "Are you sure you want to delete this file?",
    textActionCancel: "Cancel",
    textActionDelete: "Delete",
    elevatedButtonTextStyleEnable: TextStyle(color: Colors.white),
    elevatedButtonTextStyleDisable: TextStyle(color: Colors.grey),
  );

  /// Dark theme style configuration
  static StyleMyFile get darkStyle => const StyleMyFile(
    backgroundColor: Colors.grey,
    primaryColor: Colors.blueAccent,
    secondaryColor: Colors.grey,
    textColor: Colors.white,
    padding: EdgeInsets.all(16.0),
    heightHeader: 56.0,
    textColorHeader: Colors.white,
    myFileDialogAlertFolder: "Are you sure you want to delete this folder?",
    myFileDialogAlertFile: "Are you sure you want to delete this file?",
    textActionCancel: "Cancel",
    textActionDelete: "Delete",
    elevatedButtonTextStyleEnable: TextStyle(color: Colors.white),
    elevatedButtonTextStyleDisable: TextStyle(color: Colors.grey),
  );
}

/// Custom file system entity wrapper with additional metadata
class CustomFileSystemEntity {
  final FileSystemEntity entity;
  final String name;
  final String path;
  final DateTime lastModified;
  final int size;
  final bool isDirectory;
  final String extension;

  CustomFileSystemEntity({
    required this.entity,
    required this.name,
    required this.path,
    required this.lastModified,
    required this.size,
    required this.isDirectory,
    required this.extension,
  });

  /// Create from a FileSystemEntity
  static Future<CustomFileSystemEntity> fromEntity(FileSystemEntity entity) async {
    final stat = await entity.stat();
    final isDirectory = entity is Directory;
    final name = entity.path.split('/').last;
    final extension = isDirectory ? '' : name.split('.').last.toLowerCase();

    return CustomFileSystemEntity(
      entity: entity,
      name: name,
      path: entity.path,
      lastModified: stat.modified,
      size: stat.size,
      isDirectory: isDirectory,
      extension: extension,
    );
  }

  /// Get formatted file size
  String get formattedSize {
    if (isDirectory) return '';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get appropriate icon for file type
  IconData get icon {
    if (isDirectory) return Icons.folder;
    
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.archive;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'flac':
        return Icons.audio_file;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// Check if file is a media file
  bool get isMediaFile {
    const mediaExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'mp4', 'avi', 'mov', 'wmv', 'mp3', 'wav', 'aac', 'flac'];
    return mediaExtensions.contains(extension);
  }

  /// Check if file is a document
  bool get isDocument {
    const docExtensions = ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'];
    return docExtensions.contains(extension);
  }

  /// Check if file is an archive
  bool get isArchive {
    const archiveExtensions = ['zip', 'rar', '7z', 'tar', 'gz'];
    return archiveExtensions.contains(extension);
  }
}

/// File manager service to handle file operations and selections
class FileManagerService {
  static final FileManagerService _instance = FileManagerService._internal();
  factory FileManagerService() => _instance;
  FileManagerService._internal();

  final Set<String> _selectedFiles = <String>{};
  final Map<String, CustomFileSystemEntity> _entityMap = {};

  /// Check if any files are selected
  bool hasSelectedFiles() => _selectedFiles.isNotEmpty;

  /// Get selected files count
  int get selectedCount => _selectedFiles.length;

  /// Select a file
  void selectFile(String path) => _selectedFiles.add(path);

  /// Deselect a file
  void deselectFile(String path) => _selectedFiles.remove(path);

  /// Clear all selections
  void clearValues() => _selectedFiles.clear();

  /// Check if file is selected
  bool isSelected(String path) => _selectedFiles.contains(path);

  /// Get map of selected entities
  Map<String, CustomFileSystemEntity> get map => Map.fromEntries(
    _selectedFiles.map((path) => MapEntry(path, _entityMap[path]!))
      .where((entry) => _entityMap.containsKey(entry.key))
  );

  /// Add entity to map
  void addEntity(String path, CustomFileSystemEntity entity) {
    _entityMap[path] = entity;
  }

  /// Remove entity from map
  void removeEntity(String path) {
    _entityMap.remove(path);
    _selectedFiles.remove(path);
  }
}

/// File management initialization helper
class FileManagerInit {
  static StyleMyFile? _currentStyle;

  /// Initialize file manager with custom style
  static void init({StyleMyFile? style}) {
    _currentStyle = style ?? StyleMyFile.defaultStyle;
  }

  /// Get current style
  static StyleMyFile get currentStyle => _currentStyle ?? StyleMyFile.defaultStyle;

  /// Update style
  static void updateStyle(StyleMyFile style) {
    _currentStyle = style;
  }
}
