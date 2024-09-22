import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Privacy extends StatefulWidget {
  const Privacy({super.key});

  @override
  PrivacyState createState() => PrivacyState();
}

class PrivacyState extends State<Privacy> with SingleTickerProviderStateMixin {
  bool isLoading = false;
  final storage = const FlutterSecureStorage();
  late SharedPreferences prefs;
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  int? _selectedRadioValue;
  bool _privateProfileMoved = false;

  @override
  void initState() {
    super.initState();
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _showCustomSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  // Wrap SingleChildScrollView with Expanded
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 20),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Image.asset(
                                'images/BackButton.png',
                                height: 25,
                                color:Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.05),
                            Expanded(
                              flex: 10,
                              child: Text(
                                'Privacy',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 20),
                              child: InkWell(
                                // Use InkWell for tap functionality
                                onTap: () {},
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'images/Privacy.png',
                                      height: 35,
                                      color:Theme.of(context).colorScheme.onSurface,
                                    ),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.065),
                                    Text(
                                      'Private profile',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15.0,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    const Spacer(),
                                    Switch(
                                      value: _privateProfileMoved,
                                      onChanged: (value) => {}, // Toggle the dark mode
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 20),
                              child: InkWell(
                                // Use InkWell for tap functionality
                                onTap: () {},
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'images/Muted.png',
                                      height: 35,
                                      color:Theme.of(context).colorScheme.onSurface,
                                    ),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.05),
                                    Text(
                                      'Muted',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15.0,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 20),
                              child: InkWell(
                                // Use InkWell for tap functionality
                                onTap: () {},
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'images/Hidden word.png',
                                      height: 35,
                                      color:Theme.of(context).colorScheme.onSurface,
                                    ),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.05),
                                    Text(
                                      'Hidden Words',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15.0,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 20),
                              child: InkWell(
                                // Use InkWell for tap functionality
                                onTap: () {},
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'images/Users.png',
                                      height: 35,
                                      color:Theme.of(context).colorScheme.onSurface,
                                    ),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.05),
                                    Text(
                                      'Profiles you follow',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15.0,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 20),
                              child: InkWell(
                                // Use InkWell for tap functionality
                                onTap: () {},
                                child: Row(
                                  children: [
                                    Text(
                                      'Other privacy settings',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15.0,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    const Spacer(),
                                    Image.asset(
                                      'images/Exit.png',
                                      height: 35,
                                      color:Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 20),
                              child: Text(
                                'Some settings, like restricting, apply to both threads and Instagram and can be managed on instagram.',
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                maxLines: 3,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 20),
                              child: InkWell(
                                // Use InkWell for tap functionality
                                onTap: () {},
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'images/Blocked.png',
                                      height: 35,
                                      color:Theme.of(context).colorScheme.onSurface,
                                    ),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.05),
                                    Text(
                                      'Blocked',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15.0,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    const Spacer(),
                                    Image.asset(
                                      'images/Exit.png',
                                      height: 35,
                                      color:Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
