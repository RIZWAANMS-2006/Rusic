import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_win/video_player_win.dart';
import 'package:music_controller/Settings/settings.dart';
import 'package:weather_animation/weather_animation.dart';
import '../Managers/weather_manager.dart';

late dynamic controller_darkmode;
late dynamic controller_lightmode;

class WeatherBackground extends StatefulWidget {
  const WeatherBackground({super.key});

  @override
  State<WeatherBackground> createState() {
    return WeatherBackgroundState();
  }
}

class WeatherBackgroundState extends State<WeatherBackground> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: WeatherBackgroundFunction(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SizedBox.expand(child: snapshot.data);
        } else {
          return Align(
            alignment: AlignmentGeometry.xy(10, 1),
            child: CircularProgressIndicator(color: Colors.red),
          );
        }
      },
    );
  }
}
