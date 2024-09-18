import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yarn/main_app.dart';
import 'package:yarn/sign_up_page.dart';

import 'forgot_password_page.dart';
import 'package:yarn/main_app.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with WidgetsBindingObserver {
  final FocusNode _userNameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();
  late SharedPreferences prefs;
  bool isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _submitForm() async {
    if (prefs == null) {
      await _initializePrefs();
    }
    final String username = userNameController.text.trim();
    final String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      // Show an error message if any field is empty
      _showCustomSnackBar(
        context,
        'All fields are required.',
        isError: true,
      );

      return;
    }

    // Validate email format
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(username)) {
      // Show an error message if email is invalid
      _showCustomSnackBar(
        context,
        'Please enter a valid email address.',
        isError: true,
      );

      return;
    }

    // Validate password length
    if (password.length < 6) {
      // Show an error message if password is too short
      _showCustomSnackBar(
        context,
        'Password must be at least 6 characters.',
        isError: true,
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    // Send the POST request
    final response = await http.post(
      Uri.parse('https://script.teendev.dev/signal/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': username,
        'password': password,
      }),
    );

    final responseData = json.decode(response.body);

    print('Response Data: $responseData');

    if (response.statusCode == 200) {
      // The responseData['user'] is a Map, not a String, so handle it accordingly
      final Map<String, dynamic> user = responseData['user'];
      final String accessToken = responseData['access_token'];

      await storage.write(key: 'yarnAccessToken', value: accessToken);
      await prefs.setString(
          'user', jsonEncode(user)); // Store user as a JSON string

      // Handle the successful response here
      _showCustomSnackBar(
        context,
        'Sign in successful!',
        isError: false,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainApp(key: UniqueKey()),
        ),
      );
    } else if (response.statusCode == 400) {
      setState(() {
        isLoading = false;
      });
      final String error = responseData['error'];
      final String data = responseData['data'];

      // Handle validation error
      _showCustomSnackBar(
        context,
        'Error: $error - $data',
        isError: true,
      );
    } else if (response.statusCode == 401) {
      setState(() {
        isLoading = false;
      });
      final String error = responseData['error'];

      // Handle invalid credentials
      _showCustomSnackBar(
        context,
        'Error: $error',
        isError: true,
      );
    } else {
      setState(() {
        isLoading = false;
      });
      // Handle other unexpected responses
      _showCustomSnackBar(
        context,
        'An unexpected error occurred.',
        isError: true,
      );
    }
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
    return OrientationBuilder(
      builder: (context, orientation) {
        return PopScope(
          canPop: false,
          child: Scaffold(
            body: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  height: orientation == Orientation.portrait
                      ? MediaQuery
                      .of(context)
                      .size
                      .height * 1.2
                      : MediaQuery
                      .of(context)
                      .size
                      .height * 1.9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.1),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Hello',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w900,
                            fontSize: 50.0,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Again!',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w900,
                            fontSize: 50.0,
                            color: Color(0xFF000099),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.02),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          "Welcome back you've \nbeen missed",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 17.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.05),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Username',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextFormField(
                          controller: userNameController,
                          focusNode: _userNameFocusNode,
                          style: const TextStyle(
                            fontSize: 16.0,
                            decoration: TextDecoration.none,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          cursorColor: Colors.black,
                        ),
                      ),
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.02),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Password',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextFormField(
                          controller: passwordController,
                          focusNode: _passwordFocusNode,
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                          decoration: InputDecoration(
                              labelText: '*******************',
                              labelStyle: const TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Poppins',
                                fontSize: 12.0,
                                decoration: TextDecoration.none,
                              ),
                              floatingLabelBehavior: FloatingLabelBehavior
                                  .never,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: Colors.black,
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
                          cursorColor: Colors.black,
                          obscureText: !_isPasswordVisible,
                          obscuringCharacter: "*",
                        ),
                      ),
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.02),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 20.0),
                        child: Row(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Checkbox(
                                  activeColor: const Color(0xFF000099),
                                  checkColor: Colors.white,
                                  value: _rememberMe,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _rememberMe = value!;
                                    });
                                  },
                                ),
                                const Text("Remember me", style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Poppins',
                                  fontSize: 12.0,
                                  decoration: TextDecoration.none,
                                ),),
                              ],
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ForgotPassword(key: UniqueKey()),
                                  ),
                                );
                              },
                              child: const Text(
                                'Forgot password?',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  decoration: TextDecoration.none,
                                  decorationColor: Colors.grey,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.0,
                                  color: Color(0xFF000099),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.02),
                      Container(
                        width: double.infinity,
                        height: (60 / MediaQuery
                            .of(context)
                            .size
                            .height) *
                            MediaQuery
                                .of(context)
                                .size
                                .height,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainApp(key: UniqueKey()),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor:
                            WidgetStateProperty.resolveWith<Color>(
                                  (Set<WidgetState> states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return Colors.white;
                                }
                                return const Color(0xFF000099);
                              },
                            ),
                            foregroundColor:
                            WidgetStateProperty.resolveWith<Color>(
                                  (Set<WidgetState> states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return const Color(0xFF000099);
                                }
                                return Colors.white;
                              },
                            ),
                            elevation: WidgetStateProperty.all<double>(4.0),
                            shape:
                            WidgetStateProperty.all<RoundedRectangleBorder>(
                              const RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(15)),
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
                            'Login',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.02),
                      const Center(
                        child: Text(
                          'or continue with',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: (60 / MediaQuery
                                .of(context)
                                .size
                                .height) *
                                MediaQuery
                                    .of(context)
                                    .size
                                    .height,
                            padding:
                            const EdgeInsets.symmetric(horizontal: 20.0),
                            child: ElevatedButton(
                              onPressed: () {

                              },
                              style: ButtonStyle(
                                backgroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                                      (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.pressed)) {
                                      return Colors.white;
                                    }
                                    return const Color(0xFFEEF1F4);
                                  },
                                ),
                                foregroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                                      (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.pressed)) {
                                      return Colors.white;
                                    }
                                    return Colors.grey;
                                  },
                                ),
                                elevation: WidgetStateProperty.all<double>(0),
                                shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'images/FacebookIcon.png',
                                    height: 25,
                                  ),
                                  SizedBox(
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width *
                                          0.03),
                                  const Text(
                                    'Facebook',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: (60 / MediaQuery
                                .of(context)
                                .size
                                .height) *
                                MediaQuery
                                    .of(context)
                                    .size
                                    .height,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0),
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                backgroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                                      (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.pressed)) {
                                      return Colors.white;
                                    }
                                    return const Color(0xFFEEF1F4);
                                  },
                                ),
                                foregroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                                      (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.pressed)) {
                                      return Colors.white;
                                    }
                                    return Colors.grey;
                                  },
                                ),
                                elevation: WidgetStateProperty.all<double>(0),
                                shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'images/GoogleIcon.png',
                                    height: 25,
                                  ),
                                  SizedBox(
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width *
                                          0.03),
                                  const Text(
                                    'Google',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "don't have an account?",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.03),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SignUpPage(key: UniqueKey()),
                                ),
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF000099),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
