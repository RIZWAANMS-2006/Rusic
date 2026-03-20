import 'package:flutter/material.dart';
import 'package:Rusic/managers/credentials_manager.dart';
import 'package:Rusic/managers/server_manager/supabase_manager.dart';
import 'package:Rusic/managers/server_manager/server_manager.dart';
import 'package:Rusic/managers/database_manager.dart';
import 'package:Rusic/ui/media_ui.dart';

class OnlineScreen extends StatefulWidget {
  const OnlineScreen({super.key});

  @override
  State<OnlineScreen> createState() => OnlineScreenState();
}

class OnlineScreenState extends State<OnlineScreen> {
  Future<List<OnlineSong>>? _songsFuture;
  bool _isConfigured = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkConfigAndFetch();
  }

  Future<void> _checkConfigAndFetch() async {
    final credentials = CredentialsManager();
    final supaCreds = await credentials.getSupabaseCredentials();
    final serverAddress = await credentials.getServerAddress();
    final serverName = await credentials.getServerName();

    final hasSupa = supaCreds['url'] != null && supaCreds['apiKey'] != null;
    final hasServer = serverAddress != null && serverAddress.isNotEmpty;

    if (!hasSupa && !hasServer) {
      if (mounted) {
        setState(() {
          _isConfigured = false;
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isConfigured = true;
      });
    }

    final cachedSongs = await DatabaseManager.instance.getCachedOnlineSongs();

    if (cachedSongs.isNotEmpty) {
      if (mounted) {
        setState(() {
          _songsFuture = Future.value(cachedSongs);
          _isLoading = false;
        });
      }
      // Update cache in the background
      _fetchAndUpdateCache(credentials, supaCreds, serverAddress, serverName);
    } else {
      if (mounted) {
        setState(() {
          _songsFuture = _fetchAndUpdateCache(
            credentials,
            supaCreds,
            serverAddress,
            serverName,
          );
          _isLoading = false;
        });
      }
    }
  }

  Future<List<OnlineSong>> _fetchAndUpdateCache(
    CredentialsManager credentials,
    Map<String, String?> supaCreds,
    String? serverAddress,
    String? serverName,
  ) async {
    List<OnlineSong> combinedSongs = [];

    // 1. Fetch Supabase
    if (supaCreds['url'] != null && supaCreds['apiKey'] != null) {
      try {
        final tableName = supaCreds['tableName'] ?? 'Online';
        final supa = SupabaseConnection(
          supabaseUrl: supaCreds['url']!,
          supabaseAnonKey: supaCreds['apiKey']!,
          tableName: tableName,
        );
        combinedSongs.addAll(await supa.fetchOnlineSongsRaw());
      } catch (e) {
        print('Error fetching Supabase: $e');
      }
    }

    // 2. Fetch HTTP Server
    if (serverAddress != null && serverAddress.isNotEmpty) {
      try {
        final httpManager = HTTPServerManager(
          serverAddress: serverAddress,
          serverName: serverName,
        );
        combinedSongs.addAll(await httpManager.fetchSongs());
      } catch (e) {
        print('Error fetching Server: $e');
      }
    }

    if (combinedSongs.isNotEmpty) {
      await DatabaseManager.instance.cacheOnlineSongs(combinedSongs);
    }

    return combinedSongs;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color.fromRGBO(26, 26, 26, 1),
        body: Center(
          child: CircularProgressIndicator(strokeCap: StrokeCap.round),
        ),
      );
    }

    if (!_isConfigured) {
      return const Scaffold(
        backgroundColor: Color.fromRGBO(26, 26, 26, 1),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 64, color: Colors.grey),
              SizedBox(height: 6),
              Text(
                'Not Configured',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Please configure Supabase or Server inside Settings.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return OnlineMediaUI(
      title: 'Online',
      songsFuture: _songsFuture,
      emptyMessage: 'No songs found. Please check your connection or server.',
      showMusicController: true,
      onLogout: null, // Removed logout button from UI
    );
  }
}
