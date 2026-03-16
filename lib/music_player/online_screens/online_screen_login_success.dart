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

    _loadAndFetchSongs();
  }

  Future<void> _loadAndFetchSongs() async {
    try {
      final credentials = CredentialsManager();
      final credentialsData = await credentials.getSupabaseCredentials();
      final tableName = credentialsData['tableName'] ?? 'Online';
      final url = credentialsData['url'];
      final apiKey = credentialsData['apiKey'];

      if (!mounted) return;

      setState(() {
        _tableName = tableName;
      });

      if (url != null && apiKey != null) {
        final connection = SupabaseConnection(
          supabaseUrl: url,
          supabaseAnonKey: apiKey,
          tableName: tableName,
        );

        if (!mounted) return;

        setState(() {
          _songsFuture = connection.fetchOnlineSongs();
        });
      } else {}
    } catch (e) {}
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
