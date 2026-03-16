import 'package:Rusic/managers/ui_manager.dart';
import 'package:Rusic/managers/credentials_manager.dart';
import 'package:Rusic/managers/server_manager/supabase_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(26, 26, 26, 1),
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
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
              sliver: SliverToBoxAdapter(child: CompactSettingsScreen()),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.8),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      // 1. Clear FlutterSecureStorage
                      final credentialsManager = CredentialsManager();
                      await credentialsManager.clearAll();

                      // 2. Clear SharedPreferences
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();

                      if (context.mounted) {
                        showToast(context, "All app data has been cleared.");
                      }
                    },
                    child: const Text("Clear All App Data"),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
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
  TextEditingController skipAtBeginningController = TextEditingController();
  TextEditingController skipAtEndController = TextEditingController();
  FocusNode highlightsDurationFocusNode = FocusNode();
  FocusNode skipAtBeginningFocusNode = FocusNode();
  FocusNode skipAtEndFocusNode = FocusNode();

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
    skipAtBeginningController.text = "5";
    skipAtEndController.text = "10";

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

    skipAtBeginningFocusNode.addListener(() {
      if (!skipAtBeginningFocusNode.hasFocus) {
        if (skipAtBeginningController.text.isEmpty) {
          return;
        } else {
          int value = int.tryParse(skipAtBeginningController.text) ?? 0;
          if (value < 0) value = 0;
          if (value > 10) value = 10;
          skipAtBeginningController.text = value.toString();
        }
      }
    });

    skipAtEndFocusNode.addListener(() {
      if (!skipAtEndFocusNode.hasFocus) {
        if (skipAtEndController.text.isEmpty) {
          return;
        } else {
          int value = int.tryParse(skipAtEndController.text) ?? 0;
          if (value < 0) value = 0;
          if (value > 10) value = 10;
          skipAtEndController.text = value.toString();
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
    skipAtBeginningController.dispose();
    skipAtBeginningFocusNode.dispose();
    skipAtEndController.dispose();
    skipAtEndFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── System Settings ──────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader("System Settings"),
              const Divider(),
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
                    DropdownMenuEntry(
                      value: 'Comic Relief',
                      label: 'Comic Relief',
                    ),
                    DropdownMenuEntry(
                      value: 'System Font',
                      label: 'System Font',
                    ),
                  ],
                  onSelected: (value) {},
                ),
              ),
              const SizedBox(height: 16),
              const Text("System Theme", style: TextStyle(fontSize: 16)),
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
              const Text("App UI", style: TextStyle(fontSize: 16)),
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
                      label: const Text("Weather Theme"),
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
            ],
          ),
        ),

        // ── Audio Settings ────────────────────────────────────────────────
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader("Audio Settings"),
              const Divider(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Skip at Beginning",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(
                      width: 35,
                      child: TextField(
                        controller: skipAtBeginningController,
                        focusNode: skipAtBeginningFocusNode,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          suffixText: "s",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Skip at End", style: TextStyle(fontSize: 16)),
                    SizedBox(
                      width: 35,
                      child: TextField(
                        controller: skipAtEndController,
                        focusNode: skipAtEndFocusNode,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          suffixText: "s",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text("Cross Fade", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
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
                    });
                  },
                  min: 0,
                  max: 10,
                  divisions: 10,
                  label: crossFade.toInt().toString(),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "0s",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      "10s",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Video Settings ────────────────────────────────────────────────
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader("Video Settings"),
              const Divider(),
              const SizedBox(height: 16),
              const Text("Video Preference", style: TextStyle(fontSize: 16)),
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
                child: Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: playHighlights,
                    onChanged: (value) =>
                        setState(() => playHighlights = value),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SettingsRow(
                label: "Highlights Duration",
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: SizedBox(
                    width: 35,
                    child: TextField(
                      controller: highlightsDurationController,
                      focusNode: highlightsDurationFocusNode,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        suffixText: "s",
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Supabase Configuration"),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: isSupabaseConfigured,
                          onChanged: (value) async {
                            setState(() {
                              isSupabaseConfigured = value;
                            });
                            if (!value) {
                              await _credentialsManager
                                  .clearSupabaseCredentials();
                              urlController.clear();
                              apiKeyController.clear();
                              tableNameController.clear();
                              if (mounted) {
                                showToast(
                                  context,
                                  'Supabase configuration cleared',
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
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
                                          supabaseUrl: urlController.text
                                              .trim(),
                                          supabaseAnonKey: apiKeyController.text
                                              .trim(),
                                          tableName: tableNameController.text
                                              .trim(),
                                        );

                                        final isConnected = await connection
                                            .isConnected();

                                        if (mounted) {
                                          if (isConnected) {
                                            await _credentialsManager
                                                .saveSupabaseCredentials(
                                                  url: urlController.text
                                                      .trim(),
                                                  apiKey: apiKeyController.text
                                                      .trim(),
                                                  tableName: tableNameController
                                                      .text
                                                      .trim(),
                                                );
                                            showToast(
                                              context,
                                              'Supabase connected and saved successfully!',
                                            );
                                          } else {
                                            showToast(
                                              context,
                                              'Failed to connect to Supabase. Check your credentials.',
                                            );
                                          }
                                        }
                                      }
                                    },
                                    style: ButtonStyle(
                                      shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
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
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Server Configuration"),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: isServerConfigured,
                      onChanged: (value) async {
                        setState(() {
                          isServerConfigured = value;
                        });
                        if (!value) {
                          await _credentialsManager.clearServerAddress();
                          serverAddressController.clear();
                          if (mounted) {
                            showToast(context, 'Server configuration cleared');
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
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
                                      showToast(
                                        context,
                                        'Server configuration saved successfully!',
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
                    : const SizedBox.shrink(),
              ),
            ],
          ),
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

void showToast(BuildContext context, String message) {
  toastification.show(
    context: context,
    title: Text(message),
    style: ToastificationStyle.simple,
    autoCloseDuration: const Duration(seconds: 3),
    alignment: Alignment.bottomCenter,
    margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    borderRadius: BorderRadius.circular(30),
    showProgressBar: false,
    type: ToastificationType.info,
    closeButtonShowType: CloseButtonShowType.none,
  );
}
