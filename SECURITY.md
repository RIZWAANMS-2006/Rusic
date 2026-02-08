# Secure Storage Implementation

## Overview
This project uses **FlutterSecureStorage** to securely store sensitive data like API keys, URLs, and table names. The data is encrypted on device storage, making it much more secure than plain text storage methods like SharedPreferences.

## What's Secured
- **Supabase URL**: Your Supabase project URL
- **Supabase Anon Key**: Your Supabase anonymous key
- **Table Name**: Your Supabase table name

## How It Works

### CredentialsManager
The `CredentialsManager` class (`lib/managers/credentials_manager.dart`) provides a simple interface for storing and retrieving sensitive data:

```dart
final credentials = CredentialsManager();

// Save credentials
await credentials.saveSupabaseCredentials(
  url: 'your_url',
  apiKey: 'your_key',
  tableName: 'your_table',
);

// Retrieve credentials
final credentialsData = await credentials.getSupabaseCredentials();
final url = credentialsData['url'];
final apiKey = credentialsData['apiKey'];
final tableName = credentialsData['tableName'];

// Clear credentials (logout)
await credentials.clearSupabaseCredentials();
```

## Configuration File (api_key.json)

### ⚠️ Security Notice
The `api_key.json` file contains sensitive credentials and should **NEVER** be committed to version control. It's already added to `.gitignore` to prevent accidental commits.

### Setup
1. Copy `api_key.example.json` to `api_key.json`
2. Replace the placeholder values with your actual credentials:
   ```json
   {
       "SUPABASE_URL": "https://your-project.supabase.co",
       "SUPABASE_ANON_KEY": "your_actual_anon_key_here"
   }
   ```

## Migration from SharedPreferences

### What Changed
Previously, sensitive data was stored using `SharedPreferences`, which stores data in **plain text**. This has been migrated to `FlutterSecureStorage`, which **encrypts** all stored data.

### Files Updated
- ✅ `lib/music_player/online_screens/online_screen.dart`
- ✅ `lib/music_player/online_screens/online_screen_login_success.dart`

### Storage Keys Changed
**Old (SharedPreferences):**
- `supabaseUrl`
- `supabaseAnonKey`
- `supabaseTableName`

**New (SecureStorage):**
- `secure_supabase_url`
- `secure_supabase_anon_key`
- `secure_supabase_table_name`

## Platform-Specific Encryption

### Android
- Uses `EncryptedSharedPreferences` with AES encryption
- Keys are stored in Android Keystore

### iOS
- Uses iOS Keychain
- Data is accessible after first device unlock

### Windows/Linux/macOS
- Uses platform-specific secure storage mechanisms
- Data is encrypted at the OS level

## Best Practices

1. **Never log sensitive data**: Avoid printing API keys or credentials in console logs
2. **Use environment variables**: For development, consider using environment variables
3. **Rotate keys**: Regularly rotate your API keys and update them securely
4. **Clear on logout**: Always clear secure storage when users log out
5. **Handle errors**: Always wrap secure storage calls in try-catch blocks

## Testing

To test if your credentials are properly stored:

```dart
final credentials = CredentialsManager();
final hasCredentials = await credentials.hasSupabaseCredentials();
print('Has credentials: $hasCredentials');
```

## Troubleshooting

### Data not persisting
- Ensure you're not running in debug mode without proper platform setup
- Check that flutter_secure_storage is properly configured for your platform

### Migration from old data
If you have existing data in SharedPreferences, you'll need to log in again. The old plain-text data will not be automatically migrated for security reasons.

## Additional Resources
- [FlutterSecureStorage Documentation](https://pub.dev/packages/flutter_secure_storage)
- [Supabase Security Best Practices](https://supabase.com/docs/guides/api/security)
