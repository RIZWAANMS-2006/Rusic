import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<List<Map<String, dynamic>>> fetchSongs() async {
    final response = await client.from(tableName).select();
    return List<Map<String, dynamic>>.from(response as List);
  }
}
