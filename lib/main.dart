import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yarn/intro_page.dart';
import 'package:yarn/main_app.dart';
import 'chat_provider.dart'; // Make sure this is correctly imported

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'yarnAccessToken');
  final prefs = await SharedPreferences.getInstance();
  bool? isDarkMode = prefs.getBool('isDarkMode') ?? false; // Default to false if not set

  final bool isLoggedIn = accessToken != null;
  runApp(MyApp(isLoggedIn: isLoggedIn, isDarkMode: isDarkMode));
}

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.black,
  iconTheme: const IconThemeData(color: Colors.black),
  textTheme: TextTheme(
    bodyLarge: const TextStyle(color: Colors.black),
    bodyMedium: const TextStyle(color: Colors.black),
    titleLarge: const TextStyle(color: Colors.black),
    labelSmall: TextStyle(color: Colors.grey[700]), // More visible grey for labels
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.white,
  iconTheme: const IconThemeData(color: Colors.white),
  textTheme: TextTheme(
    bodyLarge: const TextStyle(color: Colors.white),
    bodyMedium: const TextStyle(color: Colors.white),
    titleLarge: const TextStyle(color: Colors.white),
    labelSmall: TextStyle(color: Colors.grey[400]), // Lighter grey for dark mode labels
  ),
);

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final bool isDarkMode;

  const MyApp({Key? key, required this.isLoggedIn, required this.isDarkMode}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  void toggleDarkMode(bool isDark) async {
    setState(() {
      _isDarkMode = isDark;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatProvider(), // Providing the ChatProvider here
      child: MaterialApp(
        title: 'Yarn',
        theme: lightTheme, // Use the custom light theme
        darkTheme: darkTheme, // Use the custom dark theme
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light, // Automatically switch between themes
        home: widget.isLoggedIn
            ? MainApp(onToggleDarkMode: toggleDarkMode, isDarkMode: _isDarkMode)
            : IntroPage(onToggleDarkMode: toggleDarkMode, isDarkMode: _isDarkMode),
      ),
    );
  }
}
