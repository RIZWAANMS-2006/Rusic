import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Rusic/music_player/dynamic_background.dart';
import 'package:Rusic/managers/audio_manager.dart';
import "package:Rusic/managers/ui_manager.dart";
import 'package:Rusic/managers/songs_manager.dart';
import 'package:Rusic/managers/video_manager.dart';
import 'package:video_player/video_player.dart';

bool _isDragging = false;
double _dragValue = 0.0;

class MusicQueueScreen extends StatefulWidget {
  final BuildContext? context;
  const MusicQueueScreen({super.key, this.context});

  @override
  State<MusicQueueScreen> createState() => _MusicQueueScreenState();
}

class _MusicQueueScreenState extends State<MusicQueueScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SongsManager(),
      builder: (context, _) {
        final songsManager = SongsManager();
        final currentSong = songsManager.currentSong;
        final upNext = [];
        if (songsManager.currentQueue.isNotEmpty &&
            songsManager.currentIndex >= 0 &&
            songsManager.currentIndex < songsManager.currentQueue.length - 1) {
          upNext.addAll(
            songsManager.currentQueue.sublist(songsManager.currentIndex + 1),
          );
        }

        return Scaffold(
          backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
          appBar: AppBar(
            title: const Text("Playing Queue"),
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Now Playing",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.music_note,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  currentSong?.title ?? "No Song is Playing...",
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: currentSong?.artist != null
                    ? Text(
                        currentSong!.artist!,
                        style: const TextStyle(color: Colors.white70),
                      )
                    : null,
                trailing: Icon(
                  Icons.equalizer,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Divider(color: Colors.white24, indent: 16, endIndent: 16),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "Up Next",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  itemCount: upNext.length,
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final item = upNext.removeAt(oldIndex);
                      upNext.insert(newIndex, item);
                      songsManager.reorderQueue(
                        songsManager.currentIndex + 1 + oldIndex,
                        songsManager.currentIndex + 1 + newIndex,
                      );
                    });
                  },
                  itemBuilder: (context, index) {
                    final songItem = upNext[index];
                    return ListTile(
                      key: ValueKey(songItem.id),
                      leading: Text(
                        "${index + 1}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      title: Text(
                        songItem.title,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: songItem.artist != null
                          ? Text(
                              songItem.artist!,
                              style: const TextStyle(color: Colors.white70),
                            )
                          : null,
                      trailing: const Icon(
                        Icons.drag_handle,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MusicProgressBar extends StatefulWidget {
  const MusicProgressBar({super.key});

  @override
  State<MusicProgressBar> createState() => _MusicProgressBarState();
}

class _MusicProgressBarState extends State<MusicProgressBar> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: AudioManager().positionStream,
      builder: (context, snapshot) {
        final totalDuration = AudioManager().totalDuration;
        final currentPosition = snapshot.data ?? Duration.zero;
        double max = totalDuration.inSeconds.toDouble();
        if (max <= 0) max = 1.0;
        double value = _isDragging
            ? _dragValue
            : currentPosition.inSeconds.toDouble();
        if (value > max) value = max;

        return Slider(
          min: 0,
          max: max,
          value: value,
          thumbColor: const Color.fromRGBO(255, 0, 0, 1),
          activeColor: const Color.fromRGBO(255, 0, 0, 1),
          inactiveColor: const Color.fromRGBO(255, 0, 0, 0.3),
          onChanged: (newValue) {
            setState(() {
              _isDragging = true;
              _dragValue = newValue;
            });
          },
          onChangeEnd: (newValue) {
            AudioManager().seek(Duration(seconds: newValue.toInt()));
            setState(() {
              _isDragging = false;
            });
          },
        );
      },
    );
  }
}

class BottomMusicController extends StatefulWidget {
  const BottomMusicController({super.key});

  @override
  State<BottomMusicController> createState() => BottomMusicControllerState();
}

class BottomMusicControllerState extends State<BottomMusicController> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SongsManager(),
      builder: (context, _) {
        final currentSong = SongsManager().currentSong;
        return GestureDetector(
          onTap: () => setState(() {
            setState(() {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 700),
                  pageBuilder: (context, animation, secondaryanimation) {
                    return const FullSizeMusicController();
                  },
                ),
              );
            });
          }),
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity > 0) {
              SongsManager().playPrevious();
            } else if (velocity < 0) {
              SongsManager().playNext();
            }
          },
          child: Container(
            alignment: Alignment.topCenter,
            width: double.infinity,
            height: 145,
            decoration: BoxDecoration(
              color: setContainerContrastColor(context),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Container(
                          width: 45,
                          height: 45,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(34, 34, 34, 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SvgPicture.asset(
                            "assets/MusicIcons/Vector-3.svg",
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.36,
                        child: Text(
                          currentSong == null
                              ? "No Song is Playing..."
                              : currentSong.title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color.fromRGBO(34, 34, 34, 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StreamBuilder<PlayerState>(
                          stream: AudioManager().instance.playerStateStream,
                          builder: (context, snapshot) {
                            final playing = snapshot.data?.playing ?? false;
                            return IconButton(
                              icon: SvgPicture.asset(
                                playing
                                    ? "assets/MusicIcons/Pause.svg"
                                    : "assets/MusicIcons/Play.svg",
                                color: const Color.fromRGBO(34, 34, 34, 1),
                                width: 25,
                                height: 25,
                              ),
                              onPressed: () {
                                playing
                                    ? AudioManager().pause()
                                    : AudioManager().resume();
                              },
                            );
                          },
                        ),
                        IconButton(
                          onPressed: () {
                            SongsManager().toggleRepeat();
                          },
                          icon: SvgPicture.asset(
                            "assets/MusicIcons/Loop.svg",
                            color: SongsManager().repeatMode.name != 'off'
                                ? Colors.red
                                : const Color.fromRGBO(34, 34, 34, 1),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            SongsManager().toggleShuffle();
                          },
                          icon: SvgPicture.asset(
                            "assets/MusicIcons/Shuffle.svg",
                            color: SongsManager().isShuffle
                                ? Colors.red
                                : const Color.fromRGBO(34, 34, 34, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CustomToggleSwitch extends StatefulWidget {
  const CustomToggleSwitch({super.key});

  @override
  State<CustomToggleSwitch> createState() => _CustomToggleSwitchState();
}

class _CustomToggleSwitchState extends State<CustomToggleSwitch> {
  bool isAudioSelected = false;

  @override
  Widget build(BuildContext context) {
    const double width = 300.0;
    const double height = 60.0;

    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: isAudioSelected
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: Container(
                width: width * 0.5,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isAudioSelected = true;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.transparent,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: isAudioSelected ? Colors.white : Colors.black,
                          fontFamily: 'Quicksand',
                        ),
                        child: const Text("Audio"),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isAudioSelected = false;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.transparent,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: isAudioSelected ? Colors.black : Colors.white,
                        ),
                        child: const Text("Video"),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

double i = 0;

class FullSizeMusicController extends StatefulWidget {
  const FullSizeMusicController({super.key});

  @override
  State<FullSizeMusicController> createState() =>
      _FullSizeMusicControllerState();
}

class _FullSizeMusicControllerState extends State<FullSizeMusicController> {
  late CurvedAnimation curved;
  bool isQueueOpen = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // curved.dispose(); // No controller passed to curved so removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SongsManager(),
      builder: (context, _) {
        final currentSong = SongsManager().currentSong;
        return LayoutBuilder(
          builder: (context, constraints) {
            return (constraints.maxWidth < 700)
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      return DefaultTabController(
                        length: 2,
                        child: Scaffold(
                          key: const ValueKey('displaySize<700'),
                          backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
                          extendBodyBehindAppBar: true,
                          extendBody: true,
                          bottomNavigationBar: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const MusicProgressBar(),
                              Container(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: 10,
                                  children: [
                                    IconButton(
                                      icon: SvgPicture.asset(
                                        "assets/MusicIcons/Shuffle.svg",
                                        color: SongsManager().isShuffle
                                            ? Colors.red
                                            : null,
                                        width: 20,
                                        height: 20,
                                      ),
                                      onPressed: () {
                                        SongsManager().toggleShuffle();
                                      },
                                    ),
                                    IconButton(
                                      icon: SvgPicture.asset(
                                        "assets/MusicIcons/PreviousButton.svg",
                                        width: 20,
                                        height: 20,
                                      ),
                                      onPressed: () {
                                        SongsManager().playPrevious();
                                      },
                                    ),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: const BoxDecoration(
                                            color: Color.fromRGBO(255, 0, 0, 1),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        StreamBuilder<PlayerState>(
                                          stream: AudioManager()
                                              .instance
                                              .playerStateStream,
                                          builder: (context, snapshot) {
                                            final playing =
                                                snapshot.data?.playing ?? false;
                                            return IconButton(
                                              icon: SvgPicture.asset(
                                                playing
                                                    ? "assets/MusicIcons/Pause.svg"
                                                    : "assets/MusicIcons/Play.svg",
                                                width: 20,
                                                height: 20,
                                              ),
                                              onPressed: () {
                                                playing
                                                    ? AudioManager().pause()
                                                    : AudioManager().resume();
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: SvgPicture.asset(
                                        "assets/MusicIcons/NextButton.svg",
                                        width: 20,
                                        height: 20,
                                      ),
                                      onPressed: () {
                                        SongsManager().playNext();
                                      },
                                    ),
                                    IconButton(
                                      icon: SvgPicture.asset(
                                        "assets/MusicIcons/Loop.svg",
                                        color:
                                            SongsManager().repeatMode.name !=
                                                'off'
                                            ? Colors.red
                                            : null,
                                        width: 20,
                                        height: 20,
                                      ),
                                      onPressed: () {
                                        SongsManager().toggleRepeat();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 15,
                                  bottom: 30,
                                ),
                                child: Builder(
                                  builder: (context) {
                                    return FilledButton.icon(
                                      icon: Icon(
                                        isQueueOpen
                                            ? Icons.close
                                            : Icons.queue_music,
                                        size: 15,
                                      ),
                                      onPressed: () {
                                        if (isQueueOpen) {
                                          Navigator.pop(context);
                                        } else {
                                          setState(() {
                                            isQueueOpen = true;
                                          });
                                          Scaffold.of(context)
                                              .showBottomSheet((context) {
                                                return ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.vertical(
                                                        top: Radius.circular(
                                                          20,
                                                        ),
                                                      ),
                                                  child: SizedBox(
                                                    height:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.height *
                                                        0.65,
                                                    child: MusicQueueScreen(
                                                      context: context,
                                                    ),
                                                  ),
                                                );
                                              })
                                              .closed
                                              .then((_) {
                                                if (mounted) {
                                                  setState(() {
                                                    isQueueOpen = false;
                                                  });
                                                }
                                              });
                                        }
                                      },
                                      label: Text(
                                        isQueueOpen ? "Close" : "Queue",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          appBar: AppBar(
                            surfaceTintColor: Colors.transparent,
                            backgroundColor: Colors.transparent,
                            leading: IconButton(
                              icon: SvgPicture.asset(
                                "assets/MusicIcons/DownArrow.svg",
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          body: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  top:
                                      MediaQuery.of(context).padding.top +
                                      kToolbarHeight,
                                  bottom: 180,
                                ),
                                child: AnimatedBuilder(
                                  animation: VideoManager(),
                                  builder: (context, _) {
                                    final isVideo =
                                        VideoManager().isVideoAvailable;
                                    return TabBarView(
                                      physics: isVideo
                                          ? const BouncingScrollPhysics()
                                          : const NeverScrollableScrollPhysics(),
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 5,
                                                      ),
                                                  child: IconButton(
                                                    icon: SvgPicture.asset(
                                                      "assets/MusicIcons/Like.svg",
                                                    ),
                                                    onPressed: () {},
                                                  ),
                                                ),
                                                Container(
                                                  height:
                                                      constraints.maxWidth *
                                                      0.35,
                                                  width:
                                                      constraints.maxWidth *
                                                      0.35,
                                                  constraints:
                                                      const BoxConstraints(
                                                        minHeight: 210,
                                                        minWidth: 210,
                                                        maxHeight: 300,
                                                        maxWidth: 300,
                                                      ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Color.fromRGBO(
                                                          255,
                                                          245,
                                                          245,
                                                          1,
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                  alignment: Alignment.center,
                                                  child: SvgPicture.asset(
                                                    "assets/MusicIcons/MusicLogo.svg",
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 5,
                                                      ),
                                                  child: IconButton(
                                                    icon: SvgPicture.asset(
                                                      "assets/MusicIcons/AddPlaylist.svg",
                                                    ),
                                                    onPressed: () {},
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                top: 20,
                                              ),
                                              child: Column(
                                                spacing: 3,
                                                children: [
                                                  const Text(
                                                    "Song:",
                                                    style: TextStyle(
                                                      color: Color.fromRGBO(
                                                        255,
                                                        245,
                                                        245,
                                                        1,
                                                      ),
                                                      fontSize: 14,
                                                      fontFamily: "Borel",
                                                    ),
                                                  ),
                                                  Text(
                                                    currentSong == null
                                                        ? "No Song is Playing..."
                                                        : currentSong.title,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: Color.fromRGBO(
                                                        255,
                                                        245,
                                                        245,
                                                        1,
                                                      ),
                                                      fontSize: 16,
                                                      fontFamily: "Borel",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        AnimatedBuilder(
                                          animation: VideoManager(),
                                          builder: (context, child) {
                                            final isAvailable =
                                                VideoManager().isVideoAvailable;
                                            final controller =
                                                VideoManager().controller;

                                            if (!isAvailable ||
                                                controller == null ||
                                                !controller
                                                    .value
                                                    .isInitialized) {
                                              return Container(
                                                color: Colors.black,
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  "No Video Available\nFor The Playing Media",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              );
                                            }

                                            return Center(
                                              child: AspectRatio(
                                                aspectRatio: controller
                                                    .value
                                                    .aspectRatio,
                                                child: VideoPlayer(controller),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 180,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 130,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                          225,
                                          225,
                                          225,
                                          1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          25.0,
                                        ),
                                      ),
                                      child: AnimatedBuilder(
                                        animation: VideoManager(),
                                        builder: (context, _) {
                                          final isVideo =
                                              VideoManager().isVideoAvailable;
                                          return TabBar(
                                            indicatorSize:
                                                TabBarIndicatorSize.tab,
                                            indicator: BoxDecoration(
                                              color: const Color.fromRGBO(
                                                34,
                                                34,
                                                34,
                                                1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(25.0),
                                            ),
                                            dividerColor: Colors.transparent,
                                            labelColor: Colors.white,
                                            unselectedLabelColor: Colors.black,
                                            splashBorderRadius:
                                                BorderRadius.circular(25.0),
                                            onTap: (index) {
                                              if (!isVideo && index == 1) {
                                                // Bounce back to Audio tab immediately
                                                DefaultTabController.of(
                                                  context,
                                                ).animateTo(0);
                                              }
                                            },
                                            tabs: [
                                              const Tab(
                                                child: Text(
                                                  "Audio",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              Tab(
                                                child: Opacity(
                                                  opacity: isVideo ? 1.0 : 0.4,
                                                  child: const Text(
                                                    "Video",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Builder(
                    builder: (context) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      });
                      return const SizedBox.shrink();
                    },
                  );
          },
        );
      },
    );
  }
}

class Home_Page_Rusic extends StatefulWidget {
  const Home_Page_Rusic({super.key});

  @override
  State<Home_Page_Rusic> createState() => Home_Page_Rusic_State();
}

class Home_Page_Rusic_State extends State<Home_Page_Rusic> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SongsManager(),
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.only(right: 20, left: 20),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.35 + 40,
            decoration: const BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              backgroundBlendMode: BlendMode.darken,
            ),
            child: (MediaQuery.of(context).size.width > 700)
                ? SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Container(
                            width: 250,
                            height: 200,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.music_note,
                              size: 80,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 40),
                            child: Container(
                              height: 200,
                              decoration: const BoxDecoration(
                                color: Colors.black45,
                                backgroundBlendMode: BlendMode.darken,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const MusicProgressBar(),
                                  SizedBox(
                                    width: 180,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.skip_previous,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                          onPressed: () {
                                            SongsManager().playPrevious();
                                          },
                                        ),
                                        StreamBuilder<PlayerState>(
                                          stream: AudioManager()
                                              .instance
                                              .playerStateStream,
                                          builder: (context, snapshot) {
                                            final playing =
                                                snapshot.data?.playing ?? false;
                                            return IconButton(
                                              icon: Icon(
                                                playing
                                                    ? Icons.pause_circle_filled
                                                    : Icons.play_circle_fill,
                                                size: 50,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                playing
                                                    ? AudioManager().pause()
                                                    : AudioManager().resume();
                                              },
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.skip_next,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                          onPressed: () {
                                            SongsManager().playNext();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 30,
                            right: 30,
                            top: 20,
                            bottom: 20,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  backgroundBlendMode: BlendMode.hardLight,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.music_note,
                                  size: 40,
                                  color: Colors.black,
                                ),
                              ),
                              const Expanded(child: MusicProgressBar()),
                              SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.skip_previous,
                                        color: Colors.white,
                                        size: 35,
                                      ),
                                      onPressed: () {
                                        SongsManager().playPrevious();
                                      },
                                    ),
                                    StreamBuilder<PlayerState>(
                                      stream: AudioManager()
                                          .instance
                                          .playerStateStream,
                                      builder: (context, snapshot) {
                                        final playing =
                                            snapshot.data?.playing ?? false;
                                        return IconButton(
                                          alignment: Alignment.center,
                                          icon: Icon(
                                            playing
                                                ? Icons.pause_circle_filled
                                                : Icons.play_circle_fill,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                          color: Colors.white,
                                          iconSize: 40,
                                          onPressed: () {
                                            playing
                                                ? AudioManager().pause()
                                                : AudioManager().resume();
                                          },
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.skip_next,
                                        color: Colors.white,
                                        size: 35,
                                      ),
                                      onPressed: () {
                                        SongsManager().playNext();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class SideMusicController extends StatefulWidget {
  const SideMusicController({super.key});

  @override
  State<SideMusicController> createState() => SideMusicControllerState();
}

class SideMusicControllerState extends State<SideMusicController> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SongsManager(),
      builder: (context, _) {
        final currentSong = SongsManager().currentSong;
        return Stack(
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: const WeatherBackground(),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 15,
              children: [
                Container(
                  width: 170,
                  height: 170,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.music_note,
                    size: 60,
                    color: Colors.black,
                  ),
                ),
                Text(
                  currentSong == null
                      ? "No Song is Playing..."
                      : currentSong.title,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const MusicProgressBar(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            SongsManager().toggleRepeat();
                          },
                          icon: Icon(
                            Icons.repeat,
                            size: 35,
                            color: SongsManager().repeatMode.name != 'off'
                                ? Colors.red
                                : Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            SongsManager().playPrevious();
                          },
                          icon: const Icon(
                            Icons.skip_previous,
                            size: 35,
                            color: Colors.white,
                          ),
                        ),
                        StreamBuilder<PlayerState>(
                          stream: AudioManager().instance.playerStateStream,
                          builder: (context, snapshot) {
                            final playing = snapshot.data?.playing ?? false;
                            return IconButton(
                              onPressed: () {
                                playing
                                    ? AudioManager().pause()
                                    : AudioManager().resume();
                              },
                              icon: Icon(
                                playing
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_fill,
                                color: Colors.white,
                                size: 40,
                              ),
                              color: Colors.black,
                            );
                          },
                        ),
                        IconButton(
                          onPressed: () {
                            SongsManager().playNext();
                          },
                          icon: const Icon(
                            Icons.skip_next,
                            size: 35,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            SongsManager().toggleShuffle();
                          },
                          icon: Icon(
                            Icons.shuffle,
                            size: 35,
                            color: SongsManager().isShuffle
                                ? Colors.red
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
