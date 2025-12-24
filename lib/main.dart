import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_controller/Music Player/Music_Controller.dart';
import "package:window_size/window_size.dart";
import 'Music Player/Music_Player.dart';
import 'Settings/Settings_UI.dart';
import 'Search/Search_Page.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Initialize JustAudioMediaKit And Flutter Bindings
  JustAudioMediaKit.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  // Custom Error Widget
  // ErrorWidget.builder = (FlutterErrorDetails details) {
  //   return Center(child: CircularProgressIndicator(color: Colors.redAccent));
  // };

  // Initialize Supabase
  await Supabase.initialize(
    url: String.fromEnvironment(
      'SUPABASE_URL',
    ), // Found in Project Settings -> API
    anonKey: String.fromEnvironment(
      'SUPABASE_ANON_KEY',
    ), // Found in Project Settings -> API
  );

  // Set Preferred Orientations and System UI Mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  // Set Window Size Constraints for Desktop Platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(Size(500, 1005)); //logical width height
    setWindowMaxSize(Size(10000, 10000)); //logical width height
  }

  runApp(const MxMusicConsole());
}

//index for Navigation Bar
int navigationIndex = 1;

// Bottom Navigation Bar Items
const List<BottomNavigationBarItem> bottomNavigationBarItems = [
  BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
  BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Home'),
  BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
];

// Navigation Rail Destinations
const List<NavigationRailDestination> navigationRailDestinationsItems = [
  NavigationRailDestination(
    icon: Icon(Icons.search),
    selectedIcon: Icon(Icons.search),
    label: Text("Search"),
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.library_music),
    label: Text("Home"),
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  NavigationRailDestination(
    icon: Icon(Icons.settings),
    label: Text("Settings"),
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
];

class MxMusicConsole extends StatefulWidget {
  const MxMusicConsole({super.key});

  @override
  State<MxMusicConsole> createState() => MxMusicConsoleState();
}

class MxMusicConsoleState extends State<MxMusicConsole> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MxMusicConsole",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Asimovian',
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black),
          bodyLarge: TextStyle(color: Colors.black),
          bodySmall: TextStyle(color: Colors.black),
          displayLarge: TextStyle(color: Colors.black),
          displayMedium: TextStyle(color: Colors.black),
          displaySmall: TextStyle(color: Colors.black),
          headlineLarge: TextStyle(color: Colors.black),
          headlineMedium: TextStyle(color: Colors.black),
          headlineSmall: TextStyle(color: Colors.black),
          titleLarge: TextStyle(color: Colors.black87),
          titleMedium: TextStyle(color: Colors.black87),
          titleSmall: TextStyle(color: Colors.black87),
        ),
      ),
      darkTheme: ThemeData(
        fontFamily: 'Asimovian',
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: Colors.redAccent,
        ),
        brightness: Brightness.dark,
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
          bodyLarge: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
          bodySmall: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
          displayLarge: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
          displayMedium: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
          displaySmall: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
          headlineLarge: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
          headlineMedium: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
          headlineSmall: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
          titleLarge: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
          titleMedium: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
          titleSmall: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
        ),
      ),
      themeMode: ThemeMode.system,
      home: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth <= 700) {
            return CompactScreen();
          } else {
            return WideScreen();
          }
        },
      ),
    );
  }
}

// Wide Screen Layout for larger displays
class WideScreen extends StatefulWidget {
  const WideScreen({super.key});

  @override
  State<WideScreen> createState() => WideScreenState();
}

class WideScreenState extends State<WideScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            // extended: true,
            destinations: navigationRailDestinationsItems,
            groupAlignment: 0,
            backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
            labelType: NavigationRailLabelType.selected,
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            selectedIndex: navigationIndex,
            onDestinationSelected: (value) => setState(() {
              navigationIndex = value;
            }),
          ),
          VerticalDivider(
            color: Color.fromRGBO(255, 245, 245, 0.3),
            thickness: 0.5,
            width: 0.5,
          ),
          Expanded(
            child: IndexedStack(
              index: navigationIndex,
              children: const [Search_Page(), Home_Page(), Settings_UI()],
            ),
          ),
        ],
      ),
    );
  }
}

// Compact Screen Layout for smaller displays
class CompactScreen extends StatefulWidget {
  const CompactScreen({super.key});

  @override
  State<CompactScreen> createState() => CompactScreenState();
}

class CompactScreenState extends State<CompactScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 60,
            width: 240,
            decoration: BoxDecoration(color: Color.fromRGBO(34, 34, 34, 1)),
            child: BottomNavigationBar(
              landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
              type: BottomNavigationBarType.fixed,
              items: bottomNavigationBarItems,
              currentIndex: navigationIndex,
              onTap: (value) => setState(() {
                navigationIndex = value;
              }),
              backgroundColor: Color.fromRGBO(34, 34, 34, 1),
              showUnselectedLabels: false,
              unselectedItemColor: Colors.white,
              selectedItemColor: Colors.red,
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: navigationIndex,
        children: const [Search_Page(), Home_Page(), Settings_UI()],
      ),
    );
  }
}
