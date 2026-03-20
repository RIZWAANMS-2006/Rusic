import 'package:flutter/material.dart';
import 'package:Rusic/managers/credentials_manager.dart';

class ServerConfigurationScreen extends StatefulWidget {
  const ServerConfigurationScreen({super.key});

  @override
  State<ServerConfigurationScreen> createState() =>
      _ServerConfigurationScreenState();
}

class _ServerConfigurationScreenState extends State<ServerConfigurationScreen> {
  TextEditingController serverNameController = TextEditingController();
  TextEditingController serverAddressController = TextEditingController();
  final _serverFormKey = GlobalKey<FormState>();
  final _credentialsManager = CredentialsManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Server Configuration")),
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(36, 33, 33, 1),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Form(
            key: _serverFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                const Text("Server Name"),
                TextFormField(
                  controller: serverNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Valid Server Name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text("Server Address"),
                TextFormField(
                  controller: serverAddressController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Valid Server Address';
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
                        if (_serverFormKey.currentState?.validate() ?? false) {
                          await _credentialsManager.saveServerAddress(
                            serverAddressController.text.trim(),
                          );
                          await _credentialsManager.saveServerName(
                            serverNameController.text.trim(),
                          );
                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Server configuration saved successfully!',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
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
