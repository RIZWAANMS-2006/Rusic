// ignore_for_file: avoid_print

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages file system paths and permissions for media file access across platforms.
///
/// This class uses a user-consent model where the app only accesses folders
/// that the user has explicitly selected via the folder picker.
class Pathmanager {
  // ==================== STATIC CONSTANTS ====================

  /// Key for storing user-selected library folders in SharedPreferences.
  static const String _libraryFoldersKey = 'user_library_folders';

  /// Key for tracking if default folders have been initialized.
  static const String _defaultFoldersInitializedKey =
      'default_folders_initialized';

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

  /// Requests storage permissions on Android.
  /// Returns true if permissions are granted.
  Future<bool> _requestAndroidPermissions() async {
    if (!Platform.isAndroid) return true;

    final storageStatus = await Permission.storage.request();
    final manageStorageStatus = await Permission.manageExternalStorage
        .request();

    print('[PathManager] Storage permission: $storageStatus');
    print('[PathManager] Manage storage permission: $manageStorageStatus');

    return storageStatus.isGranted || manageStorageStatus.isGranted;
  }

  // ==================== USER LIBRARY FOLDER MANAGEMENT ====================

  /// Gets the standard user directories (Downloads, Music, Videos) based on platform.
  ///
  /// Returns a list of directory paths that exist.
  /// - Windows: C:\Users\[username]\Downloads, Music, Videos
  /// - Linux: /home/[username]/Downloads, Music, Videos
  /// - macOS: /Users/[username]/Downloads, Music, Movies
  /// - Android: Skipped (uses different storage model)
  Future<List<String>> getDefaultSystemDirectories() async {
    final List<String> defaultDirs = [];

    try {
      if (Platform.isAndroid) {
        // Skip for Android - uses different storage model
        print('[PathManager] Skipping default directories for Android');
        return defaultDirs;
      }

      // Get user home directory
      final String? home =
          Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];

      if (home == null) {
        print('[PathManager] Could not determine home directory');
        return defaultDirs;
      }

      print('[PathManager] Home directory: $home');

      // Standard directory names based on platform
      final List<String> dirNames = Platform.isMacOS
          ? [
              'Downloads',
              'Music',
              'Movies',
            ] // macOS uses "Movies" instead of "Videos"
          : ['Downloads', 'Music', 'Videos'];

      // Check each directory
      for (final dirName in dirNames) {
        final dirPath = Platform.isWindows
            ? '$home\\$dirName'
            : '$home/$dirName';

        final dir = Directory(dirPath);
        if (await dir.exists()) {
          defaultDirs.add(dirPath);
          print('[PathManager] Found default directory: $dirPath');
        } else {
          print('[PathManager] Directory does not exist: $dirPath');
        }
      }
    } catch (e) {
      print('[PathManager] Error getting default directories: $e');
    }

    return defaultDirs;
  }

  /// Initializes default library folders on first launch.
  ///
  /// Adds Downloads, Music, and Videos (or Movies on macOS) directories
  /// to the library if they exist and haven't been initialized before.
  ///
  /// Returns the number of directories that were added.
  Future<int> initializeDefaultLibraryFolders() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if already initialized
      final alreadyInitialized =
          prefs.getBool(_defaultFoldersInitializedKey) ?? false;

      if (alreadyInitialized) {
        print('[PathManager] Default folders already initialized');
        return 0;
      }

      print('[PathManager] Starting default folder initialization...');

      // Get default system directories
      final defaultDirs = await getDefaultSystemDirectories();

      print(
        '[PathManager] Found ${defaultDirs.length} default directories: $defaultDirs',
      );

      if (defaultDirs.isEmpty) {
        print('[PathManager] No default directories found');
        // Mark as initialized even if no directories found
        await prefs.setBool(_defaultFoldersInitializedKey, true);
        return 0;
      }

      // Add each directory to library
      int addedCount = 0;
      for (final dirPath in defaultDirs) {
        print('[PathManager] Attempting to add: $dirPath');
        final success = await addLibraryFolderPath(dirPath);
        if (success) {
          addedCount++;
          print('[PathManager] Successfully added: $dirPath');
        } else {
          print('[PathManager] Failed to add: $dirPath');
        }
      }

      // Mark as initialized
      await prefs.setBool(_defaultFoldersInitializedKey, true);
      print('[PathManager] Initialized $addedCount default directories');

      return addedCount;
    } catch (e) {
      print('[PathManager] Error initializing default folders: $e');
      return 0;
    }
  }

  /// Force initializes default folders even if already initialized.
  ///
  /// Useful when user has no folders and wants to reset to defaults.
  Future<int> forceInitializeDefaultFolders() async {
    try {
      print('[PathManager] Force initializing default folders...');

      // Get default system directories
      final defaultDirs = await getDefaultSystemDirectories();

      print(
        '[PathManager] Found ${defaultDirs.length} default directories: $defaultDirs',
      );

      if (defaultDirs.isEmpty) {
        print('[PathManager] No default directories found to add');
        return 0;
      }

      // Add each directory to library
      int addedCount = 0;
      for (final dirPath in defaultDirs) {
        print('[PathManager] Force adding: $dirPath');
        final success = await addLibraryFolderPath(dirPath);
        if (success) {
          addedCount++;
          print('[PathManager] Successfully added: $dirPath');
        } else {
          print('[PathManager] Already exists or failed: $dirPath');
        }
      }

      // Mark as initialized
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_defaultFoldersInitializedKey, true);
      print('[PathManager] Force initialized $addedCount new directories');

      return addedCount;
    } catch (e) {
      print('[PathManager] Error force initializing default folders: $e');
      return 0;
    }
  }

  /// Checks if default folders have been initialized.
  Future<bool> areDefaultFoldersInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    final initialized = prefs.getBool(_defaultFoldersInitializedKey) ?? false;
    print('[PathManager] areDefaultFoldersInitialized: $initialized');
    return initialized;
  }

  /// Resets the default folder initialization flag.
  ///
  /// After calling this, the next call to initializeDefaultLibraryFolders()
  /// will add default folders again. Useful for troubleshooting.
  Future<void> resetDefaultFoldersInitialization() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_defaultFoldersInitializedKey);
    print('[PathManager] Reset default folders initialization flag');
  }

  /// Gets all user-selected library folders from persistent storage.
  ///
  /// Returns an empty list if no folders have been selected yet.
  Future<List<String>> getSavedLibraryFolders() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_libraryFoldersKey) ?? [];
  }

  /// Opens a folder picker dialog and adds the selected folder to the library.
  ///
  /// Returns `true` if a new folder was successfully added.
  /// Returns `false` if:
  /// - User canceled the picker
  /// - Selected folder is already in the library (duplicate)
  /// - An error occurred
  Future<bool> addLibraryFolder() async {
    try {
      // Open folder picker dialog
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        final prefs = await SharedPreferences.getInstance();

        // Get current folder list
        List<String> currentFolders =
            prefs.getStringList(_libraryFoldersKey) ?? [];

        // Avoid duplicates
        if (!currentFolders.contains(selectedDirectory)) {
          currentFolders.add(selectedDirectory);
          await prefs.setStringList(_libraryFoldersKey, currentFolders);
          print('[PathManager] Added library folder: $selectedDirectory');
          return true;
        } else {
          print('[PathManager] Folder already exists: $selectedDirectory');
        }
      } else {
        print('[PathManager] Folder picker canceled');
      }
    } catch (e) {
      print('[PathManager] Error adding folder: $e');
    }
    return false;
  }

  /// Adds a specific folder path to the library without opening a picker.
  ///
  /// Useful for programmatically adding folders.
  /// Returns `true` if successfully added, `false` if duplicate or error.
  Future<bool> addLibraryFolderPath(String folderPath) async {
    try {
      final dir = Directory(folderPath);
      if (!await dir.exists()) {
        print('[PathManager] Folder does not exist: $folderPath');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      List<String> currentFolders =
          prefs.getStringList(_libraryFoldersKey) ?? [];

      if (!currentFolders.contains(folderPath)) {
        currentFolders.add(folderPath);
        await prefs.setStringList(_libraryFoldersKey, currentFolders);
        print('[PathManager] Added library folder: $folderPath');
        return true;
      }
    } catch (e) {
      print('[PathManager] Error adding folder path: $e');
    }
    return false;
  }

  /// Removes a folder from the user's library.
  ///
  /// The folder itself is not deleted, only removed from the app's scan list.
  Future<void> removeLibraryFolder(String folderPath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> currentFolders =
          prefs.getStringList(_libraryFoldersKey) ?? [];

      currentFolders.remove(folderPath);
      await prefs.setStringList(_libraryFoldersKey, currentFolders);
      print('[PathManager] Removed library folder: $folderPath');
    } catch (e) {
      print('[PathManager] Error removing folder: $e');
    }
  }

  /// Clears all user-selected library folders.
  Future<void> clearAllLibraryFolders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_libraryFoldersKey);
      print('[PathManager] Cleared all library folders');
    } catch (e) {
      print('[PathManager] Error clearing folders: $e');
    }
  }

  /// Checks if the user has any library folders selected.
  Future<bool> hasLibraryFolders() async {
    final folders = await getSavedLibraryFolders();
    return folders.isNotEmpty;
  }

  /// Gets library folders with their extracted names for display purposes.
  ///
  /// Returns a list of maps containing:
  /// - 'path': full folder path
  /// - 'name': extracted folder name for display
  Future<List<Map<String, String>>> getLibraryFoldersWithNames() async {
    final folders = await getSavedLibraryFolders();
    return folders.map((path) {
      return {'path': path, 'name': _extractDirectoryName(path)};
    }).toList();
  }

  // ==================== LIBRARY SCANNING METHODS ====================

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

  /// Scans ONLY the user-selected library folders for media files.
  ///
  /// This is the recommended method for scanning media files as it respects
  /// user preferences and only accesses folders the user has explicitly allowed.
  ///
  /// Returns a Map where:
  /// - Keys: directory names (e.g., "Music", "Downloads")
  /// - Values: list of media files found in that directory
  ///
  /// Returns an empty map if no library folders have been selected.
  Future<Map<String, List<File>>> fetchMediaFilesFromLibrary() async {
    // Request permissions on Android before scanning
    await _requestAndroidPermissions();

    final libraryFolders = await getSavedLibraryFolders();
    final mediaFilesByLocation = <String, List<File>>{};

    if (libraryFolders.isEmpty) {
      print('[PathManager] No library folders selected');
      return mediaFilesByLocation;
    }

    print(
      '[PathManager] Scanning ${libraryFolders.length} user library folders...',
    );

    for (final folderPath in libraryFolders) {
      final dir = Directory(folderPath);

      if (await _isDirectoryAccessible(dir)) {
        final filesInDirectory = await scanMediaFiles(folderPath);
        final dirName = _extractDirectoryName(folderPath);
        // Always include saved folders, even if they have no media files yet
        mediaFilesByLocation[dirName] = filesInDirectory;
        print('[PathManager] $dirName: ${filesInDirectory.length} files');
      } else {
        print('[PathManager] Folder no longer accessible: $folderPath');
      }
    }

    final totalFiles = mediaFilesByLocation.values.fold<int>(
      0,
      (sum, files) => sum + files.length,
    );
    print(
      '[PathManager] Library total: $totalFiles files across ${mediaFilesByLocation.length} locations',
    );

    return mediaFilesByLocation;
  }

  /// Scans library folders and returns a flat list of all media files.
  ///
  /// Unlike [fetchMediaFilesFromLibrary], this returns all files in a single list
  /// without grouping by directory. Useful when you just need all songs.
  Future<List<File>> fetchAllMediaFilesFromLibrary() async {
    // Request permissions on Android before scanning
    await _requestAndroidPermissions();

    final libraryFolders = await getSavedLibraryFolders();
    final allMediaFiles = <File>[];

    if (libraryFolders.isEmpty) {
      print('[PathManager] No library folders selected');
      return allMediaFiles;
    }

    for (final folderPath in libraryFolders) {
      final dir = Directory(folderPath);

      if (await dir.exists()) {
        try {
          final files = dir.listSync(recursive: true);

          for (final file in files) {
            if (file is File && _isMediaFile(file.path)) {
              allMediaFiles.add(file);
            }
          }
        } catch (e) {
          print('[PathManager] Error scanning $folderPath: $e');
        }
      }
    }

    print('[PathManager] Found ${allMediaFiles.length} media files in library');
    return allMediaFiles;
  }

  /// Scans library folders and returns only audio files.
  Future<List<File>> fetchAudioFilesFromLibrary() async {
    // Request permissions on Android before scanning
    await _requestAndroidPermissions();

    final libraryFolders = await getSavedLibraryFolders();
    final audioFiles = <File>[];

    if (libraryFolders.isEmpty) {
      return audioFiles;
    }

    for (final folderPath in libraryFolders) {
      final dir = Directory(folderPath);

      if (await dir.exists()) {
        try {
          final files = dir.listSync(recursive: true);

          for (final file in files) {
            if (file is File) {
              final lowercasePath = file.path.toLowerCase();
              if (_audioExtensions.any((ext) => lowercasePath.endsWith(ext))) {
                audioFiles.add(file);
              }
            }
          }
        } catch (e) {
          print('[PathManager] Error scanning $folderPath: $e');
        }
      }
    }

    print('[PathManager] Found ${audioFiles.length} audio files in library');
    return audioFiles;
  }

  /// Scans library folders and returns only video files.
  Future<List<File>> fetchVideoFilesFromLibrary() async {
    // Request permissions on Android before scanning
    await _requestAndroidPermissions();

    final libraryFolders = await getSavedLibraryFolders();
    final videoFiles = <File>[];

    if (libraryFolders.isEmpty) {
      return videoFiles;
    }

    for (final folderPath in libraryFolders) {
      final dir = Directory(folderPath);

      if (await dir.exists()) {
        try {
          final files = dir.listSync(recursive: true);

          for (final file in files) {
            if (file is File) {
              final lowercasePath = file.path.toLowerCase();
              if (_videoExtensions.any((ext) => lowercasePath.endsWith(ext))) {
                videoFiles.add(file);
              }
            }
          }
        } catch (e) {
          print('[PathManager] Error scanning $folderPath: $e');
        }
      }
    }

    print('[PathManager] Found ${videoFiles.length} video files in library');
    return videoFiles;
  }
}
