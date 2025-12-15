import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:music_controller/Settings/Settings_UI.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:music_controller/Music Player/HomePage_Components.dart';

// play and pause button variable declaration
int indicatorState = 0;

//Audio Playing feature variables and functions
final AudioPlayer player = AudioPlayer();
String audio_path = "";
Future<void> audioPlayAndPauseFunction() async {
  if (audio_path.isNotEmpty) {
    if (player.state == PlayerState.playing) {
      player.pause();
    } else {
      await player.play(DeviceFileSource(audio_path));
    }
  }
}

Future<List<double?>> SliderFunction() async {
  if (await player.getDuration() != null) {
    return [
      (await player.getDuration())?.inSeconds.toDouble(),
      (await player.getCurrentPosition())?.inSeconds.toDouble(),
    ];
  } else {
    return [0.0, 0.0];
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
  double bmch = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        bmch = 65;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      initialData: {"mode": true, "bgstatus": "PowerSaving Mode"},
      future: FileSettings,
      builder: (context, snapshot) {
        if (snapshot.hasData == true) {
          return GestureDetector(
            onTap: () => setState(() {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 700),
                  pageBuilder: (context, animation, secondaryanimation) {
                    return Full_Size_Music_Controller();
                  },
                ),
              );
            }),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.slowMiddle,
              alignment: Alignment.topCenter,
              width: double.infinity,
              height: bmch,
              decoration: BoxDecoration(
                color: (snapshot.data!['mode'] == true)
                    ? Color.fromARGB(215, 255, 255, 255)
                    : Colors.black,
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
                          child: Hero(
                            tag: 'music_icon',
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: (snapshot.data!['mode'] == true)
                                    ? Colors.black
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.music_note,
                                size: 25,
                                color: snapshot.data!['mode'] == true
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),

                        Text(
                          audio_path == ''
                              ? "No Song is Playing..."
                              : audio_path.split(Platform.pathSeparator).last,
                          style: TextStyle(
                            color: (snapshot.data!['mode'] == true)
                                ? Colors.black
                                : Colors.white,
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
                              Icon(
                                Icons.play_arrow,
                                size: 40,
                                color: (snapshot.data!['mode'] == true)
                                    ? Colors.black
                                    : Colors.white,
                              ),
                              Icon(
                                Icons.pause,
                                size: 40,
                                color: (snapshot.data!['mode'] == true)
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ][indicatorState],
                            color: (snapshot.data!['mode'] == true)
                                ? Colors.black
                                : Colors.white,
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
                            icon: Icon(
                              Icons.repeat,
                              size: 40,
                              color: (snapshot.data!['mode'] == true)
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.shuffle,
                              size: 40,
                              color: (snapshot.data!['mode'] == true)
                                  ? Colors.black
                                  : Colors.white,
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
        } else {
          return CircularProgressIndicator(color: Colors.redAccent);
        }
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
                        backgroundColor: Color.fromRGBO(26, 26, 26, 1),
                        key: ValueKey('displaySize<700'),
                        body: Padding(
                          padding: EdgeInsets.only(
                            top: constraints.maxHeight * 0.15,
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
                                      "Playing...",
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
                                    Slider(
                                      min: 0,
                                      max: 100,
                                      thumbColor: Color.fromRGBO(255, 0, 0, 1),
                                      value: i,
                                      activeColor: Color.fromRGBO(255, 0, 0, 1),
                                      onChanged: (value) {
                                        setState(() {
                                          i = value;
                                        });
                                      },
                                    ),
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
                                                icon: SvgPicture.asset(
                                                  "assets/MusicIcons/Play.svg",
                                                  width: 20,
                                                  height: 20,
                                                ),
                                                onPressed: () {},
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
              color: (snapshot.data!['mode'] == true)
                  ? Colors.black45
                  : Colors.white38,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              backgroundBlendMode: (snapshot.data!['mode'] == true)
                  ? BlendMode.darken
                  : BlendMode.hardLight,
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
                              color: (snapshot.data!['mode'] == true)
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            child: Icon(
                              Icons.music_note,
                              size: 80,
                              color: (snapshot.data!['mode'] == true)
                                  ? Colors.black
                                  : Colors.white,
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
                                color: (snapshot.data!['mode'] == true)
                                    ? Colors.black45
                                    : Colors.white38,
                                backgroundBlendMode:
                                    (snapshot.data!['mode'] == true)
                                    ? BlendMode.darken
                                    : BlendMode.hardLight,

                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FutureBuilder(
                                    future: SliderFunction(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Slider(
                                          value: snapshot.data![1]!.toDouble(),
                                          min: 0,
                                          max: snapshot.data![0]!.toDouble(),
                                          thumbColor: Colors.white,
                                          onChanged: (value) {
                                            setState(() {
                                              i = value;
                                            });
                                          },
                                          activeColor: Colors.redAccent,
                                          inactiveColor: Colors.white,
                                        );
                                      } else {
                                        return Slider(
                                          value: i,
                                          min: 0,
                                          max: snapshot.data![0]!.toDouble(),
                                          thumbColor: Colors.white,
                                          onChanged: (value) {
                                            setState(() {
                                              i = value;
                                            });
                                          },
                                          activeColor: Colors.redAccent,
                                          inactiveColor: Colors.white,
                                        );
                                      }
                                    },
                                  ),
                                  Container(
                                    width: 180,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.skip_previous,
                                            color:
                                                (snapshot.data!['mode'] == true)
                                                ? Colors.white
                                                : Colors.black,
                                            size: 40,
                                          ),
                                          onPressed: () {},
                                        ),
                                        IconButton(
                                          icon: [
                                            Icon(
                                              Icons.play_circle_fill,
                                              size: 50,
                                              color:
                                                  (snapshot.data!['mode'] ==
                                                      true)
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            Icon(
                                              Icons.pause_circle_filled,
                                              size: 50,
                                              color:
                                                  (snapshot.data!['mode'] ==
                                                      true)
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ][indicatorState],
                                          onPressed: () {
                                            if (indicatorState == 0) {
                                              setState(() {
                                                player.resume();
                                                indicatorState = 1;
                                              });
                                            } else {
                                              setState(() {
                                                player.pause();
                                                indicatorState = 0;
                                              });
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.skip_next,
                                            color:
                                                (snapshot.data!['mode'] == true)
                                                ? Colors.white
                                                : Colors.black,
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
                                  color: (snapshot.data!['mode'] == true)
                                      ? Colors.white
                                      : Colors.black,
                                  shape: BoxShape.rectangle,
                                  backgroundBlendMode: BlendMode.hardLight,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                child: Icon(
                                  Icons.music_note,
                                  size: 40,
                                  color: (snapshot.data!['mode'] == true)
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  thumbColor: Colors.white,
                                  activeColor: Colors.redAccent,
                                  min: 0,
                                  max: 100,
                                  value: i,
                                  onChanged: (value) {
                                    setState(() {
                                      i = value;
                                    });
                                  },
                                ),
                              ),
                              Container(
                                height: 50,
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.skip_previous,
                                        color: (snapshot.data!['mode'] == true)
                                            ? Colors.white
                                            : Colors.black,
                                        size: 35,
                                      ),
                                      onPressed: () => {},
                                    ),
                                    IconButton(
                                      alignment: Alignment.center,
                                      icon: [
                                        Icon(
                                          Icons.play_circle_fill,
                                          color:
                                              (snapshot.data!['mode'] == true)
                                              ? Colors.white
                                              : Colors.black,
                                          size: 40,
                                        ),
                                        Icon(
                                          Icons.pause_circle_filled,
                                          color:
                                              (snapshot.data!['mode'] == true)
                                              ? Colors.white
                                              : Colors.black,
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
                                        color: (snapshot.data!['mode'] == true)
                                            ? Colors.white
                                            : Colors.black,
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

class SideBar_Music_Controller extends StatefulWidget {
  const SideBar_Music_Controller({super.key});

  @override
  State<SideBar_Music_Controller> createState() =>
      SideBar_Music_Controller_State();
}

class SideBar_Music_Controller_State extends State<SideBar_Music_Controller> {
  double sbmcw = -350;

  @override
  void initState() {
    super.initState();
    // Animate sidebar in after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        sbmcw = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      initialData: {"mode": true, "bgstatus": "PowerSaving Mode"},
      future: FileSettings,
      builder: (context, snapshot) {
        return SizedBox(
          width: 350,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            // alignment: AlignmentDirectional.center,
            children: [
              AnimatedPositioned(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
                right: sbmcw,
                child: SizedBox(
                  width: 350, // match parent Container width
                  height: MediaQuery.of(
                    context,
                  ).size.height, // match parent Container height
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Background_Dynamic_Theme(),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
                right: sbmcw,
                child: SizedBox(
                  width: 350,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 15,
                    children: [
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: snapshot.data!['mode'] == true
                              ? Colors.white
                              : Colors.black,
                        ),
                        child: Icon(
                          Icons.music_note,
                          size: 60,
                          color: snapshot.data!['mode'] == true
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                      Text(
                        audio_path == ''
                            ? "No Song is Playing..."
                            : audio_path.split(Platform.pathSeparator).last,
                        style: TextStyle(
                          color: snapshot.data!['mode'] == true
                              ? Colors.white
                              : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FutureBuilder(
                            future: SliderFunction(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData != [null, null]) {
                                return Slider(
                                  value: snapshot.data![1]!.toDouble(),
                                  min: 0,
                                  max: snapshot.data![0]!.toDouble(),
                                  thumbColor: Colors.white,
                                  onChanged: (value) {
                                    setState(() {
                                      player.seek(
                                        Duration(seconds: value.toInt()),
                                      );
                                    });
                                  },
                                  activeColor: Colors.redAccent,
                                  inactiveColor: Colors.white,
                                );
                              } else {
                                return Slider(
                                  value: 0,
                                  min: 0,
                                  max: 1,
                                  thumbColor: Colors.white,
                                  onChanged: null,
                                  activeColor: Colors.redAccent,
                                  inactiveColor: Colors.white,
                                );
                              }
                            },
                          ),
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
                                  color: snapshot.data!['mode'] == true
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.skip_previous,
                                  size: 35,
                                  color: snapshot.data!['mode'] == true
                                      ? Colors.white
                                      : Colors.black,
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
                                    color: (snapshot.data!['mode'] == true)
                                        ? Colors.white
                                        : Colors.black,
                                    size: 40,
                                  ),
                                  Icon(
                                    Icons.pause_circle_filled,
                                    color: (snapshot.data!['mode'] == true)
                                        ? Colors.white
                                        : Colors.black,
                                    size: 40,
                                  ),
                                ][indicatorState],
                                color: (snapshot.data!['mode'] == true)
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.skip_next,
                                  size: 35,
                                  color: snapshot.data!['mode'] == true
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.shuffle,
                                  size: 35,
                                  color: snapshot.data!['mode'] == true
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
