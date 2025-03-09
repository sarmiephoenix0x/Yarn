import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/widgets/custom_snackbar.dart';
import '../screens/reset_password/reset_password.dart';

class SignUpOtpController extends ChangeNotifier {
  String otpCode = "";
  bool _isLoading = false;

  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  final String phoneNumber;
  final String email;

  SignUpOtpController(
      {required this.onToggleDarkMode,
      required this.isDarkMode,
      required this.phoneNumber,
      required this.email});

//public getters
  bool get isLoading => _isLoading;

  void handleOtpInputComplete(String code, BuildContext context) async {
    otpCode = code;
    notifyListeners();
    await submitOtp(context);
  }

  Future<void> submitOtp(BuildContext context) async {
    // Show loading indicator

    _isLoading = true;
    notifyListeners();

    try {
      // Send the POST request
      final response = await http.post(
        Uri.parse('https://yarnapi-fuu0.onrender.com/api/auth/otp-submit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otpCode}),
      );

      final responseData = json.decode(response.body);

      print('Response Data: $responseData');

      if (response.statusCode == 200) {
        // Fetch userId and OTP from response
        final int userId = responseData['data']['userId'];
        final String returnedOtp = responseData['data']['OTP'];

        // Navigate to another page and pass userId and OTP
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPassword(
              key: UniqueKey(),
              onToggleDarkMode: onToggleDarkMode,
              isDarkMode: isDarkMode,
              userId: userId, // Pass userId
              otp: returnedOtp, // Pass OTP
            ),
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
