import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:music_controller/music_player/music_controller.dart';
import 'package:music_controller/managers/ui_manager.dart';
import 'package:music_controller/managers/path_manager.dart';
import 'dart:io';
import 'package:music_controller/search/search_page.dart';

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
  });

  @override
  State<MediaUI> createState() => _MediaUIState();
}

class _MediaUIState extends State<MediaUI> {
  int hoverIndex = -1;

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
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          } else {
            return _buildContent(snapshot.data!);
          }
        },
      );
    }

    // No data provided
    return _buildEmptyState();
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: Color.fromRGBO(26, 26, 26, 1),
      body: CustomScrollView(
        slivers: [
          _buildNavigationBar(),
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(26, 26, 26, 1),
      body: CustomScrollView(
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
                    'Error loading files',
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: Color.fromRGBO(26, 26, 26, 1),
      body: CustomScrollView(
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
                    widget.emptyMessage,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
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
                        backgroundColor: Colors.deepPurple,
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
    );
  }

  Widget _buildContent(Map<String, List<File>> mediaByLocation) {
    final allFiles = mediaByLocation.values.expand((files) => files).toList();
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: Color.fromRGBO(26, 26, 26, 1),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: widget.showMusicController && !isDesktop
          ? Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
              child: BottomMusicController(),
            )
          : null,
      body: isDesktop
          ? _buildDesktopLayout(allFiles)
          : _buildMobileLayout(allFiles),
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

  Widget _buildDesktopLayout(List<File> allFiles) {
    return Scaffold(
      floatingActionButton: widget.showSearchBar ? MusicSearchBar() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildNavigationBar(),
              SliverPadding(
                padding: const EdgeInsets.all(5),
                sliver: SliverGrid.extent(
                  maxCrossAxisExtent: 400,
                  childAspectRatio: 3,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  children: List.generate(allFiles.length, (index) {
                    return _buildGridItem(allFiles[index], index);
                  }),
                ),
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
      ),
    );
  }

  Widget _buildMobileLayout(List<File> allFiles) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              backgroundColor: setContainerColor(context),
              largeTitle: Text(widget.title),
              middle: Text(widget.title),
              alwaysShowMiddle: false,
            ),
            SliverList.builder(
              itemCount: allFiles.length,
              itemBuilder: (context, index) {
                return _buildListItem(allFiles[index], index);
              },
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

  Widget _buildGridItem(File file, int index) {
    final fileName = file.path.split(Platform.pathSeparator).last;

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
    final fileName = file.path.split(Platform.pathSeparator).last;

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
        tileColor: setContainerColor(context),
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
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          } else {
            return _buildContent(snapshot.data!);
          }
        },
      );
    }

    // No data provided
    return _buildEmptyState();
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: Color.fromRGBO(26, 26, 26, 1),
      appBar: _buildAppBar(),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(String error) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(26, 26, 26, 1),
      appBar: _buildAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading songs',
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
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: Color.fromRGBO(26, 26, 26, 1),
      appBar: _buildAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              widget.emptyMessage,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
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
        if (widget.onLogout != null)
          Padding(
            padding: EdgeInsets.only(right: isDesktop ? 8.0 : 10.0),
            child: isDesktop
                ? Transform.scale(
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
                      child: Row(
                        spacing: 5,
                        children: [
                          Icon(Icons.power_settings_new_rounded),
                          Text("Logout"),
                        ],
                      ),
                    ),
                  )
                : FilledButton(
                    onPressed: widget.onLogout,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    child: Row(
                      spacing: 5,
                      children: [
                        Icon(Icons.power_settings_new_rounded),
                        Text("Logout"),
                      ],
                    ),
                  ),
          ),
      ],
    );
  }

  Widget _buildContent(List<OnlineSong> songs) {
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: Color.fromRGBO(26, 26, 26, 1),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: widget.showMusicController && !isDesktop
          ? Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
              child: BottomMusicController(),
            )
          : null,
      body: isDesktop ? _buildDesktopLayout(songs) : _buildMobileLayout(songs),
    );
  }

  Widget _buildDesktopLayout(List<OnlineSong> songs) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
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
                  child: Row(
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
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(5),
                sliver: SliverGrid.extent(
                  maxCrossAxisExtent: 400,
                  childAspectRatio: 3,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  children: List.generate(songs.length, (index) {
                    return _buildGridItem(songs[index], index);
                  }),
                ),
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
          style: TextStyle(
            fontSize: 18,
            fontFamily: "Normal",
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          if (widget.onLogout != null)
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: FilledButton(
                onPressed: widget.onLogout,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                child: Row(
                  spacing: 5,
                  children: [
                    Icon(Icons.power_settings_new_rounded),
                    Text("Logout"),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              return _buildListItem(songs[index], index);
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
        tileColor: setContainerColor(context),
        title: Text(
          song.title,
          textAlign: TextAlign.left,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: song.artist != null
            ? Text(
                song.artist!,
                style: TextStyle(fontSize: 12, color: Colors.grey),
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
}
