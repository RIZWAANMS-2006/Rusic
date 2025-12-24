import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/svg.dart";
import "package:music_controller/Settings/Settings_UI.dart";
import "package:path_provider/path_provider.dart";
import "dart:io";
import 'package:music_controller/Music Player/Music_Controller.dart';

Future<String> getOrCreateMyMusicDirectory() async {
  Directory? myMusicDir;
  if (Platform.isAndroid) {
    myMusicDir = Directory('/storage/emulated/0/Download/MyMusic');
  } else if (Platform.isWindows) {
    myMusicDir = await getDownloadsDirectory();
  } else if (Platform.isLinux) {
    final String? home = Platform.environment['HOME'];
    final String separator = Platform.pathSeparator;
    final String musicPath = '$home${separator}Downloads${separator}MyMusic';
    myMusicDir = Directory(musicPath);
  }
  if (await myMusicDir!.exists()) {
    return myMusicDir.path;
  } else {
    await myMusicDir.create(recursive: true);
    return myMusicDir.path;
  }
}

Future<List<File>> getMediaFiles(String path) async {
  final dir = Directory(path);
  final files = dir.listSync(recursive: true);
  // List of common audio and video file extensions
  final extensions = [
    '.mp3', '.wav', '.aac', '.flac', '.ogg', '.m4a', // audio
    '.mp4', '.avi', '.mov', '.wmv', '.flv', '.mkv', '.webm', '.3gp', // video
  ];
  return files
      .whereType<File>()
      .where(
        (file) =>
            extensions.any((ext) => file.path.toLowerCase().endsWith(ext)),
      )
      .toList();
}

Future<List<File>> comboFunction() async {
  List<File> mediaFiles = await getMediaFiles(
    await getOrCreateMyMusicDirectory(),
  );
  return mediaFiles;
}

class Search_Page extends StatefulWidget {
  const Search_Page({super.key});

  @override
  State<Search_Page> createState() => _Search_PageState();
}

class MusicSearchBar extends StatefulWidget {
  const MusicSearchBar({super.key});

  @override
  State<StatefulWidget> createState() => _MusicSearchBarState();
}

class _MusicSearchBarState extends State<MusicSearchBar> {
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

class _Search_PageState extends State<Search_Page> {
  late Future<List<File>> mediaFileFuture;
  int hoverIndex = -1;

  @override
  void initState() {
    super.initState();
    mediaFileFuture = comboFunction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(26, 26, 26, 1),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: MediaQuery.of(context).size.width > 700
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 75, left: 5, right: 5),
              child: Bottom_Music_Controller(),
            ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: FutureBuilder(
              future: mediaFileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No media files found',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  if (MediaQuery.of(context).size.width > 700) {
                    return Stack(
                      children: [
                        GridView.extent(
                          padding: const EdgeInsets.only(left: 5, bottom: 5),
                          maxCrossAxisExtent: 400,
                          childAspectRatio: 3,
                          shrinkWrap: false,
                          children: List.generate(snapshot.data!.length, (
                            index,
                          ) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 5, top: 5),
                              child: GestureDetector(
                                onTap: () {
                                  audio_path = snapshot.data![index].path;
                                  audioPlayAndPauseFunction();
                                  setState(() {});
                                },
                                child: AnimatedScale(
                                  scale: (hoverIndex == index) ? 1.015 : 1,
                                  duration: Duration(milliseconds: 75),
                                  curve: Curves.linear,
                                  child: MouseRegion(
                                    onEnter: (event) {
                                      setState(() {
                                        hoverIndex = index;
                                      });
                                    },
                                    onExit: (event) {
                                      setState(() {
                                        hoverIndex = -1;
                                      });
                                    },
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        color: setContainerColor(context),
                                      ),
                                      child: Center(
                                        child: Text(
                                          snapshot.data![index].path
                                              .split(Platform.pathSeparator)
                                              .last,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Center(child: MusicSearchBar()),
                        ),
                      ],
                    );
                  } else {
                    return Stack(
                      children: [
                        CustomScrollView(
                          slivers: [
                            CupertinoSliverNavigationBar(
                              backgroundColor: setContainerColor(context),
                              largeTitle: Text("Search"),
                              middle: Text("Search"),
                              alwaysShowMiddle: false,
                            ),
                            SliverList.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: double.infinity,
                                    minHeight: 50,
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      audio_path = snapshot.data![index].path;
                                      audioPlayAndPauseFunction();
                                      if (indicatorState == 0) {
                                        indicatorState = 1;
                                      } else {
                                        indicatorState = 0;
                                      }
                                      setState(() {});
                                    },
                                    leading: Container(
                                      width: 35,
                                      height: 35,
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                      ),
                                      child: SvgPicture.asset(
                                        "assets/MusicIcons/MusicLogo.svg",
                                      ),
                                    ),
                                    tileColor: setContainerColor(context),
                                    title: Text(
                                      snapshot.data![index].path
                                          .split(Platform.pathSeparator)
                                          .last,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SliverToBoxAdapter(
                              child: Container(
                                height: 170,
                                color: setContainerColor(context),
                              ),
                            ),
                          ],
                        ),
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
                }
              },
            ),
          ),
          MediaQuery.of(context).size.width > 700
              ? SideBar_Music_Controller()
              : Container(),
        ],
      ),
    );
  }
}
