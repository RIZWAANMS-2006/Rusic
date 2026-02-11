import 'package:Rusic/managers/ui_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  double crossFade = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 7,
      children: [
        Container(
          alignment: Alignment.topLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 7,
            children: [
              Text(
                "System Settings",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Font",
                    style: TextStyle(
                      // backgroundColor: Colors.amber,
                      fontSize: 16,
                    ),
                  ),
                  DropdownMenu(
                    width: 150,
                    hintText: "Select Font",
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                    ),
                    inputDecorationTheme: InputDecorationTheme(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownMenuEntries: <DropdownMenuEntry>[
                      DropdownMenuEntry(value: 'Asimovian', label: 'Asimovian'),
                      DropdownMenuEntry(value: 'Borel', label: 'Borel'),
                      DropdownMenuEntry(
                        value: 'Comic Relief',
                        label: 'Comic Relief',
                      ),
                      DropdownMenuEntry(
                        value: 'System Font',
                        label: 'System Font',
                      ),
                    ],
                    onSelected: (value) {
                      print(value);
                    },
                  ),
                ],
              ),
              Column(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "System Theme",
                    style: TextStyle(
                      // backgroundColor: Colors.amber,
                      fontSize: 16,
                    ),
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
            ],
          ),
        ),
        SizedBox(height: 10),
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 7,
            children: [
              Text(
                "Audio Settings",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.start,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Cross Fade", style: TextStyle(fontSize: 16)),
                  Slider(
                    value: crossFade,
                    onChanged: (value) {
                      setState(() {
                        crossFade = value;
                        print(crossFade);
                      });
                    },
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: crossFade.toInt().toString(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
