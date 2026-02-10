// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:Rusic/managers/credentials_manager.dart';
import 'package:Rusic/managers/server_manager/supabase_manager.dart';
import 'package:Rusic/ui/media_ui.dart';

class OnlineScreenLoginSuccess extends StatefulWidget {
  final void Function() onLogout;
  const OnlineScreenLoginSuccess({super.key, required this.onLogout});

  @override
  State<OnlineScreenLoginSuccess> createState() =>
      OnlineScreenLoginSuccessState();
}

class OnlineScreenLoginSuccessState extends State<OnlineScreenLoginSuccess> {
  String _tableName = 'Online';
  Future<List<OnlineSong>>? _songsFuture;

  @override
  void initState() {
    super.initState();
    print('[OnlineScreenLoginSuccess] initState called');
    _loadAndFetchSongs();
  }

  Future<void> _loadAndFetchSongs() async {
    try {
      final credentials = CredentialsManager();
      final credentialsData = await credentials.getSupabaseCredentials();
      final tableName = credentialsData['tableName'] ?? 'Online';
      final url = credentialsData['url'];
      final apiKey = credentialsData['apiKey'];

      print('Loading songs from table: $tableName');
      print('URL exists: ${url != null}');
      print('API Key exists: ${apiKey != null}');

      if (!mounted) return;

      setState(() {
        _tableName = tableName;
      });

      if (url != null && apiKey != null) {
        print('Creating Supabase connection...');
        final connection = SupabaseConnection(
          supabaseUrl: url,
          supabaseAnonKey: apiKey,
          tableName: tableName,
        );

        if (!mounted) return;

        setState(() {
          _songsFuture = connection.fetchOnlineSongs();
        });
        print('Songs future set');
      } else {
        print('ERROR: Missing Supabase credentials');
      }
    } catch (e) {
      print('ERROR in _loadAndFetchSongs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnlineMediaUI(
      title: _tableName,
      songsFuture: _songsFuture,
      emptyMessage: 'No songs found in $_tableName',
      showMusicController: true,
      onLogout: widget.onLogout,
    );
  }
}
