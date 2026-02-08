import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manager for securely storing sensitive credentials like API keys, URLs, and table names
/// Uses FlutterSecureStorage which encrypts data on device storage across all platforms
class CredentialsManager {
  static final CredentialsManager _instance = CredentialsManager._internal();
  factory CredentialsManager() => _instance;
  CredentialsManager._internal();

  // FlutterSecureStorage with platform-specific secure options
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    wOptions: WindowsOptions(useBackwardCompatibility: true),
    lOptions: LinuxOptions(),
    mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Key constants for secure storage
  static const String _keySupabaseUrl = 'secure_supabase_url';
  static const String _keySupabaseAnonKey = 'secure_supabase_anon_key';
  static const String _keySupabaseTableName = 'secure_supabase_table_name';

  /// Save Supabase URL securely
  Future<void> saveSupabaseUrl(String url) async {
    await _storage.write(key: _keySupabaseUrl, value: url);
  }

  /// Save Supabase API Key securely
  Future<void> saveSupabaseAnonKey(String apiKey) async {
    await _storage.write(key: _keySupabaseAnonKey, value: apiKey);
  }

  /// Save Supabase Table Name securely
  Future<void> saveSupabaseTableName(String tableName) async {
    await _storage.write(key: _keySupabaseTableName, value: tableName);
  }

  /// Save all Supabase credentials at once
  Future<void> saveSupabaseCredentials({
    required String url,
    required String apiKey,
    required String tableName,
  }) async {
    print('[CredentialsManager] Saving credentials...');
    print(
      '[CredentialsManager] URL: ${url.substring(0, 20)}... (length: ${url.length})',
    );
    print('[CredentialsManager] API Key length: ${apiKey.length}');
    print('[CredentialsManager] Table name: $tableName');

    try {
      // Save sequentially instead of parallel to avoid race conditions
      await _storage.write(key: _keySupabaseUrl, value: url);
      print('[CredentialsManager] URL saved');

      await _storage.write(key: _keySupabaseAnonKey, value: apiKey);
      print('[CredentialsManager] API Key saved');

      await _storage.write(key: _keySupabaseTableName, value: tableName);
      print('[CredentialsManager] Table name saved');

      // Verify the save by reading back
      final verifyUrl = await _storage.read(key: _keySupabaseUrl);
      final verifyKey = await _storage.read(key: _keySupabaseAnonKey);
      final verifyTable = await _storage.read(key: _keySupabaseTableName);

      print(
        '[CredentialsManager] Verification - URL: ${verifyUrl != null ? "✓" : "✗"}',
      );
      print(
        '[CredentialsManager] Verification - API Key: ${verifyKey != null ? "✓" : "✗"}',
      );
      print(
        '[CredentialsManager] Verification - Table: ${verifyTable != null ? "✓" : "✗"}',
      );

      print(
        '[CredentialsManager] All credentials saved and verified successfully',
      );
    } catch (e) {
      print('[CredentialsManager] ERROR saving credentials: $e');
      rethrow;
    }
  }

  /// Get Supabase URL
  Future<String?> getSupabaseUrl() async {
    return await _storage.read(key: _keySupabaseUrl);
  }

  /// Get Supabase API Key
  Future<String?> getSupabaseAnonKey() async {
    return await _storage.read(key: _keySupabaseAnonKey);
  }

  /// Get Supabase Table Name
  Future<String?> getSupabaseTableName() async {
    return await _storage.read(key: _keySupabaseTableName);
  }

  /// Get all Supabase credentials at once
  Future<Map<String, String?>> getSupabaseCredentials() async {
    print('[CredentialsManager] Reading credentials from secure storage...');

    try {
      // Read sequentially with individual logging
      final url = await _storage.read(key: _keySupabaseUrl);
      print(
        '[CredentialsManager] Read URL: ${url != null ? "exists (${url.length} chars)" : "NULL"}',
      );

      final apiKey = await _storage.read(key: _keySupabaseAnonKey);
      print(
        '[CredentialsManager] Read API Key: ${apiKey != null ? "exists (${apiKey.length} chars)" : "NULL"}',
      );

      final tableName = await _storage.read(key: _keySupabaseTableName);
      print('[CredentialsManager] Read Table: ${tableName ?? "NULL"}');

      // Debug: List all keys in storage
      final allKeys = await _storage.readAll();
      print(
        '[CredentialsManager] All keys in storage: ${allKeys.keys.toList()}',
      );

      return {'url': url, 'apiKey': apiKey, 'tableName': tableName};
    } catch (e) {
      print('[CredentialsManager] ERROR reading credentials: $e');
      rethrow;
    }
  }

  /// Remove all Supabase credentials (logout)
  Future<void> clearSupabaseCredentials() async {
    await Future.wait([
      _storage.delete(key: _keySupabaseUrl),
      _storage.delete(key: _keySupabaseAnonKey),
      _storage.delete(key: _keySupabaseTableName),
    ]);
  }

  /// Check if credentials exist
  Future<bool> hasSupabaseCredentials() async {
    final credentials = await getSupabaseCredentials();
    return credentials['url'] != null &&
        credentials['apiKey'] != null &&
        credentials['tableName'] != null;
  }

  /// Clear all stored data (use with caution)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
