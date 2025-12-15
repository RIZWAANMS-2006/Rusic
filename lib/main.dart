import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:window_size/window_size.dart";
import 'Music Player/Music_Player.dart';
import 'Settings/Settings_UI.dart';
import 'Search/Search_Page.dart';

void main() async {
  // ErrorWidget.builder = (FlutterErrorDetails details) {
  //   return Center(child: CircularProgressIndicator(color: Colors.redAccent));
  // };
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(Size(500, 1005)); //logical width height
    setWindowMaxSize(Size(10000, 10000)); //logical width height
  }
  runApp(const MyMusic());
}

//index for bottom navigation bar
int navigationIndex = 1;

// Bottom Navigation Bar Items
const List<BottomNavigationBarItem> bottomNavigationBarItems = [
  BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
  BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Home'),
  BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
];

// Navigation Rail Items
const List<NavigationRailDestination> navigationRailItems = [
  NavigationRailDestination(icon: Icon(Icons.search), label: Text('Search')),
  NavigationRailDestination(
    icon: Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Icon(Icons.library_music),
    ),
    label: Text('Home'),
  ),
  NavigationRailDestination(
    icon: Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Icon(Icons.settings),
    ),
    label: Text('Settings'),
  ),
];

class MyMusic extends StatefulWidget {
  const MyMusic({super.key});

  @override
  State<MyMusic> createState() => MyMusicState();
}

class MyMusicState extends State<MyMusic> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "MyMusic",
      home: FutureBuilder(
        initialData: {"mode": true, "bgstatus": "PowerSaving Mode"},
        future: FileSettings,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              backgroundColor: snapshot.data!["mode"] == true
                  ? Colors.black
                  : Colors.white,
              body: MediaQuery.of(context).size.width < 700
                  ? (navigationIndex == 0
                        ? Search_Page()
                        : navigationIndex == 1
                        ? Home_Page()
                        : navigationIndex == 2
                        ? Settings_UI()
                        : Container())
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 0,
                      children: [
                        navigationIndex == 0
                            ? Expanded(child: Search_Page())
                            : navigationIndex == 1
                            ? Expanded(child: Home_Page())
                            : navigationIndex == 2
                            ? Expanded(child: Settings_UI())
                            : Container(),
                      ],
                    ),
              floatingActionButtonLocation:
                  MediaQuery.of(context).size.width < 700
                  ? FloatingActionButtonLocation.centerFloat
                  : FloatingActionButtonLocation.startFloat,
              floatingActionButton: MediaQuery.of(context).size.width < 700
                  ? Padding(
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
                                    BottomNavigationBarLandscapeLayout.centered,
                                type: BottomNavigationBarType.fixed,
                                items: bottomNavigationBarItems,
                                currentIndex: navigationIndex,
                                onTap: (value) => setState(() {
                                  navigationIndex = value;
                                }),
                                showUnselectedLabels: false,
                                backgroundColor: Colors.transparent,
                                unselectedItemColor:
                                    (snapshot.data!["mode"] == true)
                                    ? Colors.white
                                    : Colors.black,
                                selectedItemColor: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight:
                                MediaQuery.of(context).size.height * 0.35,
                            minWidth: 60,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: snapshot.data!["mode"] == true
                                    ? [Colors.black45, Colors.black54]
                                    : [Colors.white54, Colors.white60],
                              ),
                              // color: snapshot.data!["mode"] == true
                              //     ? Colors.black
                              //     : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              spacing: 10,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        navigationIndex = 0;
                                        setState(() {});
                                      },
                                      icon: Icon(
                                        Icons.search,
                                        color: navigationIndex == 0
                                            ? Colors.red
                                            : snapshot.data!["mode"] == true
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    if (navigationIndex == 0)
                                      Text(
                                        "Search",
                                        style: TextStyle(
                                          color: navigationIndex == 0
                                              ? Colors.red
                                              : snapshot.data!["mode"] == true
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        navigationIndex = 1;
                                        setState(() {});
                                      },
                                      icon: Icon(
                                        Icons.library_music,
                                        color: navigationIndex == 1
                                            ? Colors.red
                                            : snapshot.data!["mode"] == true
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    if (navigationIndex == 1)
                                      Text(
                                        "Home",
                                        style: TextStyle(
                                          color: navigationIndex == 1
                                              ? Colors.red
                                              : snapshot.data!["mode"] == true
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        navigationIndex = 2;
                                        setState(() {});
                                      },
                                      icon: Icon(
                                        Icons.settings,
                                        color: navigationIndex == 2
                                            ? Colors.red
                                            : snapshot.data!["mode"] == true
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    if (navigationIndex == 2)
                                      Text(
                                        "Settings",
                                        style: TextStyle(
                                          color: navigationIndex == 2
                                              ? Colors.red
                                              : snapshot.data!["mode"] == true
                                              ? Colors.white
                                              : Colors.black,
                                        ),
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
          } else {
            return CircularProgressIndicator(color: Colors.redAccent);
          }
        },
      ),
    );
  }
}
