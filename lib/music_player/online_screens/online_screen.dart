// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:music_controller/music_player/online_screens/online_screen_login.dart';
import 'package:music_controller/music_player/online_screens/online_screen_login_success.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('supabaseUrl');
    final savedKey = prefs.getString('supabaseAnonKey');
    final savedTableName = prefs.getString('supabaseTableName');

    if (savedUrl != null && savedKey != null && savedTableName != null) {
      supabaseConnection = SupabaseConnection(
        supabaseUrl: savedUrl,
        supabaseAnonKey: savedKey,
        tableName: savedTableName,
      );
      final ok = await supabaseConnection!.isConnected();
      setState(() {
        _url = savedUrl;
        _apiKey = savedKey;
        _tableName = savedTableName;
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
    if (ok) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('supabaseUrl', url);
      await prefs.setString('supabaseAnonKey', apiKey);
      await prefs.setString('supabaseTableName', tableName);
    }
    setState(() {
      _url = url;
      _apiKey = apiKey;
      _tableName = tableName;
      connectionStatus = ok;
      isChecking = false;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('supabaseUrl');
    await prefs.remove('supabaseAnonKey');
    await prefs.remove('supabaseTableName');
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
