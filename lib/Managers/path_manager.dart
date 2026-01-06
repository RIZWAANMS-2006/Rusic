// ignore_for_file: avoid_print

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Manages file system paths and permissions for media file access across platforms.
class Pathmanager {
  // ==================== STATIC CONSTANTS ====================

  /// Supported audio file extensions.
  static const List<String> _audioExtensions = [
    '.mp3',
    '.wav',
    '.aac',
    '.flac',
    '.ogg',
    '.m4a',
    '.wma',
  ];

  /// Supported video file extensions.
  static const List<String> _videoExtensions = [
    '.mp4',
    '.avi',
    '.mov',
    '.wmv',
    '.flv',
    '.mkv',
    '.webm',
    '.3gp',
  ];

  // ==================== PRIVATE HELPER METHODS ====================

  /// Checks if a directory exists and is accessible.
  Future<bool> _isDirectoryAccessible(Directory directory) async {
    try {
      final exists = await directory.exists();
      print('[PathManager] Directory check ${directory.path}: $exists');
      return exists;
    } catch (e) {
      print('[PathManager] Error accessing ${directory.path}: $e');
      return false;
    }
  }

  /// Ensures a directory exists, creating it recursively if needed.
  Future<void> _ensureDirectoryExists(Directory directory) async {
    try {
      if (!await directory.exists()) {
        print('[PathManager] Creating directory: ${directory.path}');
        await directory.create(recursive: true);
      }
    } catch (e) {
      print('[PathManager] Failed to create directory ${directory.path}: $e');
      rethrow;
    }
  }

  /// Checks if a file path has a supported media extension.
  bool _isMediaFile(String filePath) {
    final lowercasePath = filePath.toLowerCase();
    final allExtensions = [..._audioExtensions, ..._videoExtensions];
    return allExtensions.any((ext) => lowercasePath.endsWith(ext));
  }

  /// Extracts a readable directory name from a full path.
  ///
  /// Examples:
  /// - /storage/emulated/0/Music → Music
  /// - C:\Users\Name\Downloads → Downloads
  /// - /home/user/Videos → Videos
  String _extractDirectoryName(String fullPath) {
    // Remove trailing slashes
    final cleanPath = fullPath.replaceAll(RegExp(r'[/\\]+$'), '');

    // Get last component
    final parts = cleanPath.split(RegExp(r'[/\\]'));
    final lastName = parts.isNotEmpty ? parts.last : 'Unknown';

    return lastName;
  }

  // ==================== PRIVATE PLATFORM-SPECIFIC METHODS ====================

  /// Returns standard directory names for Android platform.
  List<String> _getAndroidDirectoryNames() {
    return [
      'Download',
      'Music',
      'Movies',
      'DCIM',
      'Pictures',
      'Podcasts',
      'Audiobooks',
      'Recordings',
      'Notifications',
      'Ringtones',
      'Alarms',
    ];
  }

  /// Returns standard directory names for Windows platform.
  List<String> _getWindowsDirectoryNames() {
    return [
      'Downloads',
      'Music',
      'Videos',
      'Pictures',
      'Documents\\Music',
      'OneDrive\\Music',
      'OneDrive\\Documents',
      'Public\\Music',
      'Public\\Videos',
    ];
  }

  /// Returns standard directory names for Linux platform.
  List<String> _getLinuxDirectoryNames() {
    return [
      'Downloads',
      'Music',
      'Videos',
      'Documents',
      'Public',
      'Downloads/MyMusic',
    ];
  }

  /// Returns all accessible media directories on Android.
  Future<List<String>> _getAllAndroidMediaDirectories() async {
    // Request necessary permissions
    final storageStatus = await Permission.storage.request();
    final manageStorageStatus = await Permission.manageExternalStorage
        .request();

    print('[PathManager] Storage permission: $storageStatus');
    print('[PathManager] Manage storage permission: $manageStorageStatus');

    final accessiblePaths = <String>[];

    // Common Android media directories
    final commonPaths = [
      '/storage/emulated/0/Download',
      '/storage/emulated/0/Music',
      '/storage/emulated/0/Movies',
      '/storage/emulated/0/DCIM',
      '/storage/emulated/0/Pictures',
      '/storage/emulated/0/Podcasts',
      '/storage/emulated/0/Audiobooks',
      '/storage/emulated/0/Recordings',
      '/storage/emulated/0/Notifications',
      '/storage/emulated/0/Ringtones',
      '/storage/emulated/0/Alarms',
    ];

    for (final path in commonPaths) {
      final dir = Directory(path);
      if (await _isDirectoryAccessible(dir)) {
        accessiblePaths.add(path);
      }
    }

    // Add app-specific fallback if no public directories are accessible
    if (accessiblePaths.isEmpty) {
      try {
        final appDocsDir = await getApplicationDocumentsDirectory();
        accessiblePaths.add(appDocsDir.path);
        print('[PathManager] Using app documents fallback: ${appDocsDir.path}');
      } catch (e) {
        print('[PathManager] App documents unavailable: $e');
      }
    }

    print(
      '[PathManager] Accessible Android directories: ${accessiblePaths.length}',
    );
    return accessiblePaths;
  }

  /// Resolves media directory for Android with permission handling and fallbacks.
  Future<String> _resolveAndroidMediaPath() async {
    // Request necessary permissions
    final storageStatus = await Permission.storage.request();
    final manageStorageStatus = await Permission.manageExternalStorage
        .request();

    print('[PathManager] Storage permission: $storageStatus');
    print('[PathManager] Manage storage permission: $manageStorageStatus');

    // Primary: shared Download directory
    final primaryPath = Directory('/storage/emulated/0/Download');
    if (await _isDirectoryAccessible(primaryPath)) {
      print('[PathManager] Using shared Download: ${primaryPath.path}');
      return primaryPath.path;
    }

    // Fallback 1: app documents directory
    try {
      final appDocsDir = await getApplicationDocumentsDirectory();
      print('[PathManager] Using app documents: ${appDocsDir.path}');
      return appDocsDir.path;
    } catch (e) {
      print('[PathManager] App documents unavailable: $e');
    }

    // Fallback 2: external storage root
    final storageRoot = Directory('/storage/emulated/0');
    if (await _isDirectoryAccessible(storageRoot)) {
      print('[PathManager] Using storage root: ${storageRoot.path}');
      return storageRoot.path;
    }

    throw Exception('Unable to access any media directory on Android');
  }

  /// Returns all accessible media directories on Windows.
  Future<List<String>> _getAllWindowsMediaDirectories() async {
    final accessiblePaths = <String>[];

    // Try standard Windows media directories
    try {
      final userProfile = Platform.environment['USERPROFILE'];
      final publicProfile = Platform.environment['PUBLIC'];

      if (userProfile != null) {
        final mediaDirs = [
          '$userProfile\\Downloads',
          '$userProfile\\Music',
          '$userProfile\\Videos',
          '$userProfile\\Pictures',
          '$userProfile\\Documents\\Music',
          '$userProfile\\OneDrive\\Music',
          '$userProfile\\OneDrive\\Documents',
        ];

        for (final path in mediaDirs) {
          final dir = Directory(path);
          if (await _isDirectoryAccessible(dir)) {
            accessiblePaths.add(path);
          }
        }
      }

      // Add public/shared directories
      if (publicProfile != null) {
        final publicDirs = ['$publicProfile\\Music', '$publicProfile\\Videos'];

        for (final path in publicDirs) {
          final dir = Directory(path);
          if (await _isDirectoryAccessible(dir)) {
            accessiblePaths.add(path);
          }
        }
      }
    } catch (e) {
      print('[PathManager] Error accessing Windows user directories: $e');
    }

    // Fallback to path_provider if no directories found
    if (accessiblePaths.isEmpty) {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null && await _isDirectoryAccessible(downloadsDir)) {
        accessiblePaths.add(downloadsDir.path);
      }
    }

    print(
      '[PathManager] Accessible Windows directories: ${accessiblePaths.length}',
    );
    return accessiblePaths;
  }

  /// Resolves media directory for Windows platform.
  Future<String> _resolveWindowsMediaPath() async {
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      await _ensureDirectoryExists(downloadsDir);
      return downloadsDir.path;
    }

    final documentsDir = await getApplicationDocumentsDirectory();
    return documentsDir.path;
  }

  /// Returns all accessible media directories on Linux.
  Future<List<String>> _getAllLinuxMediaDirectories() async {
    final accessiblePaths = <String>[];
    final homeDir = Platform.environment['HOME'];

    if (homeDir != null) {
      final mediaDirs = [
        '$homeDir/Downloads',
        '$homeDir/Music',
        '$homeDir/Videos',
        '$homeDir/Documents',
        '$homeDir/Public',
        '$homeDir/Downloads/MyMusic',
      ];

      for (final path in mediaDirs) {
        final dir = Directory(path);
        if (await _isDirectoryAccessible(dir)) {
          accessiblePaths.add(path);
        }
      }

      // Check mounted drives
      final mediaUserPath = '/media/$homeDir'.replaceAll('/home/', '');
      final mountedDirs = ['/media/$mediaUserPath', '/mnt'];

      for (final path in mountedDirs) {
        final dir = Directory(path);
        if (await _isDirectoryAccessible(dir)) {
          // Add subdirectories of mounted locations
          try {
            final subDirs = dir
                .listSync()
                .whereType<Directory>()
                .map((d) => d.path)
                .toList();
            accessiblePaths.addAll(subDirs);
          } catch (e) {
            print('[PathManager] Error listing mounted drives: $e');
          }
        }
      }
    }

    print(
      '[PathManager] Accessible Linux directories: ${accessiblePaths.length}',
    );
    return accessiblePaths;
  }

  /// Resolves media directory for Linux platform.
  Future<String> _resolveLinuxMediaPath() async {
    final homeDir = Platform.environment['HOME'];
    final separator = Platform.pathSeparator;
    final mediaPath = '$homeDir${separator}Downloads${separator}MyMusic';

    final targetDir = Directory(mediaPath);
    await _ensureDirectoryExists(targetDir);
    return targetDir.path;
  }

  // ==================== PUBLIC UTILITY METHODS ====================

  /// Returns the list of standard media directory names for the current platform.
  ///
  /// Returns directory names only (not full paths) that the platform typically uses
  /// for storing media files.
  ///
  /// Example outputs:
  /// - Android: ["Download", "Music", "Movies", "DCIM", etc.]
  /// - Windows: ["Downloads", "Music", "Videos", "Pictures", etc.]
  /// - Linux: ["Downloads", "Music", "Videos", "Documents", etc.]
  List<String> getPlatformMediaDirectoryNames() {
    if (Platform.isAndroid) {
      return _getAndroidDirectoryNames();
    } else if (Platform.isWindows) {
      return _getWindowsDirectoryNames();
    } else if (Platform.isLinux) {
      return _getLinuxDirectoryNames();
    }

    // Default fallback
    return ['Documents'];
  }

  /// Resolves and returns the primary media directory path.
  ///
  /// On Android: requests storage permissions, then attempts /storage/emulated/0/Download
  /// with fallbacks to app-specific directories.
  /// On Windows: uses system Downloads directory.
  /// On Linux: uses ~/Downloads/MyMusic.
  ///
  /// Throws [Exception] if no accessible directory can be found on Android.
  Future<String> resolveMediaDirectory() async {
    if (Platform.isAndroid) {
      return await _resolveAndroidMediaPath();
    } else if (Platform.isWindows) {
      return await _resolveWindowsMediaPath();
    } else if (Platform.isLinux) {
      return await _resolveLinuxMediaPath();
    }

    // Default fallback for other platforms
    final documentsDir = await getApplicationDocumentsDirectory();
    return documentsDir.path;
  }

  /// Returns all possible media directory paths for the current platform.
  ///
  /// On Android: Downloads, Music, Movies, DCIM, Pictures
  /// On Windows: Downloads, Music, Videos
  /// On Linux: Downloads, Music, Videos
  ///
  /// Returns only directories that exist and are accessible.
  Future<List<String>> getAllMediaDirectories() async {
    if (Platform.isAndroid) {
      return await _getAllAndroidMediaDirectories();
    } else if (Platform.isWindows) {
      return await _getAllWindowsMediaDirectories();
    } else if (Platform.isLinux) {
      return await _getAllLinuxMediaDirectories();
    }

    // Default fallback for other platforms
    final documentsDir = await getApplicationDocumentsDirectory();
    return [documentsDir.path];
  }

  /// Scans the specified directory and returns all media files (audio + video).
  ///
  /// Performs recursive scanning and filters by supported extensions.
  /// Returns empty list if directory is inaccessible or contains no media.
  Future<List<File>> scanMediaFiles(String directoryPath) async {
    try {
      final targetDir = Directory(directoryPath);
      print('[PathManager] Scanning: $directoryPath');

      if (!await targetDir.exists()) {
        print('[PathManager] Directory does not exist: $directoryPath');
        return [];
      }

      final allEntries = targetDir.listSync(recursive: true);
      print('[PathManager] Total entries found: ${allEntries.length}');

      final mediaFiles = allEntries
          .whereType<File>()
          .where((file) => _isMediaFile(file.path))
          .toList();

      print('[PathManager] Media files found: ${mediaFiles.length}');
      return mediaFiles;
    } catch (e) {
      print('[PathManager] Error scanning directory: $e');
      rethrow;
    }
  }

  // ==================== IMPORTANT PUBLIC METHODS ====================

  /// Resolves the primary media directory and scans for media files.
  ///
  /// This is a convenience method for scanning only the primary directory.
  /// Use [fetchAllMediaFiles] to scan all possible media directories.
  ///
  /// Returns a Map with a single entry where the key is the directory name
  /// and the value is the list of media files found.
  Future<Map<String, List<File>>> fetchPrimaryDirectoryMediaFiles() async {
    final mediaDirectoryPath = await resolveMediaDirectory();
    final mediaFiles = await scanMediaFiles(mediaDirectoryPath);
    final dirName = _extractDirectoryName(mediaDirectoryPath);

    return {dirName: mediaFiles};
  }

  /// Scans all accessible media directories and returns media files grouped by location.
  ///
  /// This method finds all platform-appropriate media directories
  /// (Downloads, Music, Movies/Videos, DCIM, etc.) and scans each one
  /// for audio and video files.
  ///
  /// Returns a Map where:
  /// - Keys: directory names (e.g., "Music", "Downloads", "Movies")
  /// - Values: list of media files found in that directory
  ///
  /// This is the primary method for comprehensive media file discovery.
  Future<Map<String, List<File>>> fetchAllMediaFiles() async {
    final allDirectories = await getAllMediaDirectories();
    final mediaFilesByLocation = <String, List<File>>{};

    print('[PathManager] Scanning ${allDirectories.length} directories...');

    for (final directoryPath in allDirectories) {
      final filesInDirectory = await scanMediaFiles(directoryPath);

      if (filesInDirectory.isNotEmpty) {
        // Extract directory name from full path
        final dirName = _extractDirectoryName(directoryPath);
        mediaFilesByLocation[dirName] = filesInDirectory;
        print('[PathManager] $dirName: ${filesInDirectory.length} files');
      }
    }

    final totalFiles = mediaFilesByLocation.values.fold<int>(
      0,
      (sum, files) => sum + files.length,
    );
    print(
      '[PathManager] Total: $totalFiles files across ${mediaFilesByLocation.length} locations',
    );

    return mediaFilesByLocation;
  }
}
