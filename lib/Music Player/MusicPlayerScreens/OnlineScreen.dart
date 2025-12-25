import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupabaseConnection {
  final String supabaseUrl;
  final String supabaseAnonKey;
  late final SupabaseClient client;

  SupabaseConnection({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  }) {
    client = SupabaseClient(supabaseUrl, supabaseAnonKey);
  }

  Future<bool> isConnected() async {
    try {
      await client.from('MxMusicConsoleSongs').select().limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchSongs() async {
    final response = await client.from('MxMusicConsoleSongs').select();
    return List<Map<String, dynamic>>.from(response as List);
  }
}

class OnlineScreenLogin extends StatefulWidget {
  final void Function(String url, String apiKey) onSubmit;

  const OnlineScreenLogin({super.key, required this.onSubmit});

  @override
  State<OnlineScreenLogin> createState() => OnlineScreenLoginState();
}

class OnlineScreenLoginState extends State<OnlineScreenLogin> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController urlController = TextEditingController();
  TextEditingController apiKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
        child: Container(
          height: 330,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: Color.fromRGBO(39, 39, 39, 1),
          ),
          child: Form(
            key: _formKey,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        "Supabase Configuration",
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text("Enter URL"),
                    TextFormField(
                      controller: urlController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter Valid URL';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Text("Enter Anon-API Key"),
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
                  ],
                ),
                Positioned(
                  bottom: 10,
                  right: 0,
                  child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSubmit(
                          urlController.text.trim(),
                          apiKeyController.text.trim(),
                        );
                      }
                    },
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    child: Text("Connect"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnlineScreenLoginSuccess extends StatefulWidget {
  final void Function() onLogout;
  const OnlineScreenLoginSuccess({super.key, required this.onLogout});

  @override
  State<OnlineScreenLoginSuccess> createState() =>
      OnlineScreenLoginSuccessState();
}

class OnlineScreenLoginSuccessState extends State<OnlineScreenLoginSuccess> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: FilledButton(
                    onPressed: widget.onLogout,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    child: Row(
                      spacing: 5,
                      children: [
                        Icon(Icons.power_settings_new_rounded),
                        Text("Logout"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            body: Center(child: Text("Online Music Screen Login Success")),
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: FilledButton(
                    onPressed: widget.onLogout,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    child: Row(
                      spacing: 5,
                      children: [
                        Icon(Icons.power_settings_new_rounded),
                        Text("Logout"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            body: Center(child: Text("Online Music Screen Login Success")),
          );
        }
      },
    );
  }
}

class OnlineScreen extends StatefulWidget {
  const OnlineScreen({super.key});

  @override
  State<OnlineScreen> createState() => OnlineScreenState();
}

class OnlineScreenState extends State<OnlineScreen> {
  SupabaseConnection? supabaseConnection;
  bool isChecking = true;
  bool? connectionStatus;
  String? _url;
  String? _apiKey;

  @override
  void initState() {
    super.initState();
    _checkExistingConnection();
  }

  Future<void> _checkExistingConnection() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('supabaseUrl');
    final savedKey = prefs.getString('supabaseAnonKey');

    if (savedUrl != null && savedKey != null) {
      supabaseConnection = SupabaseConnection(
        supabaseUrl: savedUrl,
        supabaseAnonKey: savedKey,
      );
      final ok = await supabaseConnection!.isConnected();
      setState(() {
        _url = savedUrl;
        _apiKey = savedKey;
        connectionStatus = ok;
        isChecking = false;
      });
    } else {
      setState(() {
        connectionStatus = false;
        isChecking = false;
      });
    }
  }

  Future<void> _onCredentialsSubmit(String url, String apiKey) async {
    setState(() => isChecking = true);
    supabaseConnection = SupabaseConnection(
      supabaseUrl: url,
      supabaseAnonKey: apiKey,
    );
    final ok = await supabaseConnection!.isConnected();
    if (ok) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('supabaseUrl', url);
      await prefs.setString('supabaseAnonKey', apiKey);
    }
    setState(() {
      _url = url;
      _apiKey = apiKey;
      connectionStatus = ok;
      isChecking = false;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('supabaseUrl');
    await prefs.remove('supabaseAnonKey');
    setState(() {
      supabaseConnection = null;
      _url = null;
      _apiKey = null;
      connectionStatus = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isChecking) {
      return const Center(
        child: CircularProgressIndicator(strokeCap: StrokeCap.round),
      );
    }

    return connectionStatus == true
        ? OnlineScreenLoginSuccess(onLogout: _logout)
        : OnlineScreenLogin(onSubmit: _onCredentialsSubmit);
  }
}
