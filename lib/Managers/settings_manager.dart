import "package:shared_preferences/shared_preferences.dart";

class SettingsManager {
  static late SharedPreferences userSettings;

  static Future<void> init() async {
    userSettings = await SharedPreferences.getInstance();
  }

  //Get Functions
  static bool get getDarkMode => userSettings.getBool('darkMode') ?? true;
  static String get getFontFamily =>
      userSettings.getString('fontFamily') ?? "normal";
  static String get getLastSongPlayedName =>
      userSettings.getString('lastSongPlayedName') ?? "No Song is Playing...";
  static String get getLastSongPlayedPath =>
      userSettings.getString('lastSongPlayedPath') ?? "";
  static int get getCrossfadeDuration =>
      userSettings.getInt('crossfadeDuration') ?? 0;

  //Set Functions
  static Future<void> setDarkMode(bool value) async {
    await userSettings.setBool('darkMode', value);
  }

  static Future<void> setFontFamily(String value) async {
    await userSettings.setString('fontFamily', value);
  }

  static Future<void> setLastSongPlayedName(String value) async {
    await userSettings.setString('lastSongPlayedName', value);
  }

  static Future<void> setLastSongPlayedPath(String value) async {
    await userSettings.setString('lastSongPlayedPath', value);
  }

  static Future<void> setCrossfadeDuration(int value) async {
    await userSettings.setInt('crossfadeDuration', value);
  }

  static Future<void> setDefaults() async {
    await userSettings.setBool('darkMode', true);
    await userSettings.setString('fontFamily', "normal");
    await userSettings.setInt('crossfadeDuration', 0);
  }
}
