// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:music_controller/music_player/online_screens/online_screen_login.dart';
import 'package:music_controller/music_player/online_screens/online_screen_login_success.dart';
import 'package:music_controller/managers/credentials_manager.dart';
import 'package:music_controller/managers/server_manager/supabase_manager.dart';

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
  String? _tableName;

  @override
  void initState() {
    super.initState();
    _checkExistingConnection();
  }

  Future<void> _checkExistingConnection() async {
    final credentials = CredentialsManager();
    final credentialsData = await credentials.getSupabaseCredentials();
    final savedUrl = credentialsData['url'];
    final savedKey = credentialsData['apiKey'];
    final savedTableName = credentialsData['tableName'];

    if (savedUrl != null && savedKey != null && savedTableName != null) {
      supabaseConnection = SupabaseConnection(
        supabaseUrl: savedUrl,
        supabaseAnonKey: savedKey,
        tableName: savedTableName,
      );
      final ok = await supabaseConnection!.isConnected();

      if (!mounted) return;

      setState(() {
        _url = savedUrl;
        _apiKey = savedKey;
        _tableName = savedTableName;
        connectionStatus = ok;
        isChecking = false;
      });
    } else {
      if (!mounted) return;

      setState(() {
        connectionStatus = false;
        isChecking = false;
      });
    }
  }

  Future<void> _onCredentialsSubmit(
    String url,
    String apiKey,
    String tableName,
  ) async {
    setState(() => isChecking = true);
    supabaseConnection = SupabaseConnection(
      supabaseUrl: url,
      supabaseAnonKey: apiKey,
      tableName: tableName,
    );
    final ok = await supabaseConnection!.isConnected();
    print('[OnlineScreen] Connection status: $ok');

    if (ok) {
      final credentials = CredentialsManager();
      await credentials.saveSupabaseCredentials(
        url: url,
        apiKey: apiKey,
        tableName: tableName,
      );
      print('[OnlineScreen] Credentials saved successfully');
    }

    if (!mounted) return;

    setState(() {
      _url = url;
      _apiKey = apiKey;
      _tableName = tableName;
      connectionStatus = ok;
      isChecking = false;
    });
  }

  Future<void> _logout() async {
    final credentials = CredentialsManager();
    await credentials.clearSupabaseCredentials();

    if (!mounted) return;

    setState(() {
      supabaseConnection = null;
      _url = null;
      _apiKey = null;
      _tableName = null;
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
