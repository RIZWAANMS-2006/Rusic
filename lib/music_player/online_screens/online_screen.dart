import 'dart:async';
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
  StreamSubscription<void>? _configSubscription;

  @override
  void initState() {
    super.initState();
    _checkConfigAndFetch();
    _configSubscription = CredentialsManager().configStream.listen((_) {
      _checkConfigAndFetch(forceRefresh: true);
    });
  }

  @override
  void dispose() {
    _configSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkConfigAndFetch({bool forceRefresh = false}) async {
    if (forceRefresh && mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final credentials = CredentialsManager();
    final supaConfigs = await credentials.getSupabaseConfigurations();
    final serverConfigs = await credentials.getServerConfigurations();

    final hasSupa = supaConfigs.isNotEmpty;
    final hasServer = serverConfigs.isNotEmpty;

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

    if (cachedSongs.isNotEmpty && !forceRefresh) {
      if (mounted) {
        setState(() {
          _songsFuture = Future.value(cachedSongs);
          _isLoading = false;
        });
      }
      // Update cache in the background
      _fetchAndUpdateCache(supaConfigs, serverConfigs);
    } else {
      if (mounted) {
        setState(() {
          _songsFuture = _fetchAndUpdateCache(supaConfigs, serverConfigs);
          _isLoading = false;
        });
      }
    }
  }

  Future<List<OnlineSong>> _fetchAndUpdateCache(
    List<Map<String, String>> supaConfigs,
    List<Map<String, String>> serverConfigs,
  ) async {
    List<OnlineSong> combinedSongs = [];

    // 1. Fetch from all Supabase configs
    for (final config in supaConfigs) {
      if (config['url'] != null && config['apiKey'] != null) {
        try {
          final tableName = config['tableName'] ?? 'Online';
          final supa = SupabaseConnection(
            supabaseUrl: config['url']!,
            supabaseAnonKey: config['apiKey']!,
            tableName: tableName,
          );
          final rawSongs = await supa.fetchOnlineSongsRaw();
          combinedSongs.addAll(rawSongs);
        } catch (e) {
          print('Error fetching Supabase (${config['tableName']}): $e');
        }
      }
    }

    // 2. Fetch from all HTTP Servers
    for (final config in serverConfigs) {
      if (config['serverAddress'] != null &&
          config['serverAddress']!.isNotEmpty) {
        try {
          final serverName = config['serverName'] ?? config['serverAddress'];
          final httpManager = HTTPServerManager(
            serverAddress: config['serverAddress']!,
            serverName: serverName,
          );
          final songs = await httpManager.fetchSongs();
          // Ensure the source matches the user-configured serverName.
          final taggedSongs = songs
              .map(
                (s) => OnlineSong(
                  title: s.title,
                  url: s.url,
                  artist: s.artist,
                  album: s.album,
                  source: serverName,
                ),
              )
              .toList();
          combinedSongs.addAll(taggedSongs);
        } catch (e) {
          print('Error fetching Server (${config['serverAddress']}): $e');
        }
      }
    }

    if (combinedSongs.isNotEmpty) {
      await DatabaseManager.instance.cacheOnlineSongs(combinedSongs);
    } else if (supaConfigs.isEmpty && serverConfigs.isEmpty) {
      // Clear cache if all configs are explicitly gone.
      await DatabaseManager.instance.cacheOnlineSongs([]);
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
