// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnlineScreenLoginSuccess extends StatefulWidget {
  final void Function() onLogout;
  const OnlineScreenLoginSuccess({super.key, required this.onLogout});

  @override
  State<OnlineScreenLoginSuccess> createState() =>
      OnlineScreenLoginSuccessState();
}

class OnlineScreenLoginSuccessState extends State<OnlineScreenLoginSuccess> {
  String _tableName = 'Online';

  @override
  void initState() {
    super.initState();
    _loadTableName();
  }

  Future<void> _loadTableName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tableName = prefs.getString('supabaseTableName') ?? 'Online';
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                _tableName,
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
            // floatingActionButton: FloatingActionButton(onPressed: () {}),
            backgroundColor: Colors.transparent,
            body: CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(left: 5, bottom: 5),
                  sliver: SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      childAspectRatio: 3,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                    ),
                    itemCount: 50,
                    itemBuilder: (context, i) => Container(
                      margin: EdgeInsets.only(right: 5, top: 5),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(50, 50, 50, 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          "Online Song Item ${i + 1}",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: SizedBox(height: 100),
                ),
              ],
            ),
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
