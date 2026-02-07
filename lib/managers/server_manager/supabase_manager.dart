import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:music_controller/ui/media_ui.dart';

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
      print('Supabase connection error: $e');
      return false;
    }
  }

  /// Fetches all songs from the Supabase table and converts them to OnlineSong objects
  Future<List<OnlineSong>> fetchOnlineSongs() async {
    try {
      print('Starting fetchOnlineSongs from table: $tableName');
      final response = await client.from(tableName).select();
      print('Raw response type: ${response.runtimeType}');
      print('Raw response: $response');

      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
        response as List,
      );
      print('Fetched ${data.length} songs from Supabase');
      if (data.isNotEmpty) {
        print('First song data: ${data.first}');
        print('First song keys: ${data.first.keys}');
      }
      final songs = data.map((map) => OnlineSong.fromMap(map)).toList();
      print('Converted to ${songs.length} OnlineSong objects');
      if (songs.isNotEmpty) {
        print(
          'First song - Title: ${songs.first.title}, URL: ${songs.first.url}',
        );
      }
      return songs;
    } catch (e, stackTrace) {
      print('ERROR in fetchOnlineSongs: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
