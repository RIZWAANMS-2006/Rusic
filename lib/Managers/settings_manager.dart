import "package:shared_preferences/shared_preferences.dart";

class SettingsManager {
  static late SharedPreferences userSettings;

  static Future<void> init() async {
    userSettings = await SharedPreferences.getInstance();
  }

  //Get Functions

  static bool get getDarkMode => userSettings.getBool('darkMode') ?? true;
  static String get getFontFamily => userSettings.getString('fontFamily') ?? "normal";
  

  //Set Functions

  static Future<void> setDarkMode(bool value) async{
    await userSettings.setBool('darkMode', value);
  }

  static Future<void> setFontFamily(String value) async{
    await userSettings.setString('fontFamily', value);
  }
}
