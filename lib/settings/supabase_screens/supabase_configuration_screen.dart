import 'package:Rusic/managers/server_manager/supabase_manager.dart';
import 'package:Rusic/managers/credentials_manager.dart'; // Fix: Added missing import
import 'package:flutter/material.dart';

class SupabaseConfigurationScreen extends StatefulWidget {
  const SupabaseConfigurationScreen({super.key});

  @override
  State<SupabaseConfigurationScreen> createState() =>
      _SupabaseConfigurationScreenState();
}

class _SupabaseConfigurationScreenState
    extends State<SupabaseConfigurationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _credentialsManager =
      CredentialsManager(); // Fix: Defined the credentials manager instance
  TextEditingController urlController = TextEditingController();
  TextEditingController apiKeyController = TextEditingController();
  TextEditingController tableNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Supabase Configuration"),
        // leadingWidth: 30,
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(36, 33, 33, 1),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                const Text("Enter Table Name"),
                TextFormField(
                  controller: tableNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Valid Table Name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                const Text("Enter URL"),
                TextFormField(
                  controller: urlController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Valid URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                const Text("Enter Anon-API Key"),
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
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FilledButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          // Verify connection before saving
                          final connection = SupabaseConnection(
                            supabaseUrl: urlController.text.trim(),
                            supabaseAnonKey: apiKeyController.text.trim(),
                            tableName: tableNameController.text.trim(),
                          );

                          final isConnected = await connection.isConnected();

                          // Fix: Ensure widget is still mounted after async call
                          if (!mounted) return;

                          if (isConnected) {
                            await _credentialsManager.addSupabaseConfiguration({
                              'url': urlController.text.trim(),
                              'apiKey': apiKeyController.text.trim(),
                              'tableName': tableNameController.text.trim(),
                            });

                            // Fix: Check again after second async call
                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Supabase connected and saved successfully!',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Failed to connect to Supabase. Check your credentials.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      child: const Text("Save"),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
