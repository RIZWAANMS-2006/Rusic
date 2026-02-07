import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_controller/Managers/settings_manager.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> settingsItems = [
      Center(
        child: SwitchListTile(
          value: SettingsManager.getDarkMode,
          onChanged: (value) {
            SettingsManager.setDarkMode(value);
            setState(() {});
          },
          title: Text("System Mode", style: TextStyle(color: Colors.white)),
        ),
      ),
    ];
    return Scaffold(
      backgroundColor: Color.fromRGBO(26, 26, 26, 1),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              CupertinoSliverNavigationBar(
                backgroundColor: Color.fromRGBO(26, 26, 26, 1),
                middle: Text("Settings", style: TextStyle(color: Colors.white)),
                largeTitle: Text(
                  "Settings",
                  style: TextStyle(color: Colors.white),
                ),
                alwaysShowMiddle: false,
              ),
              if (MediaQuery.of(context).size.width <= 700)
                SliverList(
                  delegate: SliverChildListDelegate([...settingsItems]),
                )
              else
                SliverGrid.extent(
                  maxCrossAxisExtent: 400,
                  childAspectRatio: 3,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  children: [...settingsItems],
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 170)),
            ],
          ),
          // Bottom gradient fade
          Positioned(
            bottom: 0,
            child: Container(
              height: 100,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.9),
                    Colors.black,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
