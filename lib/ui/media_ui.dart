import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:Rusic/music_player/music_controller.dart';
import 'package:Rusic/managers/ui_manager.dart';
import 'dart:io';
import 'package:Rusic/search/search_page.dart';
import 'package:shimmer/shimmer.dart';

/// A universal UI component for displaying media files across different tabs.
///
/// Supports both grid view (desktop) and list view (mobile) layouts.
/// Can be used with either a Future or direct data.
class MediaUI extends StatefulWidget {
  /// The title displayed in the navigation bar
  final String title;

  /// Future that resolves to media files grouped by location
  final Future<Map<String, List<File>>>? mediaFilesFuture;

  /// Direct media files data (use this OR mediaFilesFuture, not both)
  final Map<String, List<File>>? mediaFiles;

  /// Callback when no media files are found - typically to add folders
  final VoidCallback? onEmptyAction;

  /// Text for the empty state action button
  final String emptyActionText;

  /// Message shown when no media files are found
  final String emptyMessage;

  /// Whether to show the search bar (for search tab)
  final bool showSearchBar;

  /// Whether to show the floating music controller
  final bool showMusicController;

  /// Whether to show the navigation bar
  final bool showNavigationBar;

  const MediaUI({
    super.key,
    this.title = "Media",
    this.mediaFilesFuture,
    this.mediaFiles,
    this.onEmptyAction,
    this.emptyActionText = "Add Folder",
    this.emptyMessage = "No media files found",
    this.showSearchBar = false,
    this.showMusicController = true,
    this.showNavigationBar = true,
  });

  @override
  State<MediaUI> createState() => _MediaUIState();
}

class _MediaUIState extends State<MediaUI> {
  int hoverIndex = -1;
  final ScrollController _scrollController = ScrollController();
  final Map<String, int> _letterToIndex = {};
  List<File> _sortedFiles = [];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If direct data is provided, use it; otherwise use the future
    if (widget.mediaFiles != null) {
      return _buildContent(widget.mediaFiles!);
    }

    if (widget.mediaFilesFuture != null) {
      return FutureBuilder<Map<String, List<File>>>(
        future: widget.mediaFilesFuture,
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
            return _buildContent(data);
          }
        },
      );
    }

    // No data provided
    return _buildEmptyState();
  }

  Widget _buildLoadingState() {
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: CustomScrollView(
          slivers: [
            if (widget.showNavigationBar) _buildNavigationBar(),
            SliverFillRemaining(
              child: Shimmer.fromColors(
                baseColor: Colors.grey[850]!,
                highlightColor: Colors.grey[700]!,
                child: isDesktop
                    ? const _DesktopShimmer()
                    : const _MobileShimmer(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: CustomScrollView(
          slivers: [
            if (widget.showNavigationBar) _buildNavigationBar(),
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    const Text(
                      'Error loading files',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: CustomScrollView(
          slivers: [
            if (widget.showNavigationBar) _buildNavigationBar(),
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      widget.emptyMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add folders to your library to see media',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    if (widget.onEmptyAction != null) ...[
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: widget.onEmptyAction,
                        icon: const Icon(Icons.add_rounded),
                        label: Text(widget.emptyActionText),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<File>>? _lastMediaByLocation;

  Widget _buildContent(Map<String, List<File>> mediaByLocation) {
    if (_lastMediaByLocation != mediaByLocation) {
      final allFiles = mediaByLocation.values.expand((files) => files).toList();
      _sortedFiles = _sortAndMapFiles(allFiles);
      _lastMediaByLocation = mediaByLocation;
    }

    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildNavigationBar() {
    return CupertinoSliverNavigationBar(
      stretch: true,
      backgroundColor: setContainerColor(context),
      largeTitle: Text(widget.title),
      alwaysShowMiddle: false,
      transitionBetweenRoutes: false,
      border: null,
    );
  }

  Widget _buildDesktopLayout() {
    final groupedFiles = _groupFilesByLetter(_sortedFiles);
    final sortedLetters = groupedFiles.keys.toList()..sort();

    return Scaffold(
      floatingActionButton: widget.showSearchBar
          ? const MusicSearchBar()
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                if (widget.showNavigationBar) _buildNavigationBar(),
                // Build sections for each letter
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
                          final index = _sortedFiles.indexOf(file);
                          return _buildGridItem(file, index);
                        }).toList(),
                      ),
                    ),
                  ];
                }),
                const SliverToBoxAdapter(child: SizedBox(height: 170)),
              ],
            ),
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

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              if (widget.showNavigationBar)
                CupertinoSliverNavigationBar(
                  backgroundColor: setContainerColor(context),
                  largeTitle: Text(widget.title),
                  middle: Text(widget.title),
                  alwaysShowMiddle: false,
                ),
              SliverList.builder(
                itemCount: _sortedFiles.length,
                itemBuilder: (context, index) {
                  final file = _sortedFiles[index];
                  final fileName = file.path.substring(
                    file.path.lastIndexOf(Platform.pathSeparator) + 1,
                  );
                  final currentLetter = fileName.isNotEmpty
                      ? fileName[0].toUpperCase()
                      : '#';

                  // Check if this is the first item of a new letter section
                  bool showHeader = false;
                  if (index == 0) {
                    showHeader = true;
                  } else {
                    final prevFile = _sortedFiles[index - 1];
                    final prevFileName = prevFile.path.substring(
                      prevFile.path.lastIndexOf(Platform.pathSeparator) + 1,
                    );
                    final prevLetter = prevFileName.isNotEmpty
                        ? prevFileName[0].toUpperCase()
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
                      _buildListItem(file, index),
                    ],
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 150)),
            ],
          ),
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

  Widget _buildGridItem(File file, int index) {
    final fileName = file.path.substring(
      file.path.lastIndexOf(Platform.pathSeparator) + 1,
    );

    return GestureDetector(
      onTap: () => _onFileTap(file),
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
              color: setContainerColor(context),
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

  Widget _buildListItem(File file, int index) {
    final fileName = file.path.substring(
      file.path.lastIndexOf(Platform.pathSeparator) + 1,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        minHeight: 50,
      ),
      child: ListTile(
        onTap: () => _onFileTap(file),
        leading: Container(
          width: 35,
          height: 35,
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: SvgPicture.asset("assets/MusicIcons/MusicLogo.svg"),
        ),
        tileColor: const Color.fromRGBO(26, 26, 26, 1),
        title: Text(
          fileName,
          textAlign: TextAlign.left,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  void _onFileTap(File file) {
    audio_path = file.path;
    audioPlayAndPauseFunction();
    if (indicatorState == 0) {
      indicatorState = 1;
    } else {
      indicatorState = 0;
    }
    setState(() {});
  }

  /// Sort files alphabetically and create letter-to-index mapping
  List<File> _sortAndMapFiles(List<File> files) {
    if (files.isEmpty) return [];

    // Cache uppercase names to avoid O(N log N) string splitting inside sort
    final Map<File, String> nameCache = {};
    for (final file in files) {
      final lastSeparator = file.path.lastIndexOf(Platform.pathSeparator);
      final fileName = lastSeparator != -1
          ? file.path.substring(lastSeparator + 1)
          : file.path;
      nameCache[file] = fileName.toUpperCase();
    }

    final sorted = List<File>.from(files);
    sorted.sort((a, b) => nameCache[a]!.compareTo(nameCache[b]!));

    // Create letter-to-index mapping
    _letterToIndex.clear();
    for (int i = 0; i < sorted.length; i++) {
      final fileName = sorted[i].path.substring(
        sorted[i].path.lastIndexOf(Platform.pathSeparator) + 1,
      );
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
      final fileName = file.path.substring(
        file.path.lastIndexOf(Platform.pathSeparator) + 1,
      );
      final firstChar = fileName.isNotEmpty ? fileName[0].toUpperCase() : '#';
      grouped.putIfAbsent(firstChar, () => []).add(file);
    }
    return grouped;
  }

  /// Scroll to the section starting with the given letter
  void _scrollToLetter(String letter) {
    final index = _letterToIndex[letter];
    if (index != null && _scrollController.hasClients) {
      // Calculate approximate position
      // For grid: each row has multiple items
      // For list: each item has a fixed height
      final isDesktop = MediaQuery.of(context).size.width > 700;

      if (isDesktop) {
        // Grid layout calculation
        final itemsPerRow = (MediaQuery.of(context).size.width / 400).floor();
        final rowIndex = (index / itemsPerRow).floor();
        final offset = rowIndex * (400 / 3 + 5) + 100; // childAspectRatio = 3

        _scrollController.animateTo(
          offset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // List layout calculation
        final offset = index * 50.0 + 100; // approximate item height

        _scrollController.animateTo(
          offset.clamp(0.0, _scrollController.position.maxScrollExtent),
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
}

/// A model class representing an online song from Supabase
class OnlineSong {
  final String title;
  final String url;
  final String? artist;
  final String? album;

  OnlineSong({required this.title, required this.url, this.artist, this.album});

  factory OnlineSong.fromMap(Map<String, dynamic> map) {
    // Create a case-insensitive lookup
    final lowerMap = <String, dynamic>{};
    for (final entry in map.entries) {
      lowerMap[entry.key.toLowerCase()] = entry.value;
    }

    return OnlineSong(
      title:
          lowerMap['title']?.toString() ??
          lowerMap['name']?.toString() ??
          lowerMap['song_name']?.toString() ??
          lowerMap['filename']?.toString() ??
          'Unknown Song',
      url:
          lowerMap['url']?.toString() ??
          lowerMap['audio_url']?.toString() ??
          lowerMap['file_url']?.toString() ??
          lowerMap['path']?.toString() ??
          '',
      artist: lowerMap['artist']?.toString(),
      album: lowerMap['album']?.toString(),
    );
  }
}

/// A UI component for displaying online media files from Supabase.
///
/// Supports both grid view (desktop) and list view (mobile) layouts.
/// Similar to MediaUI but designed for online songs.
class OnlineMediaUI extends StatefulWidget {
  /// The title displayed in the navigation bar
  final String title;

  /// Future that resolves to list of online songs
  final Future<List<OnlineSong>>? songsFuture;

  /// Direct songs data (use this OR songsFuture, not both)
  final List<OnlineSong>? songs;

  /// Message shown when no songs are found
  final String emptyMessage;

  /// Whether to show the floating music controller
  final bool showMusicController;

  /// Optional logout callback
  final VoidCallback? onLogout;

  const OnlineMediaUI({
    super.key,
    this.title = "Online",
    this.songsFuture,
    this.songs,
    this.emptyMessage = "No songs found",
    this.showMusicController = true,
    this.onLogout,
  });

  @override
  State<OnlineMediaUI> createState() => _OnlineMediaUIState();
}

class _OnlineMediaUIState extends State<OnlineMediaUI> {
  int hoverIndex = -1;
  final ScrollController _scrollController = ScrollController();
  final Map<String, int> _letterToIndex = {};
  List<OnlineSong> _sortedSongs = [];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If direct data is provided, use it; otherwise use the future
    if (widget.songs != null) {
      return _buildContent(widget.songs!);
    }

    if (widget.songsFuture != null) {
      return FutureBuilder<List<OnlineSong>>(
        future: widget.songsFuture,
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
            return _buildContent(data);
          }
        },
      );
    }

    // No data provided
    return _buildEmptyState();
  }

  Widget _buildLoadingState() {
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
      appBar: _buildAppBar(),
      body: Shimmer.fromColors(
        baseColor: Colors.grey[850]!,
        highlightColor: Colors.grey[700]!,
        child: isDesktop ? const _DesktopShimmer() : const _MobileShimmer(),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
      appBar: _buildAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text(
              'Error loading songs',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
      appBar: _buildAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              widget.emptyMessage,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'No songs available in this table',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    final isDesktop = MediaQuery.of(context).size.width > 700;
    return AppBar(
      title: Text(
        widget.title,
        style: TextStyle(
          fontSize: isDesktop ? 22 : 18,
          fontFamily: "Normal",
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.transparent,
      actions: [
        if (isDesktop && widget.onLogout != null)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Transform.scale(
              scale: 0.9,
              child: FilledButton(
                onPressed: widget.onLogout,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Row(
                  spacing: 5,
                  children: [
                    Icon(Icons.power_settings_new_rounded),
                    Text("Logout"),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<OnlineSong>? _lastOnlineSongs;

  Widget _buildContent(List<OnlineSong> songs) {
    if (_lastOnlineSongs != songs) {
      _sortedSongs = _sortAndMapSongs(songs);
      _lastOnlineSongs = songs;
    }
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: widget.showMusicController && !isDesktop
      //     ? Padding(
      //         padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
      //         child: BottomMusicController(),
      //       )
      //     : null,
      body: isDesktop ? _buildDesktopLayout(songs) : _buildMobileLayout(songs),
    );
  }

  Widget _buildDesktopLayout(List<OnlineSong> songs) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 22,
            fontFamily: "Normal",
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          if (widget.onLogout != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Transform.scale(
                scale: 0.9,
                child: FilledButton(
                  onPressed: widget.onLogout,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Row(
                    spacing: 5,
                    children: [
                      Icon(Icons.power_settings_new_rounded),
                      Text("Logout"),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Build sections for each letter
                ...(() {
                  final groupedSongs = _groupSongsByLetter(_sortedSongs);
                  final sortedLetters = groupedSongs.keys.toList()..sort();

                  return sortedLetters.expand((letter) {
                    final songsInSection = groupedSongs[letter]!;
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
                      // Grid for this letter's songs
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        sliver: SliverGrid.extent(
                          maxCrossAxisExtent: 400,
                          childAspectRatio: 3,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                          children: songsInSection.map((song) {
                            final index = _sortedSongs.indexOf(song);
                            return _buildGridItem(song, index);
                          }).toList(),
                        ),
                      ),
                    ];
                  }).toList();
                })(),
                const SliverToBoxAdapter(child: SizedBox(height: 170)),
              ],
            ),
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

  Widget _buildMobileLayout(List<OnlineSong> songs) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontFamily: "Normal",
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: const [],
      ),
      body: Stack(
        children: [
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _sortedSongs.length,
              itemBuilder: (context, index) {
                final song = _sortedSongs[index];
                final currentLetter = song.title.isNotEmpty
                    ? song.title[0].toUpperCase()
                    : '#';

                // Check if this is the first item of a new letter section
                bool showHeader = false;
                if (index == 0) {
                  showHeader = true;
                } else {
                  final prevSong = _sortedSongs[index - 1];
                  final prevLetter = prevSong.title.isNotEmpty
                      ? prevSong.title[0].toUpperCase()
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
                    _buildListItem(song, index),
                  ],
                );
              },
            ),
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

  Widget _buildGridItem(OnlineSong song, int index) {
    return GestureDetector(
      onTap: () => _onSongTap(song),
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
              color: setContainerColor(context),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  song.title,
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

  Widget _buildListItem(OnlineSong song, int index) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        minHeight: 50,
      ),
      child: ListTile(
        onTap: () => _onSongTap(song),
        leading: Container(
          width: 35,
          height: 35,
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: SvgPicture.asset("assets/MusicIcons/MusicLogo.svg"),
        ),
        tileColor: const Color.fromRGBO(26, 26, 26, 1),

        title: Text(
          song.title,
          textAlign: TextAlign.left,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: song.artist != null
            ? Text(
                song.artist!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              )
            : null,
      ),
    );
  }

  void _onSongTap(OnlineSong song) {
    if (song.url.isNotEmpty) {
      audio_path = song.url;
      audioPlayAndPauseFunction();
      if (indicatorState == 0) {
        indicatorState = 1;
      } else {
        indicatorState = 0;
      }
      setState(() {});
    }
  }

  /// Sort songs alphabetically and create letter-to-index mapping
  List<OnlineSong> _sortAndMapSongs(List<OnlineSong> songs) {
    if (songs.isEmpty) return [];

    final Map<OnlineSong, String> nameCache = {};
    for (final song in songs) {
      nameCache[song] = song.title.toUpperCase();
    }

    final sorted = List<OnlineSong>.from(songs);
    sorted.sort((a, b) => nameCache[a]!.compareTo(nameCache[b]!));

    // Create letter-to-index mapping
    _letterToIndex.clear();
    for (int i = 0; i < sorted.length; i++) {
      final firstChar = sorted[i].title.isNotEmpty
          ? sorted[i].title[0].toUpperCase()
          : '#';
      if (!_letterToIndex.containsKey(firstChar)) {
        _letterToIndex[firstChar] = i;
      }
    }

    return sorted;
  }

  /// Group songs by their starting letter
  Map<String, List<OnlineSong>> _groupSongsByLetter(List<OnlineSong> songs) {
    final Map<String, List<OnlineSong>> grouped = {};
    for (final song in songs) {
      final firstChar = song.title.isNotEmpty
          ? song.title[0].toUpperCase()
          : '#';
      grouped.putIfAbsent(firstChar, () => []).add(song);
    }
    return grouped;
  }

  /// Scroll to the section starting with the given letter
  void _scrollToLetter(String letter) {
    final index = _letterToIndex[letter];
    if (index != null && _scrollController.hasClients) {
      final isDesktop = MediaQuery.of(context).size.width > 700;

      if (isDesktop) {
        // Grid layout calculation
        final itemsPerRow = (MediaQuery.of(context).size.width / 400).floor();
        final rowIndex = (index / itemsPerRow).floor();
        final offset = rowIndex * (400 / 3 + 5) + 100;

        _scrollController.animateTo(
          offset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // List layout calculation
        final offset = index * 50.0 + 100;

        _scrollController.animateTo(
          offset.clamp(0.0, _scrollController.position.maxScrollExtent),
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
}

/// A full-screen letter picker dialog.
///
/// Shows a grid of alphabetical characters (matching the screenshot).
/// Available letters (those that have songs) are bright white; unavailable
/// ones are dimmed.  Tapping a letter dismisses the dialog and jumps to
/// that section in the list.
class LetterPickerDialog extends StatelessWidget {
  final Map<String, int> letterToIndex;
  final void Function(String) onLetterSelected;

  const LetterPickerDialog({
    super.key,
    required this.letterToIndex,
    required this.onLetterSelected,
  });

  // All selectable entries in display order (matches screenshot layout)
  static const List<String> _letters = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    '#',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(36, 36, 36, 0.97),
            borderRadius: BorderRadius.circular(22),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Letter grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.15,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                  ),
                  itemCount: _letters.length,
                  itemBuilder: (context, index) {
                    final letter = _letters[index];
                    final isAvailable = letterToIndex.containsKey(letter);
                    return GestureDetector(
                      onTap: isAvailable
                          ? () => onLetterSelected(letter)
                          : null,
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Text(
                          letter,
                          style: TextStyle(
                            color: isAvailable
                                ? Colors.white
                                : Colors.white.withOpacity(0.22),
                            fontSize: 22,
                            fontWeight: isAvailable
                                ? FontWeight.w400
                                : FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Globe / language icon row (decorative, as in the screenshot)
                Icon(
                  Icons.language_rounded,
                  color: Colors.white.withOpacity(0.55),
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopShimmer extends StatelessWidget {
  const _DesktopShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.extent(
      maxCrossAxisExtent: 400,
      childAspectRatio: 3,
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      children: List.generate(15, (index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(4),
          child: Row(
            children: [
              Container(
                width: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      color: Colors.white,
                      margin: const EdgeInsets.only(right: 20),
                    ),
                    const SizedBox(height: 8),
                    Container(height: 12, width: 100, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _MobileShimmer extends StatelessWidget {
  const _MobileShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 15,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      color: Colors.white,
                      margin: const EdgeInsets.only(right: 40),
                    ),
                    const SizedBox(height: 8),
                    Container(height: 12, width: 150, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.more_vert, color: Colors.white),
            ],
          ),
        );
      },
    );
  }
}
