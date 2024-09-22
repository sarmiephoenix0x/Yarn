import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yarn/successful_psw_reset_page.dart';

class ResetPassword extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  const ResetPassword({super.key, required this.onToggleDarkMode, required this.isDarkMode});

  @override
  ResetPasswordState createState() => ResetPasswordState();
}

class ResetPasswordState extends State<ResetPassword>
    with SingleTickerProviderStateMixin {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController password2Controller = TextEditingController();

  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _password2FocusNode = FocusNode();

  bool isLoading = false;
  final storage = const FlutterSecureStorage();
  late SharedPreferences prefs;
  bool _isPasswordVisible = false;
  bool _isPasswordVisible2 = false;

  @override
  void initState() {
    super.initState();
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _resetPassword() async {
    final String password = passwordController.text.trim();
    final String passwordConfirmation = password2Controller.text.trim();

    if (password.isEmpty ||
        passwordConfirmation.isEmpty) {
      _showCustomSnackBar(
        context,
        'All fields are required.',
        isError: true,
      );

      return;
    }


    if (password.length < 6) {
      _showCustomSnackBar(
        context,
        'New Password must be at least 6 characters.',
        isError: true,
      );

      return;
    }

    if (password != passwordConfirmation) {
      _showCustomSnackBar(
        context,
        'Passwords do not match.',
        isError: true,
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('https://script.teendev.dev/signal/api/passowrd/reset'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    if (response.statusCode == 200) {
      _showCustomSnackBar(
        context,
        'Password reset successful.',
        isError: false,
      );

      Navigator.pop(context);
    } else {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      _showCustomSnackBar(
        context,
        'Error: ${responseData['error']}',
        isError: true,
      );
    }

    setState(() {
      isLoading = false;
    });
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
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                // Wrap SingleChildScrollView with Expanded
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                          const Spacer(),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        "Reset \nPassword",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w900,
                          fontSize: 40.0,
                          color: Color(0xFF4E4B66),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextFormField(
                        controller: passwordController,
                        focusNode: _passwordFocusNode,
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                        decoration: InputDecoration(
                            labelText: 'New Password',
                            labelStyle: const TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                              fontSize: 12.0,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            )),
                        cursorColor: Theme.of(context).colorScheme.onSurface,
                        obscureText: !_isPasswordVisible,
                        obscuringCharacter: "*",
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextFormField(
                        controller: password2Controller,
                        focusNode: _password2FocusNode,
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                        decoration: InputDecoration(
                            labelText: 'Confirm New Password',
                            labelStyle: const TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Inter',
                              fontSize: 12.0,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible2
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible2 = !_isPasswordVisible2;
                                });
                              },
                            )),
                        cursorColor: Theme.of(context).colorScheme.onSurface,
                        obscureText: !_isPasswordVisible2,
                        obscuringCharacter: "*",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
                        width: 0.5, color: Colors.black.withOpacity(0.15))),
                color: Colors.white,
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Container(
                  width: double.infinity,
                  height: (60 / MediaQuery.of(context).size.height) *
                      MediaQuery.of(context).size.height,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (password2Controller.text.isNotEmpty &&
                              isLoading == false ||
                          passwordController.text.isNotEmpty &&
                              isLoading == false) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SuccessfulResetPage(key: UniqueKey(),
                                    onToggleDarkMode: widget.onToggleDarkMode,
                                    isDarkMode: widget.isDarkMode),
                          ),
                        );
                      } else {
                        _showCustomSnackBar(
                          context,
                          'All fields are required.',
                          isError: true,
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.pressed)) {
                            return Colors.white;
                          }
                          return const Color(0xFF500450);
                        },
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.pressed)) {
                            return const Color(0xFF500450);
                          }
                          return Colors.white;
                        },
                      ),
                      elevation: WidgetStateProperty.all<double>(4.0),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(35)),
                        ),
                      ),
                    ),
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Next',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
