import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Rusic/music_player/music_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import "package:window_size/window_size.dart";
import 'music_player/music_player.dart';
import 'settings/settings.dart';
import 'search/search_page.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:Rusic/managers/settings_manager.dart';
import 'package:toastification/toastification.dart';

Future<void> main() async {
  // Initialize JustAudioMediaKit And Flutter Bindings
  JustAudioMediaKit.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  SettingsManager.init();

  // Request Android permissions early (Android 11+)
  if (Platform.isAndroid) {
    // Request READ_EXTERNAL_STORAGE first (more reliable than MANAGE_EXTERNAL_STORAGE)
    PermissionStatus readStatus = await Permission.storage.request();

    // Also try MANAGE_EXTERNAL_STORAGE for broader access
    PermissionStatus manageStatus = await Permission.manageExternalStorage
        .request();
  }

  // Custom Error Widget
  // ErrorWidget.builder = (FlutterErrorDetails details) {
  //   return Center(child: CircularProgressIndicator(color: Colors.redAccent));
  // };

  // Initialize Supabase
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // Set Preferred Orientations and System UI Mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  // Set Window Size Constraints for Desktop Platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(500, 1005)); //logical width height
    setWindowMaxSize(const Size(10000, 10000)); //logical width height
  }

  runApp(const MxMusicConsole());
}

//index for Navigation Bar
int navigationIndex = 1;

// Bottom Navigation Bar Items
List<Widget> navigationBarDestinationsItems = [
  const NavigationDestination(icon: Icon(Icons.search), label: "Search"),
  NavigationDestination(
    icon: Transform.scale(
      scale: 1.05,
      child: SvgPicture.asset(
        "assets/MusicIcons/MusicLogo.svg",
        height: 25,
        width: 25,
        color: const Color.fromRGBO(216, 194, 192, 1),
      ),
    ),
    label: "Home",
  ),
  // const NavigationDestination(icon: Icon(Icons.music_note), label: "Home"),
  const NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
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
    return ToastificationWrapper(
      child: MaterialApp(
        title: "Rusic",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Asimovian',
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
          navigationBarTheme: const NavigationBarThemeData(
            backgroundColor: Color.fromRGBO(26, 26, 26, 1),
          ),
          textTheme: const TextTheme(
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
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.dark,
            seedColor: Colors.redAccent,
          ),
          navigationBarTheme: const NavigationBarThemeData(
            backgroundColor: Color.fromRGBO(26, 26, 26, 1),
          ),
          textTheme: const TextTheme(
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
              return const CompactScreen();
            } else {
              return const WideScreen();
            }
          },
        ),
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
            indicatorShape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            selectedIndex: navigationIndex,
            onDestinationSelected: (value) => setState(() {
              navigationIndex = value;
            }),
          ),
          const VerticalDivider(
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
          const SizedBox(
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
      extendBody: true,
      bottomNavigationBar: Stack(
        alignment: AlignmentGeometry.bottomCenter,
        children: [
          AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            offset: navigationIndex != 2 ? Offset.zero : const Offset(0, 1),
            child: const BottomMusicController(),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: NavigationBar(
              height: 80,
              destinations: navigationBarDestinationsItems,
              selectedIndex: navigationIndex,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              indicatorShape: null,
              onDestinationSelected: (value) {
                navigationIndex = value;
                setState(() {});
              },
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: navigationIndex,
        children: const [Search(), Library(), Settings()],
      ),
    );
  }
}
