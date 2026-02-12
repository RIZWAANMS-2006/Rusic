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
  String videoPreference = "Landscape Contain";
  bool playHighlights = true;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        SizedBox(height: 5),
        Container(
          color: Colors.amber,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 7,
            children: [
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
        Text(
          "Audio Settings",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 5),
        Container(
          color: Colors.red,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 7,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Cross Fade", style: TextStyle(fontSize: 16)),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8.0,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 16.0,
                      ),
                      valueIndicatorShape: SliderComponentShape.noThumb,
                      valueIndicatorTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      showValueIndicator: ShowValueIndicator.onDrag,
                    ),
                    child: Slider(
                      padding: null,
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
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Low Possible Value
                        Text(
                          "0s",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        // Highest Possible Value
                        Text(
                          "10s",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Video Settings",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 5),
        Container(
          color: Colors.greenAccent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 7,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 7,
                children: [
                  Text("Video Preference", style: TextStyle(fontSize: 16)),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 5,
                      children: [
                        ChoiceChip(
                          label: Text("Landscape Contain"),
                          selected: videoPreference == "Landscape Contain",
                          onSelected: (selected) {
                            setState(() {
                              videoPreference = "Landscape Contain";
                            });
                          },
                        ),
                        ChoiceChip(
                          label: Text("Landscape Cover"),
                          selected: videoPreference == "Landscape Cover",
                          onSelected: (selected) {
                            setState(() {
                              videoPreference = "Landscape Cover";
                            });
                          },
                        ),
                        ChoiceChip(
                          label: Text("Portrait Contain"),
                          selected: videoPreference == "Portrait Contain",
                          onSelected: (selected) {
                            setState(() {
                              videoPreference = "Portrait Contain";
                            });
                          },
                        ),
                        ChoiceChip(
                          label: Text("Portrait Cover"),
                          selected: videoPreference == "Portrait Cover",
                          onSelected: (selected) {
                            setState(() {
                              videoPreference = "Portrait Cover";
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Play Highlights (Default)",
                        style: TextStyle(fontSize: 16),
                      ),
                      Switch(
                        value: playHighlights,
                        onChanged: (value) {
                          setState(() {
                            playHighlights = value;
                          });
                        },
                      ),
                    ],
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
