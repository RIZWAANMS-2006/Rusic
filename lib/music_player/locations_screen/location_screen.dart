import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Rusic/managers/path_manager.dart';
import 'dart:io';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late Future<Map<String, List<File>>> mediaFilesFuture;
  final Pathmanager _pathManager = Pathmanager();

  // State for viewing files in a specific location
  String? _selectedLocationName;
  List<File>? _selectedLocationFiles;
  int _hoverIndex = -1;

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

  /// Go back to locations list view
  void _backToLocationsList() {
    setState(() {
      _selectedLocationName = null;
      _selectedLocationFiles = null;
      _hoverIndex = -1;
    });
  }

  /// Check if currently viewing a specific location's files
  bool get _isViewingLocationFiles => _selectedLocationName != null;

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
          : FutureBuilder<Map<String, List<File>>>(
              future: mediaFilesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                } else if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                } else {
                  return _buildLocationsList(snapshot.data!);
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
        _isViewingLocationFiles ? _selectedLocationName! : 'Locations',
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
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Stack(
      children: [
        FutureBuilder<List<String>>(
          future: _pathManager.getSavedLibraryFolders(),
          builder: (context, folderSnapshot) {
            // Build a map from folder name -> full path for lookup
            final folderNameToPath = <String, String>{};
            if (folderSnapshot.hasData) {
              for (final path in folderSnapshot.data!) {
                final name = path
                    .replaceAll(RegExp(r'[/\\]+$'), '')
                    .split(RegExp(r'[/\\]'))
                    .last;
                folderNameToPath[name] = path;
              }
            }

            return CustomScrollView(
              slivers: [
                _buildNavigationBar(),
                SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: isDesktop
                      ? _buildDesktopLocationsList(
                          mediaByLocation,
                          folderNameToPath,
                        )
                      : _buildMobileLocationsList(
                          mediaByLocation,
                          folderNameToPath,
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

  Widget _buildDesktopLocationsList(
    Map<String, List<File>> mediaByLocation,
    Map<String, String> folderNameToPath,
  ) {
    return SliverGrid.extent(
      maxCrossAxisExtent: 400,
      childAspectRatio: 2.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: mediaByLocation.entries.map((entry) {
        return _buildLocationCard(entry.key, entry.value, folderNameToPath);
      }).toList(),
    );
  }

  Widget _buildMobileLocationsList(
    Map<String, List<File>> mediaByLocation,
    Map<String, String> folderNameToPath,
  ) {
    return SliverList.builder(
      itemCount: mediaByLocation.length,
      itemBuilder: (context, index) {
        final entry = mediaByLocation.entries.elementAt(index);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildLocationCard(entry.key, entry.value, folderNameToPath),
        );
      },
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

  /// Builds the view showing files in a specific location
  Widget _buildLocationFilesView() {
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Stack(
      children: [
        _selectedLocationFiles!.isEmpty
            ? CustomScrollView(
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
              )
            : CustomScrollView(
                slivers: [
                  _buildNavigationBar(),
                  isDesktop
                      ? _buildFilesDesktopGrid()
                      : _buildFilesMobileList(),
                  const SliverToBoxAdapter(child: SizedBox(height: 170)),
                ],
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

  Widget _buildFilesDesktopGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(5),
      sliver: SliverGrid.extent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 3,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        children: List.generate(_selectedLocationFiles!.length, (index) {
          return _buildFileItem(_selectedLocationFiles![index], index);
        }),
      ),
    );
  }

  Widget _buildFilesMobileList() {
    return SliverList.builder(
      itemCount: _selectedLocationFiles!.length,
      itemBuilder: (context, index) {
        return _buildFileListTile(_selectedLocationFiles![index], index);
      },
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

  Widget _buildFileListTile(File file, int index) {
    final fileName = file.path.split(Platform.pathSeparator).last;

    return ListTile(
      leading: Container(
        width: 35,
        height: 35,
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Icon(Icons.music_note, size: 20),
      ),
      tileColor: Color.fromRGBO(50, 50, 50, 1),
      title: Text(
        fileName,
        textAlign: TextAlign.left,
        style: const TextStyle(fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
