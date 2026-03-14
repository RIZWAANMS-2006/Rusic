import 'package:Rusic/managers/ui_manager.dart';
import 'package:Rusic/managers/credentials_manager.dart';
import 'package:Rusic/managers/server_manager/supabase_manager.dart';
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
      backgroundColor: Color.fromRGBO(26, 26, 26, 1),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: CustomScrollView(
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
            SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
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
  String appUI = "Minimalistic";
  bool isSupabaseConfigured = false;
  bool isServerConfigured = false;
  bool playHighlights = true;
  TextEditingController highlightsDurationController = TextEditingController();
  FocusNode highlightsDurationFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();
  final _serverFormKey = GlobalKey<FormState>();
  TextEditingController urlController = TextEditingController();
  TextEditingController apiKeyController = TextEditingController();
  TextEditingController tableNameController = TextEditingController();
  TextEditingController serverAddressController = TextEditingController();

  final _credentialsManager = CredentialsManager();

  @override
  void initState() {
    super.initState();
    _loadConfigurations();
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

  Future<void> _loadConfigurations() async {
    final supabaseCredentials = await _credentialsManager
        .getSupabaseCredentials();
    final serverAddress = await _credentialsManager.getServerAddress();

    if (mounted) {
      setState(() {
        if (supabaseCredentials['url'] != null &&
            supabaseCredentials['apiKey'] != null &&
            supabaseCredentials['tableName'] != null) {
          isSupabaseConfigured = true;
          urlController.text = supabaseCredentials['url']!;
          apiKeyController.text = supabaseCredentials['apiKey']!;
          tableNameController.text = supabaseCredentials['tableName']!;
        }

        if (serverAddress != null && serverAddress.isNotEmpty) {
          isServerConfigured = true;
          serverAddressController.text = serverAddress;
        }
      });
    }
  }

  @override
  void dispose() {
    highlightsDurationController.dispose();
    highlightsDurationFocusNode.dispose();
    urlController.dispose();
    apiKeyController.dispose();
    tableNameController.dispose();
    serverAddressController.dispose();
    super.dispose();
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
            isMomentary: false,
            onValueChanged: (value) {
              setState(() {
                selectedSystemTheme = value ?? 'System';
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        Text("App UI", style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text("Minimalistic"),
                selected: appUI == "Minimalistic",
                onSelected: (_) {
                  setState(() => appUI = "Minimalistic");
                },
              ),
              ChoiceChip(
                label: const Text("Graphic"),
                selected: appUI == "Graphic",
                onSelected: (_) {
                  setState(() {
                    appUI = "Graphic";
                  });
                },
              ),
              ChoiceChip(
                label: Text("Weather Theme"),
                selected: appUI == "Weather Theme",
                onSelected: (_) {
                  setState(() {
                    appUI = "Weather Theme";
                  });
                },
              ),
            ],
          ),
        ),

        // ── Audio Settings ────────────────────────────────────────────────
        const SizedBox(height: 30),
        _SectionHeader("Audio Settings"),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Skip at Beginning", style: const TextStyle(fontSize: 16)),
            SizedBox(
              width: 70,
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  suffixText: "s",
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Skip at End", style: const TextStyle(fontSize: 16)),
            SizedBox(
              width: 70,
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  suffixText: "s",
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
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
        Text("Server Configuration", style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Supabase Configuration"),
                Switch(
                  value: isSupabaseConfigured,
                  onChanged: (value) async {
                    setState(() {
                      isSupabaseConfigured = value;
                    });
                    if (!value) {
                      await _credentialsManager.clearSupabaseCredentials();
                      urlController.clear();
                      apiKeyController.clear();
                      tableNameController.clear();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Supabase configuration cleared'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            AnimatedSize(
              duration: Duration(milliseconds: 200),
              child: isSupabaseConfigured
                  ? Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text("Enter Table Name"),
                          TextFormField(
                            controller: tableNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter Valid Table Name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          const Text("Enter URL"),
                          TextFormField(
                            controller: urlController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter Valid URL';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          const Text("Enter Anon-API Key"),
                          TextFormField(
                            controller: apiKeyController,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter Valid Anon-API Key';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: FilledButton(
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  // Verify connection before saving
                                  final connection = SupabaseConnection(
                                    supabaseUrl: urlController.text.trim(),
                                    supabaseAnonKey: apiKeyController.text
                                        .trim(),
                                    tableName: tableNameController.text.trim(),
                                  );

                                  final isConnected = await connection
                                      .isConnected();

                                  if (mounted) {
                                    if (isConnected) {
                                      await _credentialsManager
                                          .saveSupabaseCredentials(
                                            url: urlController.text.trim(),
                                            apiKey: apiKeyController.text
                                                .trim(),
                                            tableName: tableNameController.text
                                                .trim(),
                                          );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Supabase connected and saved successfully!',
                                          ),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Failed to connect to Supabase. Check your credentials.',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              style: ButtonStyle(
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                              child: const Text("Save"),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
            ),
          ],
        ),
        SizedBox(height: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Server Configuration"),
                Switch(
                  value: isServerConfigured,
                  onChanged: (value) async {
                    setState(() {
                      isServerConfigured = value;
                    });
                    if (!value) {
                      await _credentialsManager.clearServerAddress();
                      serverAddressController.clear();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Server configuration cleared'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            AnimatedSize(
              duration: Duration(milliseconds: 200),
              child: isServerConfigured
                  ? Form(
                      key: _serverFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text("Server Address"),
                          TextFormField(
                            controller: serverAddressController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter Valid Server Address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: FilledButton(
                              onPressed: () async {
                                if (_serverFormKey.currentState?.validate() ??
                                    false) {
                                  await _credentialsManager.saveServerAddress(
                                    serverAddressController.text.trim(),
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Server configuration saved successfully!',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ButtonStyle(
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                              child: const Text("Save"),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
            ),
          ],
        ),
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
