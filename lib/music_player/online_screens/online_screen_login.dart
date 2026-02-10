import 'package:flutter/material.dart';

class OnlineScreenLogin extends StatefulWidget {
  final void Function(String url, String apiKey, String tableName) onSubmit;

  const OnlineScreenLogin({super.key, required this.onSubmit});

  @override
  State<OnlineScreenLogin> createState() => OnlineScreenLoginState();
}

class OnlineScreenLoginState extends State<OnlineScreenLogin>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  TextEditingController urlController = TextEditingController();
  TextEditingController apiKeyController = TextEditingController();
  TextEditingController tableNameController = TextEditingController();
  TextEditingController serverAddressController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild when tab changes
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    urlController.dispose();
    apiKeyController.dispose();
    tableNameController.dispose();
    serverAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
        child: Column(
          children: [
            Center(
              child: Container(
                height: 40,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey[400],
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(text: "Supabase"),
                    Tab(text: "Server"),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: Color.fromRGBO(39, 39, 39, 1),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    // Indexed list with AnimatedSize for dynamic height
                    AnimatedSize(
                      duration: Duration(milliseconds: 200),
                      child: [
                        // Supabase Tab
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            Text("Enter Table Name"),
                            TextFormField(
                              controller: tableNameController,
                              validator: (value) {
                                if (_tabController.index != 0) {
                                  return null;
                                }
                                if (value == null || value.isEmpty) {
                                  return 'Enter Valid Table Name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            Text("Enter URL"),
                            TextFormField(
                              controller: urlController,
                              validator: (value) {
                                if (_tabController.index != 0) {
                                  return null;
                                }
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
                                if (_tabController.index != 0) {
                                  return null;
                                }
                                if (value == null || value.isEmpty) {
                                  return 'Enter Valid Anon-API Key';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        // Server Tab
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                "Server Configuration",
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Text("Server Address"),
                            TextFormField(
                              controller: serverAddressController,
                              validator: (value) {
                                if (_tabController.index != 1) {
                                  return null;
                                }
                                if (value == null || value.isEmpty) {
                                  return 'Enter Valid Server Address';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ][_tabController.index],
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FilledButton(
                        onPressed: () {
                          print(
                            'Validating form on tab: ${_tabController.index}',
                          );
                          print('URL: ${urlController.text}');
                          print('API Key: ${apiKeyController.text}');
                          final formState = _formKey.currentState;
                          if (formState != null && formState.validate()) {
                            print('Form validated successfully');
                            widget.onSubmit(
                              urlController.text.trim(),
                              apiKeyController.text.trim(),
                              tableNameController.text.trim(),
                            );
                          } else {
                            print('Form validation failed');
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
          ],
        ),
      ),
    );
  }
}
