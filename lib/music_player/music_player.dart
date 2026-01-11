import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_controller/music_player/online_screens/online_screen.dart';

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

// Creating "Music_Controller"
class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => LibraryState();
}

// Creating "Music Controller State Class"
class LibraryState extends State<Library>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Color.fromRGBO(26, 26, 26, 1),
        body: NestedScrollView(
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
            children: [
              OnlineScreen(),
              Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(child: Text("No Favorite Yet...")),
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(child: Text("No Playlist Yet...")),
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(child: Text("No Locations Available...")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
