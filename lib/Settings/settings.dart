import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_controller/Managers/settings_manager.dart';
import 'package:music_controller/managers/credentials_manager.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late TextEditingController _crossfadeController;
  bool _hasSupabaseCredentials = false;

  @override
  void initState() {
    super.initState();
    _crossfadeController = TextEditingController(
      text: SettingsManager.getCrossfadeDuration.toString(),
    );
    _checkSupabaseCredentials();
  }

  @override
  void dispose() {
    _crossfadeController.dispose();
    super.dispose();
  }

  Future<void> _checkSupabaseCredentials() async {
    final has = await CredentialsManager().hasSupabaseCredentials();
    if (mounted) {
      setState(() => _hasSupabaseCredentials = has);
    }
  }

  Future<void> _logoutSupabase() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromRGBO(34, 34, 34, 1),
        title: const Text(
          'Log Out of Database?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will remove your saved Supabase credentials. You will need to re-enter them to access online music.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await CredentialsManager().clearSupabaseCredentials();
      if (mounted) {
        setState(() => _hasSupabaseCredentials = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out of Supabase'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> settingsItems = [
      // Dark Mode Toggle
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
      // Crossfade Duration
      Center(
        child: ListTile(
          title: const Text(
            "Crossfade Duration",
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            SettingsManager.getCrossfadeDuration == 0
                ? "Off"
                : "${SettingsManager.getCrossfadeDuration} seconds",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          trailing: SizedBox(
            width: 80,
            child: TextField(
              controller: _crossfadeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: "0",
                hintStyle: TextStyle(color: Colors.grey[600]),
                suffixText: "s",
                suffixStyle: const TextStyle(color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                filled: true,
                fillColor: const Color.fromRGBO(50, 50, 50, 1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                final parsed = int.tryParse(value) ?? 0;
                SettingsManager.setCrossfadeDuration(parsed);
                setState(() {});
              },
            ),
          ),
        ),
      ),
      // Database Logout
      Center(
        child: ListTile(
          leading: Icon(
            Icons.cloud_off,
            color: _hasSupabaseCredentials ? Colors.red[300] : Colors.grey,
          ),
          title: const Text(
            "Database Logout",
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            _hasSupabaseCredentials ? "Connected to Supabase" : "Not connected",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          trailing: ElevatedButton(
            onPressed: _hasSupabaseCredentials ? _logoutSupabase : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              disabledBackgroundColor: Colors.grey[800],
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Log Out"),
          ),
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
