import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Rusic/music_player/music_controller.dart';
import "package:window_size/window_size.dart";
import 'music_player/music_player.dart';
import 'settings/settings.dart';
import 'search/search_page.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:Rusic/managers/settings_manager.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

Future<void> main() async {
  // Initialize JustAudioMediaKit And Flutter Bindings
  JustAudioMediaKit.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  SettingsManager.init();

  // Request Android permissions early (Android 11+)
  if (Platform.isAndroid) {
    // Request READ_EXTERNAL_STORAGE first (more reliable than MANAGE_EXTERNAL_STORAGE)
    PermissionStatus readStatus = await Permission.storage.request();
    print('Storage permission status after request: $readStatus');

    // Also try MANAGE_EXTERNAL_STORAGE for broader access
    PermissionStatus manageStatus = await Permission.manageExternalStorage
        .request();
    print('Manage external storage permission status: $manageStatus');
  }

  // Custom Error Widget
  // ErrorWidget.builder = (FlutterErrorDetails details) {
  //   return Center(child: CircularProgressIndicator(color: Colors.redAccent));
  // };

  // Initialize Supabase
  final supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  final supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

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
List<Widget> bottomNavigationBarItems = [
  Padding(padding: const EdgeInsets.all(7.0), child: Icon(Icons.search)),
  Padding(padding: const EdgeInsets.all(7.0), child: Icon(Icons.library_music)),
  Padding(padding: const EdgeInsets.all(7.0), child: Icon(Icons.settings)),
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
      title: "Rusic",
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
              children: const [Search(), Library(), Settings()],
            ),
          ),
          SizedBox(
            width: 350,
            height: double.infinity,
            child: SideMusicController(),
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
      backgroundColor: Colors.transparent,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: CurvedNavigationBar(
        color: Color.fromRGBO(34, 34, 34, 0.85),
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Theme.of(context).colorScheme.primary,
        height: 70,
        animationDuration: Duration(milliseconds: 300),
        animationCurve: Curves.linearToEaseOut,
        index: 1,
        items: bottomNavigationBarItems,
        onTap: (index) {
          setState(() {
            navigationIndex = index;
          });
        },
      ),
      body: IndexedStack(
        index: navigationIndex,
        children: const [Search(), Library(), Settings()],
      ),
    );
  }
}
