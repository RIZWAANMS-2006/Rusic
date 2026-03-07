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
  TextEditingController highlightsDurationController = TextEditingController();
  FocusNode highlightsDurationFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    highlightsDurationController.text = "30";
    highlightsDurationFocusNode.addListener(() {
      if (!highlightsDurationFocusNode.hasFocus) {
        if (highlightsDurationController.text.isEmpty) {
          return;
        } else {
          int value = int.tryParse(highlightsDurationController.text) ?? 0;
          if (value < 10) value = 10;
          if (value > 60) value = 60;
          highlightsDurationController.text = value.toString();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── System Settings ──────────────────────────────────────────────
        _SectionHeader("System Settings"),
        const SizedBox(height: 16),
        _SettingsRow(
          label: "Font",
          child: DropdownMenu(
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
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 'Asimovian', label: 'Asimovian'),
              DropdownMenuEntry(value: 'Borel', label: 'Borel'),
              DropdownMenuEntry(value: 'Comic Relief', label: 'Comic Relief'),
              DropdownMenuEntry(value: 'System Font', label: 'System Font'),
            ],
            onSelected: (value) {
              print(value);
            },
          ),
        ),
        const SizedBox(height: 16),
        Text("System Theme", style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        Center(
          child: CupertinoSlidingSegmentedControl(
            children: systemTheme,
            groupValue: selectedSystemTheme,
            thumbColor: Theme.of(context).colorScheme.primary,
            
            onValueChanged: (value) {
              setState(() {
                selectedSystemTheme = value ?? 'System';
              });
            },
          ),
        ),

        // ── Audio Settings ────────────────────────────────────────────────
        const SizedBox(height: 30),
        _SectionHeader("Audio Settings"),
        const SizedBox(height: 16),
        Text("Cross Fade", style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
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
              });
            },
            min: 0,
            max: 10,
            divisions: 10,
            label: crossFade.toInt().toString(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("0s", style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text("10s", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),

        // ── Video Settings ────────────────────────────────────────────────
        const SizedBox(height: 30),
        _SectionHeader("Video Settings"),
        const SizedBox(height: 16),
        Text("Video Preference", style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text("Landscape Contain"),
                selected: videoPreference == "Landscape Contain",
                onSelected: (_) =>
                    setState(() => videoPreference = "Landscape Contain"),
              ),
              ChoiceChip(
                label: const Text("Landscape Cover"),
                selected: videoPreference == "Landscape Cover",
                onSelected: (_) =>
                    setState(() => videoPreference = "Landscape Cover"),
              ),
              ChoiceChip(
                label: const Text("Portrait Contain"),
                selected: videoPreference == "Portrait Contain",
                onSelected: (_) =>
                    setState(() => videoPreference = "Portrait Contain"),
              ),
              ChoiceChip(
                label: const Text("Portrait Cover"),
                selected: videoPreference == "Portrait Cover",
                onSelected: (_) =>
                    setState(() => videoPreference = "Portrait Cover"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SettingsRow(
          label: "Play Highlights (Default)",
          child: Switch(
            value: playHighlights,
            onChanged: (value) => setState(() => playHighlights = value),
          ),
        ),
        const SizedBox(height: 16),
        _SettingsRow(
          label: "Highlights Duration",
          child: SizedBox(
            width: 70,
            height: 40,
            child: TextField(
              controller: highlightsDurationController,
              focusNode: highlightsDurationFocusNode,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                enabledBorder: null,
                suffixText: "s",
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _SettingsRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        child,
      ],
    );
  }
}
