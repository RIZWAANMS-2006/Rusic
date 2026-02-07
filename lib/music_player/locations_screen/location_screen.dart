import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_controller/managers/path_manager.dart';
import 'package:music_controller/ui/media_ui.dart';
import 'dart:io';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late Future<Map<String, List<File>>> mediaFilesFuture;
  final Pathmanager _pathManager = Pathmanager();

  @override
  void initState() {
    super.initState();
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addFolder,
        tooltip: 'Add Folder',
        child: Icon(Icons.add),
      ),
      body: FutureBuilder<Map<String, List<File>>>(
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
    return CupertinoSliverNavigationBar(
      stretch: true,
      backgroundColor: Color.fromRGBO(34, 34, 34, 1),
      largeTitle: Text('Locations'),
      alwaysShowMiddle: false,
      transitionBetweenRoutes: false,
      border: null,
    );
  }

  Widget _buildLocationsList(Map<String, List<File>> mediaByLocation) {
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            _buildNavigationBar(),
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: isDesktop
                  ? _buildDesktopLocationsList(mediaByLocation)
                  : _buildMobileLocationsList(mediaByLocation),
            ),
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

  Widget _buildDesktopLocationsList(Map<String, List<File>> mediaByLocation) {
    return SliverGrid.extent(
      maxCrossAxisExtent: 400,
      childAspectRatio: 2.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: mediaByLocation.entries.map((entry) {
        return _buildLocationCard(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildMobileLocationsList(Map<String, List<File>> mediaByLocation) {
    return SliverList.builder(
      itemCount: mediaByLocation.length,
      itemBuilder: (context, index) {
        final entry = mediaByLocation.entries.elementAt(index);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildLocationCard(entry.key, entry.value),
        );
      },
    );
  }

  Widget _buildLocationCard(String locationName, List<File> files) {
    return GestureDetector(
      onTap: () async {
        if (files.isNotEmpty) {
          final fullPath = _extractDirectoryPath(files.first.path);
          // Navigate to file viewer
          _navigateToFilesView(locationName, fullPath);
        }
      },
      onLongPress: () async {
        // Get the full path from files
        final fullPath = files.isNotEmpty
            ? _extractDirectoryPath(files.first.path)
            : null;
        if (fullPath != null) {
          await _removeFolder(fullPath);
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
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.folder, color: Colors.amber, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        locationName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Text(
                    '${files.length} files',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
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
    // This should match a saved library folder
    final pathManager = Pathmanager();
    // We'll use the file path and try to find which library folder it belongs to
    // For now, we'll return the parent directory
    final file = File(filePath);
    return file.parent.path;
  }

  Future<void> _navigateToFilesView(
    String locationName,
    String folderPath,
  ) async {
    final files = await _pathManager.scanMediaFiles(folderPath);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationFilesView(
            locationName: locationName,
            folderPath: folderPath,
            files: files,
          ),
        ),
      );
    }
  }
}

/// Screen to display files in a specific location
class LocationFilesView extends StatefulWidget {
  final String locationName;
  final String folderPath;
  final List<File> files;

  const LocationFilesView({
    super.key,
    required this.locationName,
    required this.folderPath,
    required this.files,
  });

  @override
  State<LocationFilesView> createState() => _LocationFilesViewState();
}

class _LocationFilesViewState extends State<LocationFilesView> {
  int hoverIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: Color.fromRGBO(26, 26, 26, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.locationName,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      body: Stack(
        children: [
          widget.files.isEmpty
              ? Center(
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
                )
              : CustomScrollView(
                  slivers: [
                    isDesktop ? _buildDesktopGrid() : _buildMobileList(),
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
      ),
    );
  }

  Widget _buildDesktopGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(5),
      sliver: SliverGrid.extent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 3,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        children: List.generate(widget.files.length, (index) {
          return _buildFileItem(widget.files[index], index);
        }),
      ),
    );
  }

  Widget _buildMobileList() {
    return SliverList.builder(
      itemCount: widget.files.length,
      itemBuilder: (context, index) {
        return _buildFileListTile(widget.files[index], index);
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
        scale: (hoverIndex == index) ? 1.015 : 1,
        duration: const Duration(milliseconds: 75),
        curve: Curves.linear,
        child: MouseRegion(
          onEnter: (_) => setState(() => hoverIndex = index),
          onExit: (_) => setState(() => hoverIndex = -1),
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
