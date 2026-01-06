// ignore_for_file: unused_field

import 'dart:ui';
import 'package:flutter/material.dart';

class OnlineScreenLogin extends StatefulWidget {
  final void Function(String url, String apiKey) onSubmit;

  const OnlineScreenLogin({super.key, required this.onSubmit});

  @override
  State<OnlineScreenLogin> createState() => OnlineScreenLoginState();
}

class OnlineScreenLoginState extends State<OnlineScreenLogin> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController urlController = TextEditingController();
  TextEditingController apiKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
        child: Container(
          height: 330,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: Color.fromRGBO(39, 39, 39, 1),
          ),
          child: Form(
            key: _formKey,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        "Supabase Configuration",
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text("Enter URL"),
                    TextFormField(
                      controller: urlController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter Valid URL';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Text("Enter Anon-API Key"),
                    TextFormField(
                      controller: apiKeyController,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter Valid Anon-API Key';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                Positioned(
                  bottom: 10,
                  right: 0,
                  child: FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSubmit(
                          urlController.text.trim(),
                          apiKeyController.text.trim(),
                        );
                      }
                    },
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    child: Text("Connect"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
