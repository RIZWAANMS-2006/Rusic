import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

//File Handling for Settings
Future<Map<dynamic, dynamic>> settingsFunction() async {
  final dir = await getDownloadsDirectory();
  if (dir == null) {
    throw Exception("Downloads directory not found");
  }
  File settingsFile = File("${dir.path}/MyMusic/settings.json");
  Map<dynamic, dynamic> settingsData = {};
  if (await settingsFile.exists()) {
    String settingsJsonInfo = await settingsFile.readAsString();
    settingsData = jsonDecode(settingsJsonInfo);
    return settingsData;
  } else {
    settingsFile.create();
    Map<dynamic, dynamic> defaultSettings = {
      "mode": true,
      "bgstatus": 'Live Wallpaper',
    };
    settingsFile.writeAsString(jsonEncode(defaultSettings));
    String settingsJsonInfo = await settingsFile.readAsString();
    settingsData = jsonDecode(settingsJsonInfo);
    return settingsData;
  }
}

// Stream<Map<dynamic, dynamic>> FileSettings() async* {
//   yield await settingsFunction();
// }

var FileSettings = settingsFunction();

WidgetStateProperty<Icon> Switch_Icons =
    WidgetStateProperty.fromMap(<WidgetStatesConstraint, Icon>{
      WidgetState.selected: Icon(Icons.dark_mode),
      WidgetState.any: Icon(Icons.light_mode),
    });

String mainvalue = 'Live Wallpaper';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => Settings_UI_State();
}

class Settings_UI_State extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
