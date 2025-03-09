import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.black,
    iconTheme: const IconThemeData(color: Colors.black),
    textTheme: TextTheme(
      bodyLarge: const TextStyle(color: Colors.black),
      bodyMedium: const TextStyle(color: Colors.black),
      titleLarge: const TextStyle(color: Colors.black),
      labelSmall: TextStyle(color: Colors.grey[700]),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.white,
    iconTheme: const IconThemeData(color: Colors.white),
    textTheme: TextTheme(
      bodyLarge: const TextStyle(color: Colors.white),
      bodyMedium: const TextStyle(color: Colors.white),
      titleLarge: const TextStyle(color: Colors.white),
      labelSmall: TextStyle(color: Colors.grey[400]),
    ),
  );
}
