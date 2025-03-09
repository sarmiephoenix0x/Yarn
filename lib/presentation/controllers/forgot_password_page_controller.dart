import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/widgets/custom_snackbar.dart';
import '../screens/sign_up_otp/sign_up_otp.dart';

class ForgotPasswordPageController extends ChangeNotifier {
  bool _isLoading = false;
  bool isLoading2 = false;
  int? _selectedRadioValue;
  bool _showInitialContent = true;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  String _phoneNumber = '';

  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;

  ForgotPasswordPageController(
      {required this.onToggleDarkMode, required this.isDarkMode});

//public getters
  bool get showInitialContent => _showInitialContent;
  int? get selectedRadioValue => _selectedRadioValue;
  String get phoneNumber => _phoneNumber;
  bool get isLoading => _isLoading;

  TextEditingController get emailController => _emailController;
  FocusNode get emailFocusNode => _emailFocusNode;

  void setPhoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }

  void setSelectedRadioValue(int value) {
    _selectedRadioValue = value;
    notifyListeners();
  }

  void setShowInitialContent(bool value) {
    _showInitialContent = value;
    notifyListeners();
  }

  Future<void> forgotPassword(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    // Send the POST request
    final response = await http.post(
      Uri.parse('https://yarnapi-fuu0.onrender.com/api/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': emailController.text.trim()}),
    );

// Check if the response is in JSON format or plain text
    if (response.headers['content-type']?.contains('application/json') ==
        true) {
      final responseData = json.decode(response.body); // Parse as JSON

      print('Response Data: $responseData');
    } else {
      // If it's not JSON, handle it as plain text
      final responseText = response.body;
      print('Response Text: $responseText');
    }

    if (response.statusCode == 200) {
      _isLoading = false;
      notifyListeners();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpOTPPage(
            key: UniqueKey(),
            onToggleDarkMode: onToggleDarkMode,
            isDarkMode: isDarkMode,
            phoneNumber: phoneNumber,
            email: emailController.text.trim(),
          ),
        ),
      );
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => SignUpOTPPage(
      //       key: UniqueKey(),
      //       onToggleDarkMode: widget.onToggleDarkMode,
      //       isDarkMode: widget.isDarkMode,
      //       phoneNumber: phoneNumber,
      //     ),
      //   ),
      // );
    } else if (response.statusCode == 400) {
      final responseData = json.decode(response.body);

      _isLoading = false;
      notifyListeners();
      final String message = responseData['message'];

      // Handle validation error
      CustomSnackbar.show(
        'Error: $message',
        isError: true,
      );
    } else {
      _isLoading = false;
      notifyListeners();
      // Handle other unexpected responses
      CustomSnackbar.show(
        'An unexpected error occurred.',
        isError: true,
      );
    }
  }
}
