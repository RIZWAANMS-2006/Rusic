import 'package:flutter/material.dart';

class OnlineScreenLogin extends StatefulWidget {
  final void Function(String url, String apiKey) onSubmit;

  const OnlineScreenLogin({super.key, required this.onSubmit});

  @override
  State<OnlineScreenLogin> createState() => OnlineScreenLoginState();
}

class OnlineScreenLoginState extends State<OnlineScreenLogin>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  TextEditingController urlController = TextEditingController();
  TextEditingController apiKeyController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
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
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
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
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Login Tab
                              SingleChildScrollView(
                                child: Column(
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
                              ),
                              // Register Tab
                              SingleChildScrollView(
                                child: Column(
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
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Enter Valid Server Address';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
          ],
        ),
      ),
    );
  }
}
