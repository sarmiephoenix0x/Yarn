import 'package:flutter/material.dart';
import 'package:yarn/intro_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yarn/main_app.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'yarnAccessToken');
  final bool isLoggedIn = accessToken != null;
  runApp(MyApp(isLoggedIn: accessToken != null));
}


class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yarn',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        fontFamily: 'Poppins', // Apply custom font
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      home: isLoggedIn ? MainApp(key: UniqueKey()) : const IntroPage(),
    );
  }
}
