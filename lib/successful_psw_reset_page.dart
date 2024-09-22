import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yarn/sign_in_page.dart';

class SuccessfulResetPage extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  const SuccessfulResetPage({super.key, required this.onToggleDarkMode, required this.isDarkMode});

  @override
  SuccessfulResetPageState createState() => SuccessfulResetPageState();
}

class SuccessfulResetPageState extends State<SuccessfulResetPage>
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

    if (password.isEmpty || passwordConfirmation.isEmpty) {
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
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  // Wrap SingleChildScrollView with Expanded
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'images/AppLogo.png',
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.04),
                        const Text(
                          "Congratulations",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w900,
                            fontSize: 30.0,
                            color: Color(0xFF4E4B66),
                          ),
                        ),
                        Text(
                          "Your account is ready to use",
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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInPage(key: UniqueKey(),
                                onToggleDarkMode: widget.onToggleDarkMode,
                                isDarkMode: widget.isDarkMode),
                          ),
                        );
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
      ),
    );
  }
}
