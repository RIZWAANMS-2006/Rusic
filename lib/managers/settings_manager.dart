import 'package:flutter/cupertino.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:flutter/material.dart';

class SettingsManager {
  ThemeData lightTheme = ThemeData(
    fontFamily: 'Asimovian',
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
    ),
    scaffoldBackgroundColor: const Color.fromRGBO(244, 248, 251,1),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black),
      bodyLarge: TextStyle(color: Colors.black),
      bodySmall: TextStyle(color: Colors.black),
      displayLarge: TextStyle(color: Colors.black),
      displayMedium: TextStyle(color: Colors.black),
      displaySmall: TextStyle(color: Colors.black),
      headlineLarge: TextStyle(color: Colors.black),
      headlineMedium: TextStyle(color: Colors.black),
      headlineSmall: TextStyle(color: Colors.black),
      titleLarge: TextStyle(color: Colors.black87),
      titleMedium: TextStyle(color: Colors.black87),
      titleSmall: TextStyle(color: Colors.black87),
    ),
  );
  ThemeData darkTheme = ThemeData(
    fontFamily: 'Asimovian',
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: Colors.redAccent,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Color.fromRGBO(26, 26, 26, 1),
    ),
    scaffoldBackgroundColor: const Color.fromRGBO(26, 26, 26, 1),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
      bodyLarge: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
      bodySmall: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
      displayLarge: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
      displayMedium: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
      displaySmall: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
      headlineLarge: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
      headlineMedium: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
      headlineSmall: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
      titleLarge: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
      titleMedium: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
      titleSmall: TextStyle(color: Color.fromRGBO(255, 245, 245, 1)),
    ),
  );

  static late SharedPreferences userSettings;

  static const String _systemThemeKey = 'systemTheme';
  static final ValueNotifier<String> systemTheme = ValueNotifier('System');
  static const String _appUiKey = 'appUI';
  static const String _crossfadeDurationKey = 'crossfadeDuration';
  static const String _videoPreferenceKey = 'videoPreference';
  static const String _playHighlightsKey = 'playHighlights';
  static const String _highlightsDurationKey = 'highlightsDuration';
  static const String _skipAtBeginningKey = 'skipAtBeginning';
  static const String _skipAtEndKey = 'skipAtEnd';
  static const String _fontFamilyKey = 'fontFamily';
  static const String _lastSongPlayedNameKey = 'lastSongPlayedName';
  static const String _lastSongPlayedPathKey = 'lastSongPlayedPath';
  static const String _lastLibraryTabKey = 'lastLibraryTab';

  static Future<void> init() async {
    userSettings = await SharedPreferences.getInstance();
    systemTheme.value = userSettings.getString(_systemThemeKey) ?? 'System';
  }

  // Get Functions
  static String get getSystemTheme =>
      userSettings.getString(_systemThemeKey) ?? "System";
  static String get getAppUI =>
      userSettings.getString(_appUiKey) ?? "Minimalistic";
  static double get getCrossfadeDuration =>
      userSettings.getDouble(_crossfadeDurationKey) ?? 0.0;
  static String get getVideoPreference =>
      userSettings.getString(_videoPreferenceKey) ?? "Landscape Contain";
  static bool get getPlayHighlights =>
      userSettings.getBool(_playHighlightsKey) ?? true;
  static String get getHighlightsDuration =>
      userSettings.getString(_highlightsDurationKey) ?? "30";
  static String get getSkipAtBeginning =>
      userSettings.getString(_skipAtBeginningKey) ?? "0";
  static String get getSkipAtEnd =>
      userSettings.getString(_skipAtEndKey) ?? "10";

  // Previously existing gets
  static String get getFontFamily {
    final value = userSettings.getString(_fontFamilyKey);
    // Keep backward compatibility with older persisted values.
    if (value == null || value == "normal") {
      return "System Font";
    }
    return value;
  }

  static String get getLastSongPlayedName =>
      userSettings.getString(_lastSongPlayedNameKey) ?? "No Song is Playing...";
  static String get getLastSongPlayedPath =>
      userSettings.getString(_lastSongPlayedPathKey) ?? "";
  static int get getLastLibraryTab =>
      userSettings.getInt(_lastLibraryTabKey) ?? 0;

  // Set Functions
  static Future<void> setSystemTheme(String value) async {
    await userSettings.setString(_systemThemeKey, value);
    systemTheme.value = value;
  }

  static Future<void> setAppUI(String value) async {
    await userSettings.setString(_appUiKey, value);
  }

  static Future<void> setCrossfadeDuration(double value) async {
    await userSettings.setDouble(_crossfadeDurationKey, value);
  }

  static Future<void> setVideoPreference(String value) async {
    await userSettings.setString(_videoPreferenceKey, value);
  }

  static Future<void> setPlayHighlights(bool value) async {
    await userSettings.setBool(_playHighlightsKey, value);
  }

  static Future<void> setHighlightsDuration(String value) async {
    await userSettings.setString(_highlightsDurationKey, value);
  }

  static Future<void> setSkipAtBeginning(String value) async {
    await userSettings.setString(_skipAtBeginningKey, value);
  }

  static Future<void> setSkipAtEnd(String value) async {
    await userSettings.setString(_skipAtEndKey, value);
  }

  // Previously existing sets
  static Future<void> setFontFamily(String value) async {
    await userSettings.setString(_fontFamilyKey, value);
  }

  static Future<void> setLastSongPlayedName(String value) async {
    await userSettings.setString(_lastSongPlayedNameKey, value);
  }

  static Future<void> setLastSongPlayedPath(String value) async {
    await userSettings.setString(_lastSongPlayedPathKey, value);
  }

  static Future<void> setLastLibraryTab(int value) async {
    await userSettings.setInt(_lastLibraryTabKey, value);
  }

  static Future<void> setDefaults() async {
    await userSettings.setString(_systemThemeKey, "System");
    systemTheme.value = "System";
    await userSettings.setString(_appUiKey, "Minimalistic");
    await userSettings.setDouble(_crossfadeDurationKey, 0.0);
    await userSettings.setString(_videoPreferenceKey, "Landscape Contain");
    await userSettings.setBool(_playHighlightsKey, true);
    await userSettings.setString(_highlightsDurationKey, "30");
    await userSettings.setString(_skipAtBeginningKey, "0");
    await userSettings.setString(_skipAtEndKey, "10");
    await userSettings.setString(_fontFamilyKey, "System Font");
  }
}
