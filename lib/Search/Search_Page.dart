import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/svg.dart";
import "package:music_controller/settings/settings.dart";
import "package:music_controller/managers/path_manager.dart";
import "dart:io";
import 'package:music_controller/music_player/music_controller.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

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

class _SearchState extends State<Search> {
  late Future<Map<String, List<File>>> mediaFileFuture;
  int hoverIndex = -1;

  @override
  void initState() {
    super.initState();
    mediaFileFuture = Pathmanager().fetchAllMediaFiles();
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
                  final mediaByLocation = snapshot.data!;
                  final allFiles = mediaByLocation.values
                      .expand((files) => files)
                      .toList();
                  if (MediaQuery.of(context).size.width > 700) {
                    return Scaffold(
                      floatingActionButton: MusicSearchBar(),
                      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
                      body: CustomScrollView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        slivers: [
                          CupertinoSliverNavigationBar(
                            stretch: true,
                            backgroundColor:
                                setContainerColor(context), // Replace with your color logic
                            largeTitle: const Text("Search"),
                            // middle: const Text("Search"),
                            alwaysShowMiddle: false,
                            transitionBetweenRoutes: false,
                            border: null,
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.only(
                              left: 5,
                              bottom: 5,
                              right: 5,
                              top: 5,
                            ),
                            sliver: SliverGrid.extent(
                              maxCrossAxisExtent: 400,
                              childAspectRatio: 3,
                              mainAxisSpacing: 5,
                              crossAxisSpacing: 5,
                              children: List.generate(allFiles.length, (
                                index,
                              ) {
                                return GestureDetector(
                                  onTap: () {
                                    audio_path = allFiles[index].path;
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
                                            allFiles[index].path
                                                .split(Platform.pathSeparator)
                                                .last,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
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
                              itemCount: allFiles.length,
                              itemBuilder: (context, index) {
                                return ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: double.infinity,
                                    minHeight: 50,
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      audio_path = allFiles[index].path;
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
                                      allFiles[index].path
                                          .split(Platform.pathSeparator)
                                          .last,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SliverToBoxAdapter(child: SizedBox(height: 170)),
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
        ],
      ),
    );
  }
}
