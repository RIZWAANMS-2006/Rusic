import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Rusic/managers/path_manager.dart';
import 'package:Rusic/ui/media_ui.dart';
import 'dart:io';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Future<Map<String, List<File>>>? mediaFilesFuture;
  final Pathmanager _pathManager = Pathmanager();

  // State for viewing files in a specific location
  String? _selectedLocationName;
  List<File>? _selectedLocationFiles;
  int _hoverIndex = -1;
  final ScrollController _filesScrollController = ScrollController();
  Map<String, int> _letterToIndex = {};
  List<File> _sortedLocationFiles = [];

  @override
  void initState() {
    super.initState();
    _initializeAndRefresh();
  }

  /// Navigate to view files in a specific location
  void _viewLocationFiles(
    String locationName,
    String folderPath,
    List<File> files,
  ) {
    setState(() {
      _selectedLocationName = locationName;
      _selectedLocationFiles = files;
    });
  }

  @override
  void dispose() {
    _filesScrollController.dispose();
    super.dispose();
  }

  /// Go back to locations list view
  void _backToLocationsList() {
    setState(() {
      _selectedLocationName = null;
      _selectedLocationFiles = null;
      _sortedLocationFiles = [];
      _letterToIndex = {};
      _hoverIndex = -1;
    });
  }

  /// Check if currently viewing a specific location's files
  bool get _isViewingLocationFiles =>
      _selectedLocationName != null && _selectedLocationFiles != null;

  /// Initialize default folders and refresh media files
  Future<void> _initializeAndRefresh() async {
    // Initialize default folders on first launch
    final addedCount = await _pathManager.initializeDefaultLibraryFolders();
    print('[LocationScreen] Added $addedCount default directories');

    // Check if we actually have any folders
    final hasFolders = await _pathManager.hasLibraryFolders();
    final folderCount = (await _pathManager.getSavedLibraryFolders()).length;
    print(
      '[LocationScreen] Has folders: $hasFolders, Actual count: $folderCount',
    );

    // If initialization returned 0 AND there are no folders, reset flag and force initialize
    if (addedCount == 0 && !hasFolders) {
      print(
        '[LocationScreen] No folders despite initialization, resetting flag and forcing...',
      );
      await _pathManager.resetDefaultFoldersInitialization();
      final forcedCount = await _pathManager.forceInitializeDefaultFolders();
      print('[LocationScreen] Force added $forcedCount directories');
    }

    // Refresh media files after initialization
    _refreshMediaFiles();
  }

  void _refreshMediaFiles() {
    setState(() {
      mediaFilesFuture = _pathManager.fetchMediaFilesFromLibrary();
    });
  }

  Future<void> _addFolder() async {
    final added = await _pathManager.addLibraryFolder();
    if (added) {
      _refreshMediaFiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Folder added successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _removeFolder(String folderPath) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromRGBO(34, 34, 34, 1),
        title: Text('Remove Folder?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Remove this location from your library?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _pathManager.removeLibraryFolder(folderPath);
      _refreshMediaFiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Folder removed'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(26, 26, 26, 1),
      floatingActionButton: _isViewingLocationFiles
          ? null
          : FloatingActionButton(
              onPressed: _addFolder,
              tooltip: 'Add Folder',
              child: Icon(Icons.add),
            ),
      body: _isViewingLocationFiles
          ? _buildLocationFilesView()
          : mediaFilesFuture == null
          ? _buildLoadingState()
          : FutureBuilder<Map<String, List<File>>>(
              future: mediaFilesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                } else if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }
                final data = snapshot.data;
                if (data == null || data.isEmpty) {
                  return _buildEmptyState();
                } else {
                  return _buildLocationsList(data);
                }
              },
            ),
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        _buildNavigationBar(),
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return CustomScrollView(
      slivers: [
        _buildNavigationBar(),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error loading locations',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return CustomScrollView(
      slivers: [
        _buildNavigationBar(),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No Locations Added',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add folders to your library to see media files',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _addFolder,
                  icon: const Icon(Icons.add_rounded),
                  label: Text('Add Folder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return SliverAppBar(
      title: Text(
        _isViewingLocationFiles
            ? (_selectedLocationName ?? 'Location')
            : 'Locations',
        style: TextStyle(fontFamily: "Normal", fontWeight: FontWeight.w500),
      ),
      backgroundColor: Colors.transparent,
      floating: false,
      pinned: true,
      leading: _isViewingLocationFiles
          ? IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: _backToLocationsList,
            )
          : null,
    );
  }

  Widget _buildLocationsList(Map<String, List<File>> mediaByLocation) {
    return Stack(
      children: [
        FutureBuilder<List<String>>(
          future: _pathManager.getSavedLibraryFolders(),
          builder: (context, folderSnapshot) {
            // Build a map from folder name -> full path for lookup
            final folderNameToPath = <String, String>{};
            final folders = folderSnapshot.data ?? [];
            for (final path in folders) {
              final name = path
                  .replaceAll(RegExp(r'[/\\]+$'), '')
                  .split(RegExp(r'[/\\]'))
                  .last;
              folderNameToPath[name] = path;
            }

            return CustomScrollView(
              slivers: [
                _buildNavigationBar(),
                SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      childAspectRatio: 2.5,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final entry = mediaByLocation.entries.elementAt(index);
                      return _buildLocationCard(
                        entry.key,
                        entry.value,
                        folderNameToPath,
                      );
                    }, childCount: mediaByLocation.length),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 170)),
              ],
            );
          },
        ),
        // Bottom gradient fade
        Positioned(
          bottom: 0,
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.9),
                  Colors.black,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(
    String locationName,
    List<File> files,
    Map<String, String> folderNameToPath,
  ) {
    // Resolve the full folder path from saved library folders
    final resolvedPath =
        folderNameToPath[locationName] ??
        (files.isNotEmpty ? _extractDirectoryPath(files.first.path) : null);

    return GestureDetector(
      onTap: () async {
        if (resolvedPath != null) {
          final scannedFiles = await _pathManager.scanMediaFiles(resolvedPath);
          _viewLocationFiles(locationName, resolvedPath, scannedFiles);
        }
      },
      onLongPress: () async {
        if (resolvedPath != null) {
          await _removeFolder(resolvedPath);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(50, 50, 50, 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.folder, color: Colors.amber, size: 28),
                        const SizedBox(height: 4),
                        Text(
                          locationName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${files.length} files',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Tooltip(
                message: 'Long press to remove',
                child: Icon(
                  Icons.info_outline,
                  color: Colors.grey[600],
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Extracts the directory path from a file path
  String _extractDirectoryPath(String filePath) {
    final file = File(filePath);
    return file.parent.path;
  }

  /// Sort files alphabetically and build letter-to-index map
  List<File> _sortAndMapLocationFiles(List<File> files) {
    final sorted = List<File>.from(files);
    sorted.sort((a, b) {
      final aName = a.path.split(Platform.pathSeparator).last.toUpperCase();
      final bName = b.path.split(Platform.pathSeparator).last.toUpperCase();
      return aName.compareTo(bName);
    });
    _letterToIndex.clear();
    for (int i = 0; i < sorted.length; i++) {
      final fileName = sorted[i].path.split(Platform.pathSeparator).last;
      final firstChar = fileName.isNotEmpty ? fileName[0].toUpperCase() : '#';
      if (!_letterToIndex.containsKey(firstChar)) {
        _letterToIndex[firstChar] = i;
      }
    }
    return sorted;
  }

  /// Group files by their starting letter
  Map<String, List<File>> _groupFilesByLetter(List<File> files) {
    final Map<String, List<File>> grouped = {};
    for (final file in files) {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final firstChar = fileName.isNotEmpty ? fileName[0].toUpperCase() : '#';
      grouped.putIfAbsent(firstChar, () => []).add(file);
    }
    return grouped;
  }

  /// Scroll to the section starting with the given letter
  void _scrollToLetter(String letter) {
    final index = _letterToIndex[letter];
    if (index != null && _filesScrollController.hasClients) {
      final isDesktop = MediaQuery.of(context).size.width > 700;
      if (isDesktop) {
        final itemsPerRow = (MediaQuery.of(context).size.width / 400).floor();
        final rowIndex = (index / itemsPerRow).floor();
        final offset = rowIndex * (400 / 3 + 5) + 80;
        _filesScrollController.animateTo(
          offset.clamp(0.0, _filesScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        final offset = index * 50.0 + 80;
        _filesScrollController.animateTo(
          offset.clamp(0.0, _filesScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  /// Show the letter picker overlay
  void _showLetterPicker() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.72),
      builder: (ctx) => LetterPickerDialog(
        letterToIndex: _letterToIndex,
        onLetterSelected: (letter) {
          Navigator.of(ctx).pop();
          _scrollToLetter(letter);
        },
      ),
    );
  }

  /// Builds the view showing files in a specific location
  Widget _buildLocationFilesView() {
    final files = _selectedLocationFiles ?? [];
    _sortedLocationFiles = _sortAndMapLocationFiles(files);
    final isDesktop = MediaQuery.of(context).size.width > 700;

    if (files.isEmpty) {
      return CustomScrollView(
        slivers: [
          _buildNavigationBar(),
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_note, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No files found',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final groupedFiles = _groupFilesByLetter(_sortedLocationFiles);
    final sortedLetters = groupedFiles.keys.toList()..sort();

    return Stack(
      children: [
        isDesktop
            ? _buildLocationFilesDesktop(sortedLetters, groupedFiles)
            : _buildLocationFilesMobile(),
        // Bottom gradient fade
        Positioned(
          bottom: 0,
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.9),
                  Colors.black,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationFilesDesktop(
    List<String> sortedLetters,
    Map<String, List<File>> groupedFiles,
  ) {
    return CustomScrollView(
      controller: _filesScrollController,
      slivers: [
        _buildNavigationBar(),
        ...sortedLetters.expand((letter) {
          final filesInSection = groupedFiles[letter]!;
          return [
            // Section header – tap to open letter picker
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: _showLetterPicker,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
            // Grid for this letter's files
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              sliver: SliverGrid.extent(
                maxCrossAxisExtent: 400,
                childAspectRatio: 3,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                children: filesInSection.map((file) {
                  final index = _sortedLocationFiles.indexOf(file);
                  return _buildFileItem(file, index);
                }).toList(),
              ),
            ),
          ];
        }).toList(),
        const SliverToBoxAdapter(child: SizedBox(height: 170)),
      ],
    );
  }

  Widget _buildLocationFilesMobile() {
    return CustomScrollView(
      controller: _filesScrollController,
      slivers: [
        _buildNavigationBar(),
        SliverList.builder(
          itemCount: _sortedLocationFiles.length,
          itemBuilder: (context, index) {
            final file = _sortedLocationFiles[index];
            final fileName = file.path.split(Platform.pathSeparator).last;
            final currentLetter = fileName.isNotEmpty
                ? fileName[0].toUpperCase()
                : '#';

            bool showHeader = false;
            if (index == 0) {
              showHeader = true;
            } else {
              final prevFile = _sortedLocationFiles[index - 1];
              final prevName = prevFile.path.split(Platform.pathSeparator).last;
              final prevLetter = prevName.isNotEmpty
                  ? prevName[0].toUpperCase()
                  : '#';
              showHeader = currentLetter != prevLetter;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showHeader)
                  GestureDetector(
                    onTap: _showLetterPicker,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        currentLetter,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                _buildFileItem(file, index),
              ],
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 170)),
      ],
    );
  }

  Widget _buildFileItem(File file, int index) {
    final fileName = file.path.split(Platform.pathSeparator).last;

    return GestureDetector(
      onTap: () {
        // Handle file tap
      },
      child: AnimatedScale(
        scale: (_hoverIndex == index) ? 1.015 : 1,
        duration: const Duration(milliseconds: 75),
        curve: Curves.linear,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hoverIndex = index),
          onExit: (_) => setState(() => _hoverIndex = -1),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: Color.fromRGBO(50, 50, 50, 1),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  fileName,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
