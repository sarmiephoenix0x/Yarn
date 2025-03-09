import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/widgets/custom_snackbar.dart';
import '../screens/successful_psw_reset_page/successful_psw_reset_page.dart';

class ResetPasswordController extends ChangeNotifier {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();

  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _password2FocusNode = FocusNode();

  bool _isLoading = false;
  final storage = const FlutterSecureStorage();
  late SharedPreferences prefs;
  bool _isPasswordVisible = false;
  bool _isPasswordVisible2 = false;

  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  final int userId;
  final String otp;

  ResetPasswordController(
      {required this.onToggleDarkMode,
      required this.isDarkMode,
      required this.userId,
      required this.otp});

//public getters
  bool get isLoading => _isLoading;

  TextEditingController get passwordController => _passwordController;
  TextEditingController get password2Controller => _password2Controller;

  FocusNode get passwordFocusNode => _passwordFocusNode;
  FocusNode get password2FocusNode => _password2FocusNode;

  Future<void> resetPassword(BuildContext context) async {
    // Show loading indicator

    _isLoading = true;
    notifyListeners();

    try {
      // Send the POST request
      final response = await http.post(
        Uri.parse('https://yarnapi-fuu0.onrender.com/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'OTP': otp,
          'password': _passwordController.text.trim(),
          'confirmPassword': _password2Controller.text.trim(),
        }),
      );

      final responseData = json.decode(response.body);

      print('Response Data: $responseData');

      if (response.statusCode == 200) {
        // Fetch userId and OTP from response
        final int userId = responseData['data']['userId'];
        final String returnedOtp = responseData['data']['username'];
        final String token = responseData['data']['token'];

        print("$returnedOtp$token");

        // Navigate to another page and pass userId and OTP
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessfulResetPage(
                key: UniqueKey(),
                onToggleDarkMode: onToggleDarkMode,
                isDarkMode: isDarkMode),
          ),
        );
      } else if (response.statusCode == 400) {
        _isLoading = false;
        notifyListeners();
        final String message = responseData['message'];
        CustomSnackbar.show('Error: $message', isError: true);
      } else {
        _isLoading = false;
        notifyListeners();
        CustomSnackbar.show('An unexpected error occurred.', isError: true);
      }
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      CustomSnackbar.show('Network error. Please try again.', isError: true);
    }
  }
}
