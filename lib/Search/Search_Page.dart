import "package:flutter/material.dart";
import "package:music_controller/managers/path_manager.dart";
import "dart:io";
import 'package:music_controller/ui/media_ui.dart';

class MusicSearchBar extends StatelessWidget {
  const MusicSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      builder: (context, controller) {
        return SearchBar(
          controller: controller,
          onTap: () {
            controller.openView();
          },
          onChanged: (value) {
            controller.openView();
          },
          leading: const Icon(Icons.search),
        );
      },
      suggestionsBuilder: (context, controller) {
        return [ListTile(title: Text("Search is not available yet"))];
      },
    );
  }
}

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late Future<Map<String, List<File>>> mediaFileFuture;

  @override
  void initState() {
    super.initState();
    mediaFileFuture = Pathmanager().fetchMediaFilesFromLibrary();
  }

  void _refreshMedia() {
    setState(() {
      mediaFileFuture = Pathmanager().fetchMediaFilesFromLibrary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MediaUI(
      title: "Search",
      mediaFilesFuture: mediaFileFuture,
      showSearchBar: true,
      showMusicController: true,
      emptyMessage: "No media files found",
      onEmptyAction: () async {
        final added = await Pathmanager().addLibraryFolder();
        if (added) {
          _refreshMedia();
        }
      },
    );
  }
}
