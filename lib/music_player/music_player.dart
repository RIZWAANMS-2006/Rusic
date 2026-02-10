import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Rusic/music_player/online_screens/online_screen.dart';
import 'package:Rusic/music_player/locations_screen/location_screen.dart';
import 'package:Rusic/ui/media_ui.dart';

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Color.fromRGBO(34, 34, 34, 1), child: tabBar);
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return false;
  }
}

// Creating "Rusic"
class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => LibraryState();
}

// Creating "Music Controller State Class"
class LibraryState extends State<Library>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  final AlphabetScrollerController _alphabetController =
      AlphabetScrollerController();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    _alphabetController.setActiveTab(_tabController.index);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _alphabetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(26, 26, 26, 1),
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerbox) {
              return [
                CupertinoSliverNavigationBar(
                  largeTitle: Text("Library"),
                  middle: Text("Library"),
                  alwaysShowMiddle: false,
                  backgroundColor: Color.fromRGBO(34, 34, 34, 1),
                  stretch: true,
                  border: null,
                ),
                SliverPersistentHeader(
                  floating: false,
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      tabAlignment: TabAlignment.start,
                      isScrollable: true,
                      indicatorColor: Colors.red,
                      tabs: [
                        SizedBox(width: 100, child: Tab(text: "Online")),
                        SizedBox(width: 100, child: Tab(text: "Favourites")),
                        SizedBox(width: 100, child: Tab(text: "Playlists")),
                        SizedBox(width: 100, child: Tab(text: "Locations")),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                AlphabetScrollerScope(
                  controller: _alphabetController,
                  tabIndex: 0,
                  child: OnlineScreen(),
                ),
                Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Center(child: Text("No Favorite Yet...")),
                ),
                Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Center(child: Text("No Playlist Yet...")),
                ),
                AlphabetScrollerScope(
                  controller: _alphabetController,
                  tabIndex: 3,
                  child: LocationScreen(),
                ),
              ],
            ),
          ),
          // Library-level AlphabetScroller overlay
          ListenableBuilder(
            listenable: _alphabetController,
            builder: (context, child) {
              if (!_alphabetController.hasData) {
                return const SizedBox.shrink();
              }
              return AlphabetScroller(
                letterToIndex: _alphabetController.letterToIndex,
                onLetterSelected: _alphabetController.onLetterSelected!,
                topPadding: 100,
                bottomPadding: 120,
              );
            },
          ),
        ],
      ),
    );
  }
}
