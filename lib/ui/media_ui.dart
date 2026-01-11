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
      body: CustomScrollView(
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
