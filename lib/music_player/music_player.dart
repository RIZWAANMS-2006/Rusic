import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Rusic/music_player/online_screens/online_screen.dart';
import 'package:Rusic/music_player/location_screens/location_screen.dart';
import 'package:Rusic/managers/database_manager.dart';
import 'package:Rusic/managers/settings_manager.dart';
import 'package:Rusic/ui/media_ui.dart';
import 'dart:io';

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
    return Container(color: const Color.fromRGBO(34, 34, 34, 1), child: tabBar);
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

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: SettingsManager.getLastLibraryTab,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        SettingsManager.setLastLibraryTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
      body: Stack(
        children: [
          NestedScrollView(
            physics: const BouncingScrollPhysics(),
            headerSliverBuilder: (context, innerbox) {
              return [
                const CupertinoSliverNavigationBar(
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
                      tabs: const [
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
                const OnlineScreen(),
                AnimatedBuilder(
                  animation: DatabaseManager.instance,
                  builder: (context, _) {
                    return MediaUI(
                      // Uses the timestamp / unique key on rebuild so MediaUI fetches anew
                      key: ValueKey(DateTime.now().millisecondsSinceEpoch),
                      title: "Favorites",
                      showNavigationBar: false,
                      emptyMessage: "No Favorite Yet...",
                      mediaFilesFuture: DatabaseManager.instance
                          .getAllFavorites()
                          .then((paths) {
                            final files = paths
                                .map((path) => File(path))
                                .where((file) => file.existsSync())
                                .toList();
                            return {"Favorites": files};
                          }),
                    );
                  },
                ),
                const Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Center(child: Text("No Playlist Yet...")),
                ),
                const LocationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
