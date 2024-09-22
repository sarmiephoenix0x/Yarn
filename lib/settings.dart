import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yarn/privacy.dart';

class Settings extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  const Settings({super.key,required this.onToggleDarkMode, required this.isDarkMode});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  final storage = const FlutterSecureStorage();
  late SharedPreferences prefs;
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  int? _selectedRadioValue;
  late bool _darkModeMoved;

  @override
  void initState() {
    super.initState();
    _darkModeMoved = widget.isDarkMode;
    _initializePrefs();
  }

  @override
  void didUpdateWidget(Settings oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local state if the parent widget's dark mode value changes
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      setState(() {
        _darkModeMoved = widget.isDarkMode;
      });
    }
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

  void _toggleDarkMode(bool value) {
    setState(() {
      _darkModeMoved = value; // Update the state
    });
    widget.onToggleDarkMode(value);
    // Simulate a delay to allow for transitions
    Future.delayed(Duration(milliseconds: 100), () {
      // After the delay, you can ensure the switch reflects the current mode
      if (_darkModeMoved != widget.isDarkMode) {
        setState(() {
          _darkModeMoved = widget.isDarkMode; // Adjust position
        });
      }
    });
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
                                'Settings',
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
                                      'images/Bell.png',
                                      height: 35,
                                      color:Theme.of(context).colorScheme.onSurface,
                                    ),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.05),
                                    Text(
                                      'Notifications',
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
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Privacy(key: UniqueKey()),
                                    ),
                                  );
                                },
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
                                      'Privacy',
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
                                      'images/AccountSettings.png',
                                      height: 35,
                                      color:Theme.of(context).colorScheme.onSurface,
                                    ),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.05),
                                    Text(
                                      'Account',
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
                                      'images/Language.png',
                                      height: 35,
                                      color:Theme.of(context).colorScheme.onSurface,
                                    ),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.05),
                                    Text(
                                      'Language',
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
                                      'images/Help.png',
                                      height: 35,
                                      color:Theme.of(context).colorScheme.onSurface,
                                    ),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.05),
                                    Text(
                                      'Help',
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
                                      'images/About.png',
                                      height: 35,
                                      color:Theme.of(context).colorScheme.onSurface,
                                    ),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.05),
                                    Text(
                                      'About',
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
                                      'images/tabler_brightness-filled.png',
                                      height: 35,
                                      color:Theme.of(context).colorScheme.onSurface,
                                    ),
                                    SizedBox(
                                        width:
                                        MediaQuery.of(context).size.width *
                                            0.065),
                                    Text(
                                      'Dark Mode',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15.0,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                    const Spacer(),
                                    Switch(
                                      value: _darkModeMoved,
                                      onChanged: _toggleDarkMode,
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
                                child: Text(
                                  'Log out',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 15.0,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
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
