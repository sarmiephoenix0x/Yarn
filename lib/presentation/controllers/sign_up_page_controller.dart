import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/widgets/custom_snackbar.dart';
import '../screens/select_country/select_country.dart';

class SignUpPageController extends ChangeNotifier {
  final FocusNode _userNameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();
  late SharedPreferences prefs;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;

  SignUpPageController(
      {required this.onToggleDarkMode, required this.isDarkMode}) {
    initialize();
  }

//public getters
  bool get isLoading => _isLoading;
  bool get rememberMe => _rememberMe;

  TextEditingController get userNameController => _userNameController;
  TextEditingController get passwordController => _passwordController;

  FocusNode get userNameFocusNode => _userNameFocusNode;
  FocusNode get passwordFocusNode => _passwordFocusNode;

  void setRememberMe(bool? value) {
    _rememberMe = value!;
    notifyListeners();
  }

  void initialize() {
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> submitForm(BuildContext context) async {
    if (prefs == null) {
      await _initializePrefs();
    }

    final String username = userNameController.text.trim();
    final String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      CustomSnackbar.show(
        'All fields are required.',
        isError: true,
      );
      return;
    }

    // Validate password length
    if (password.length < 6) {
      CustomSnackbar.show(
        'Password must be at least 6 characters.',
        isError: true,
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectCountry(
            key: UniqueKey(),
            onToggleDarkMode: onToggleDarkMode,
            isDarkMode: isDarkMode,
            username: username,
            password: password),
      ),
    );

    _isLoading = false;
    notifyListeners();
  }
}
