import 'package:Rusic/managers/ui_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Rusic/managers/settings_manager.dart';
import 'package:Rusic/managers/credentials_manager.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            stretch: true,
            alwaysShowMiddle: false,
            border: null,
            backgroundColor: setContainerColor(context),
            largeTitle: const Text("Settings"),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
            sliver: SliverToBoxAdapter(child: CompactSettingsScreen()),
          ),
        ],
      ),
    );
  }
}

class CompactSettingsScreen extends StatefulWidget {
  const CompactSettingsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _CompactSettingsScreenState();
}

class _CompactSettingsScreenState extends State<CompactSettingsScreen> {
  Map<String, Widget> systemTheme = {
    "System": const Text("System"),
    "Light": const Text("Light"),
    "Dark": const Text("Dark"),
  };
  String selectedSystemTheme = "System";

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      alignment: Alignment.topLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Container(
          //   color: Colors.green,
          //   child: ,
          // ),
          Container(
            color: Colors.red,
            child: Column(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "System Theme",
                  style: TextStyle(backgroundColor: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Center(
                  child: CupertinoSlidingSegmentedControl(
                    children: systemTheme,
                    groupValue: selectedSystemTheme,
                    thumbColor: Theme.of(context).colorScheme.primary,
                    onValueChanged: (value) {
                      setState(() {
                        selectedSystemTheme = value ?? 'System';
                        print(selectedSystemTheme);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
