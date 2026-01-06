import 'package:supabase_flutter/supabase_flutter.dart';

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
