import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:music_controller/main.dart';
import 'package:music_controller/settings/settings.dart';
import 'package:music_controller/music_player/dynamic_background.dart';
import 'package:music_controller/managers/audio_manager.dart';

// play and pause button variable declaration
int indicatorState = 0;

bool _isDragging = false;
double _dragValue = 0.0;

//Audio Playing feature variables and functions
String audio_path = "";
final manager = AudioManager();
Future<void> audioPlayAndPauseFunction() async {
  if (audio_path.isNotEmpty) {
    // 1. Get the manager

    // 2. Check: Is this the same song that is currently loaded?
    if (manager.currentSongPath == audio_path) {
      // It is the same song. Toggle Play/Pause.
      if (manager.instance.playing) {
        await manager.pause();
      } else {
        await manager.resume();
      }
    } else {
      // 3. It is a DIFFERENT song. Play it immediately.
      await manager.play(audio_path);
    }
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
      stream: AudioManager()
          .positionStream, // Listen to the "Heartbeat" of the player
      builder: (context, snapshot) {
        // 2. Get the Real-Time Data
        final totalDuration = AudioManager().totalDuration;
        final currentPosition = snapshot.data ?? Duration.zero;

        // 3. Safety Check: If song hasn't loaded, max might be 0. Avoid crash.
        double max = totalDuration.inSeconds.toDouble();
        if (max <= 0) max = 1.0;

        // 4. Determine Slider Value
        // If user is dragging, use their finger position (_dragValue).
        // If music is playing, use the song position (currentPosition).
        double value = _isDragging
            ? _dragValue
            : currentPosition.inSeconds.toDouble();

        // Clamp ensures value never exceeds max (prevents "Value > Max" crash)
        if (value > max) value = max;

        return Slider(
          min: 0,
          max: max,
          value: value,

          // COLORS
          thumbColor: const Color.fromRGBO(255, 0, 0, 1),
          activeColor: const Color.fromRGBO(255, 0, 0, 1),
          inactiveColor: const Color.fromRGBO(
            255,
            0,
            0,
            0.3,
          ), // Faded red for background
          // LOGIC
          onChanged: (newValue) {
            setState(() {
              _isDragging = true; // Stop the stream from fighting the user
              _dragValue = newValue;
            });
          },

          onChangeEnd: (newValue) {
            // Only seek when the user LETS GO of the slider
            AudioManager().seek(Duration(seconds: newValue.toInt()));

            setState(() {
              _isDragging = false; // Let the stream take over again
            });
          },
        );
      },
    );
  }
}

//Bottom Music Controller
class Bottom_Music_Controller extends StatefulWidget {
  const Bottom_Music_Controller({super.key});

  @override
  State<Bottom_Music_Controller> createState() =>
      Bottom_Music_Controller_State();
}

class Bottom_Music_Controller_State extends State<Bottom_Music_Controller> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        setState(() {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 700),
              pageBuilder: (context, animation, secondaryanimation) {
                return Full_Size_Music_Controller();
              },
            ),
          );
        });
      }),
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          print("Previous Song");
          // Swiped Right
        } else if (details.primaryVelocity! < 0) {
          print("Next Song");
          // Swiped Left
        }
      },
      child: Container(
        alignment: Alignment.topCenter,
        width: double.infinity,
        height: 65,
        decoration: BoxDecoration(
          color: setContainerContrastColor(context),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 10),
                    child: Container(
                      width: 45,
                      height: 45,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(34, 34, 34, 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SvgPicture.asset("assets/MusicIcons/Vector-3.svg"),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Text(
                      audio_path == ''
                          ? "No Song is Playing..."
                          : audio_path.split(Platform.pathSeparator).last,
                      // maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Color.fromRGBO(34, 34, 34, 1)),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: [
                        SvgPicture.asset(
                          "assets/MusicIcons/Play.svg",
                          color: Color.fromRGBO(34, 34, 34, 1),
                          width: 25,
                          height: 25,
                        ),
                        SvgPicture.asset(
                          "assets/MusicIcons/Pause.svg",
                          color: Color.fromRGBO(34, 34, 34, 1),
                          width: 25,
                          height: 25,
                        ),
                      ][indicatorState],
                      onPressed: () {
                        if (indicatorState == 0) {
                          setState(() {
                            audioPlayAndPauseFunction();
                            indicatorState = 1;
                          });
                        } else {
                          setState(() {
                            audioPlayAndPauseFunction();
                            indicatorState = 0;
                          });
                        }
                      },
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        "assets/MusicIcons/Loop.svg",
                        color: Color.fromRGBO(34, 34, 34, 1),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        "assets/MusicIcons/Shuffle.svg",
                        color: Color.fromRGBO(34, 34, 34, 1),
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
  }
}

class CustomToggleSwitch extends StatefulWidget {
  const CustomToggleSwitch({super.key});

  @override
  State<CustomToggleSwitch> createState() => _CustomToggleSwitchState();
}

class _CustomToggleSwitchState extends State<CustomToggleSwitch> {
  // 1. Tracks which side is selected (true = Audio, false = Video)
  bool isAudioSelected = false;

  @override
  Widget build(BuildContext context) {
    // Define the size of the widget
    const double width = 300.0;
    const double height = 60.0;

    return Center(
      child: Container(
        width: width,
        height: height,
        // 2. The Light Grey Background Pill
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(
            50.0,
          ), // High radius for pill shape
        ),
        child: Stack(
          children: [
            // 3. The Sliding Black Oval (The Indicator)
            AnimatedAlign(
              alignment: isAudioSelected
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              duration: const Duration(milliseconds: 250), // Animation speed
              curve: Curves.easeInOut, // Smooth sliding curve
              child: Container(
                width: width * 0.5, // Takes up 50% of the width
                height: height,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
            ),

            // 4. The Text Buttons (Transparent click detectors)
            Row(
              children: [
                // Audio Button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isAudioSelected = true;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.transparent, // Important for tap detection
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          // 5. Change Text Color based on selection
                          color: isAudioSelected ? Colors.white : Colors.black,
                          fontFamily:
                              'Quicksand', // Use a custom font if you have one
                        ),
                        child: const Text("Audio"),
                      ),
                    ),
                  ),
                ),

                // Video Button
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
                          // Change Text Color based on selection
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

// Full Sized Music Controller
class Full_Size_Music_Controller extends StatefulWidget {
  const Full_Size_Music_Controller({super.key});

  @override
  State<Full_Size_Music_Controller> createState() =>
      Full_Size_Music_Controller_State();
}

class Full_Size_Music_Controller_State
    extends State<Full_Size_Music_Controller> {
  late CurvedAnimation curved;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    curved.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(26, 26, 26, 1),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 250),
            reverseDuration: Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeInQuad,
                reverseCurve: Curves.easeOutQuad,
              );

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, 1),
                    end: Offset.zero,
                  ).animate(curved),
                  child: ScaleTransition(
                    scale: Tween(begin: 0.3, end: 1.0).animate(curved),
                    child: child,
                  ),
                ),
              );
            },
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            child: (constraints.maxWidth < 700)
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      return Scaffold(
                        key: ValueKey('displaySize<700'),
                        backgroundColor: Color.fromRGBO(26, 26, 26, 1),
                        appBar: AppBar(
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
                        floatingActionButtonLocation:
                            FloatingActionButtonLocation.centerFloat,
                        floatingActionButton: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: 240,
                                maxWidth: 300,
                              ),
                              child: SizedBox(
                                height: 60,
                                width: 100 * 0.5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(34, 34, 34, 1),
                                  ),
                                  child: BottomNavigationBar(
                                    landscapeLayout:
                                        BottomNavigationBarLandscapeLayout
                                            .centered,
                                    type: BottomNavigationBarType.fixed,
                                    items: bottomNavigationBarItems,
                                    currentIndex: navigationIndex,
                                    onTap: (value) {
                                      navigationIndex = value;
                                      setState(() {
                                        Navigator.pop(context);
                                      });
                                    },
                                    showUnselectedLabels: false,
                                    showSelectedLabels: false,
                                    backgroundColor: Color.fromRGBO(
                                      34,
                                      34,
                                      34,
                                      1,
                                    ),
                                    unselectedItemColor: Colors.white,
                                    selectedItemColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        body: Padding(
                          padding: EdgeInsets.only(
                            top: constraints.maxHeight * 0.10,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: IconButton(
                                      icon: SvgPicture.asset(
                                        "assets/MusicIcons/Like.svg",
                                      ),
                                      onPressed: () {},
                                    ),
                                  ),
                                  Container(
                                    height: constraints.maxWidth * 0.35,
                                    width: constraints.maxWidth * 0.35,
                                    constraints: BoxConstraints(
                                      minHeight: 210,
                                      minWidth: 210,
                                      maxHeight: 300,
                                      maxWidth: 300,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(255, 245, 245, 1),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: SvgPicture.asset(
                                      "assets/MusicIcons/MusicLogo.svg",
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
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
                                padding: const EdgeInsets.only(top: 20),
                                child: Column(
                                  spacing: 3,
                                  children: [
                                    Text(
                                      "Song:",
                                      style: TextStyle(
                                        color: Color.fromRGBO(255, 245, 245, 1),
                                        fontSize: 14,
                                        fontFamily: "Borel",
                                      ),
                                    ),
                                    Text(
                                      audio_path == ''
                                          ? "No Song is Playing..."
                                          : audio_path
                                                .split(Platform.pathSeparator)
                                                .last,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color.fromRGBO(255, 245, 245, 1),
                                        fontSize: 16,
                                        fontFamily: "Borel",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(top: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MusicProgressBar(),
                                    Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        spacing: 10,
                                        children: [
                                          IconButton(
                                            icon: SvgPicture.asset(
                                              "assets/MusicIcons/Shuffle.svg",
                                              width: 20,
                                              height: 20,
                                            ),
                                            onPressed: () {},
                                          ),
                                          IconButton(
                                            icon: SvgPicture.asset(
                                              "assets/MusicIcons/PreviousButton.svg",
                                              width: 20,
                                              height: 20,
                                            ),
                                            onPressed: () {},
                                          ),
                                          Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: Color.fromRGBO(
                                                    255,
                                                    0,
                                                    0,
                                                    1,
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              IconButton(
                                                icon: [
                                                  SvgPicture.asset(
                                                    "assets/MusicIcons/Play.svg",
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                                  SvgPicture.asset(
                                                    "assets/MusicIcons/Pause.svg",
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                                ][indicatorState],
                                                onPressed: () {
                                                  if (indicatorState == 0) {
                                                    setState(() {
                                                      audioPlayAndPauseFunction();
                                                      indicatorState = 1;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      audioPlayAndPauseFunction();
                                                      indicatorState = 0;
                                                    });
                                                  }
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
                                            onPressed: () {},
                                          ),
                                          IconButton(
                                            icon: SvgPicture.asset(
                                              "assets/MusicIcons/Loop.svg",
                                              width: 20,
                                              height: 20,
                                            ),
                                            onPressed: () {},
                                          ),
                                        ],
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
                : Scaffold(
                    key: ValueKey('displaySize>700'),
                    backgroundColor: Colors.amberAccent,
                  ),
          );
        },
      ),
    );
  }
}

class Home_Page_Music_Controller extends StatefulWidget {
  const Home_Page_Music_Controller({super.key});

  @override
  State<Home_Page_Music_Controller> createState() =>
      Home_Page_Music_Controller_State();
}

class Home_Page_Music_Controller_State
    extends State<Home_Page_Music_Controller> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      initialData: {"mode": true, "bgstatus": "PowerSaving Mode"},
      future: FileSettings,
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.only(right: 20, left: 20),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.35 + 40,
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              backgroundBlendMode: BlendMode.darken,
            ),
            child: (MediaQuery.of(context).size.width > 700)
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Container(
                            width: 250,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(
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
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                backgroundBlendMode: BlendMode.darken,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MusicProgressBar(),
                                  Container(
                                    width: 180,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.skip_previous,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                          onPressed: () {},
                                        ),
                                        IconButton(
                                          icon: [
                                            Icon(
                                              Icons.play_circle_fill,
                                              size: 50,
                                              color: Colors.white,
                                            ),
                                            Icon(
                                              Icons.pause_circle_filled,
                                              size: 50,
                                              color: Colors.white,
                                            ),
                                          ][indicatorState],
                                          onPressed: () {
                                            if (indicatorState == 0) {
                                              setState(() {
                                                audioPlayAndPauseFunction();
                                                indicatorState = 1;
                                              });
                                            } else {
                                              setState(() {
                                                audioPlayAndPauseFunction();
                                                indicatorState = 0;
                                              });
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.skip_next,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                          onPressed: () {},
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
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  backgroundBlendMode: BlendMode.hardLight,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                child: Icon(
                                  Icons.music_note,
                                  size: 40,
                                  color: Colors.black,
                                ),
                              ),
                              Expanded(child: MusicProgressBar()),
                              Container(
                                height: 50,
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.skip_previous,
                                        color: Colors.white,
                                        size: 35,
                                      ),
                                      onPressed: () => {},
                                    ),
                                    IconButton(
                                      alignment: Alignment.center,
                                      icon: [
                                        Icon(
                                          Icons.play_circle_fill,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                        Icon(
                                          Icons.pause_circle_filled,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ][indicatorState],
                                      color: (snapshot.data!['mode'] == true)
                                          ? Colors.white
                                          : Colors.black,
                                      iconSize: 40,
                                      onPressed: () {
                                        if (indicatorState == 1) {
                                          setState(() {
                                            audioPlayAndPauseFunction();
                                            indicatorState = 0;
                                          });
                                        } else {
                                          setState(() {
                                            audioPlayAndPauseFunction();
                                            indicatorState = 1;
                                          });
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.skip_next,
                                        color: Colors.white,
                                        size: 35,
                                      ),
                                      onPressed: () => {},
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
    return Stack(
      // alignment: AlignmentDirectional.center,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: WeatherBackground(),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 15,
          children: [
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.white,
              ),
              child: Icon(
                Icons.music_note,
                size: 60,
                color: Colors.black,
              ),
            ),
            Text(
              audio_path == ''
                  ? "No Song is Playing..."
                  : audio_path.split(Platform.pathSeparator).last,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MusicProgressBar(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (indicatorState == 1) {
                          setState(() {
                            audioPlayAndPauseFunction();
                            indicatorState = 0;
                          });
                        } else {
                          setState(() {
                            audioPlayAndPauseFunction();
                            indicatorState = 1;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.repeat,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.skip_previous,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (indicatorState == 1) {
                          setState(() {
                            audioPlayAndPauseFunction();
                            indicatorState = 0;
                          });
                        } else {
                          setState(() {
                            audioPlayAndPauseFunction();
                            indicatorState = 1;
                          });
                        }
                      },
                      icon: [
                        Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 40,
                        ),
                        Icon(
                          Icons.pause_circle_filled,
                          color: Colors.white,
                          size: 40,
                        ),
                      ][indicatorState],
                      color: 
                           Colors.black,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.skip_next,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.shuffle,
                        size: 35,
                        color: Colors.white,
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
  }
}
