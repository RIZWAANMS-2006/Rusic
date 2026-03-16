import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:Rusic/ui/media_ui.dart';
import '../database_manager.dart';

class SupabaseConnection {
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String tableName;
  late final SupabaseClient client;

  SupabaseConnection({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.tableName,
  }) {
    client = SupabaseClient(supabaseUrl, supabaseAnonKey);
  }

  Future<bool> isConnected() async {
    try {
      await client.from(tableName).select().limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Fetches all songs from the Supabase table and converts them to OnlineSong objects
  Future<List<OnlineSong>> fetchOnlineSongs() async {
    try {
      // First try to load from cache immediately to prevent blank screen
      final cachedSongs = await DatabaseManager.instance.getCachedOnlineSongs();
      if (cachedSongs.isNotEmpty) {
        // Update cache in the background
        _fetchAndUpdateCache();
        return cachedSongs;
      }

      // If cache is empty, await the fetch
      return await _fetchAndUpdateCache();
    } catch (e, stackTrace) {
      // On error, try to return cached songs as fallback
      final cachedSongs = await DatabaseManager.instance.getCachedOnlineSongs();
      if (cachedSongs.isNotEmpty) return cachedSongs;
      rethrow;
    }
  }

  Future<List<OnlineSong>> _fetchAndUpdateCache() async {
    final response = await client.from(tableName).select();

    final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
      response as List,
    );

    final songs = data.map((map) => OnlineSong.fromMap(map)).toList();

    if (songs.isNotEmpty) {
      await DatabaseManager.instance.cacheOnlineSongs(songs);
    }

    return songs;
  }
}
