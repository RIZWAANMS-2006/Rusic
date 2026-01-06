// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:music_controller/music_player/music_player_screens/online_screen.dart';

class OnlineScreenLoginSuccess extends StatefulWidget {
  final void Function() onLogout;
  const OnlineScreenLoginSuccess({super.key, required this.onLogout});

  @override
  State<OnlineScreenLoginSuccess> createState() =>
      OnlineScreenLoginSuccessState();
}

class OnlineScreenLoginSuccessState extends State<OnlineScreenLoginSuccess> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "Supabase",
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: "Normal",
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: Colors.transparent,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Transform.scale(
                    scale: 0.9,
                    child: FilledButton(
                      onPressed: widget.onLogout,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        spacing: 5,
                        children: [
                          Icon(Icons.power_settings_new_rounded),
                          Text("Logout"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            body: Container()
            
            // CustomScrollView(
            //   physics: BouncingScrollPhysics(),
            //   slivers: [
            //     SliverPadding(
            //       padding: const EdgeInsets.only(left: 5, bottom: 5),
            //       sliver: SliverGrid.builder(
            //         gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            //           maxCrossAxisExtent: 400,
            //           childAspectRatio: 3,
            //           mainAxisSpacing: 0,
            //           crossAxisSpacing: 0,
            //         ),
            //         itemCount: 50,
            //         itemBuilder: (context, i) => Container(
            //           margin: EdgeInsets.only(right: 5, top: 5),
            //           decoration: BoxDecoration(
            //             color: Color.fromRGBO(50, 50, 50, 1),
            //             borderRadius: BorderRadius.circular(5),
            //           ),
            //           child: Center(
            //             child: Text(
            //               "Online Song Item ${i + 1}",
            //               style: TextStyle(color: Colors.white),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
                // SliverFillRemaining(
                //   hasScrollBody: false,
                //   child: SizedBox(height: 100),
                // ),
              // ],
            // ),
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: FilledButton(
                    onPressed: widget.onLogout,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    child: Row(
                      spacing: 5,
                      children: [
                        Icon(Icons.power_settings_new_rounded),
                        Text("Logout"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            body: Center(child: Text("Online Music Screen Login Success")),
          );
        }
      },
    );
  }
}