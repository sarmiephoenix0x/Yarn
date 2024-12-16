import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yarn/main_app.dart';
import 'package:yarn/select_country.dart';
import 'package:yarn/sign_up_page.dart';

import 'forgot_password_page.dart';
import 'package:yarn/main_app.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInPage extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  final String? fcmToken;

  const SignInPage(
      {super.key,
      required this.onToggleDarkMode,
      required this.isDarkMode,
      this.fcmToken});

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
  bool isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/user.gender.read',
      'https://www.googleapis.com/auth/user.birthday.read',
    ],
  );

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      print('Attempting Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        setState(() {
          isGoogleLoading = true;
        });
        print('Google Sign-In successful. Retrieving authentication token...');
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        String authToken = googleAuth.idToken!;
        print('Authentication Token: $authToken');

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);

        final String? fullName = googleUser.displayName;
        final String? email = googleUser.email;

        final List<String>? nameParts = fullName?.split(' ');
        final String? firstName = nameParts?.first;
        final String surname = nameParts!.length > 1 ? nameParts.last : '';
      } else {
        setState(() {
          isGoogleLoading = false;
        });
        print('Google Sign-In canceled.');
      }
    } on PlatformException catch (e) {
      print('PlatformException: $e');
      if (e.code == 'sign_in_required') {
        _promptUserForPermission(e, context);
      } else {
        _showSignInErrorDialog(e, context);
      }
    } catch (error) {
      setState(() {
        isGoogleLoading = false;
      });
      print('Error during Google Sign-In: $error');
      _showSignInErrorDialog(error, context);
    }
  }

  void _promptUserForPermission(PlatformException e, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text('Please grant permission to continue: ${e.message}'),
        actions: [
          TextButton(
            child: const Text('Grant Permission'),
            onPressed: () {
              Navigator.pop(context);
              _handlePermissionGranted(context);
            },
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
              _handlePermissionDenied(context);
            },
          ),
        ],
      ),
    );
  }

  void _handlePermissionGranted(BuildContext context) {
    print('User granted permission.');
  }

  void _handlePermissionDenied(BuildContext context) {
    print('User denied permission.');
  }

  void _showSignInErrorDialog(Object error, BuildContext context) {
    setState(() {
      isGoogleLoading = false;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign-in Error'),
        content: Text('Failed to sign in: $error'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (prefs == null) {
      await _initializePrefs();
    }

    final String username = userNameController.text.trim();
    final String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showCustomSnackBar(
        context,
        'All fields are required.',
        isError: true,
      );
      return;
    }

    // Validate password length
    if (password.length < 6) {
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

    try {
      // Fetch the current FCM token
      final FirebaseMessaging messaging = FirebaseMessaging.instance;
      final String? currentFCMToken = await messaging.getToken();

      // Fetch the stored FCM token
      final String? storedFCMToken = prefs.getString('fcmToken');

      // Determine if the token needs to be sent
      final bool shouldSendFCMToken =
          storedFCMToken == null || currentFCMToken != storedFCMToken;

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'username': username,
        'password': password,
      };

      if (shouldSendFCMToken && currentFCMToken != null) {
        requestBody['firebaseToken'] = currentFCMToken;
      }

      // Send the POST request
      final response = await http.post(
        Uri.parse('https://yarnapi-n2dw.onrender.com/api/auth/sign-in'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      print('Response Status: ${response.statusCode}');
      print('Response Body Length: ${response.body.length}');
      print('Response Body: "${response.body}"');
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // The response format: {status, data: {userId, token, username}}
        final Map<String, dynamic> data = responseData['data'];
        final String token = data['token'];
        final int userId = data['userId'];
        final String userName = data['username'];

        // Store the token and user information
        await storage.write(key: 'yarnAccessToken', value: token);
        await prefs.setString(
          'user',
          jsonEncode({
            'userId': userId,
            'username': userName,
          }),
        );

        // Update the stored FCM token if it was sent
        if (shouldSendFCMToken && currentFCMToken != null) {
          await prefs.setString('fcmToken', currentFCMToken);
        }

        // Show success message
        _showCustomSnackBar(
          context,
          'Sign In Successful!',
          isError: false,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainApp(
              key: UniqueKey(),
              onToggleDarkMode: widget.onToggleDarkMode,
              isDarkMode: widget.isDarkMode,
            ),
          ),
        );
      } else if (response.statusCode == 400) {
        setState(() {
          isLoading = false;
        });
        final String message = responseData['message'];

        // Handle validation error
        _showCustomSnackBar(
          context,
          'Error: $message',
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
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
      _showCustomSnackBar(
        context,
        'An error occurred. Please try again later.',
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
                      ? MediaQuery.of(context).size.height * 1.2
                      : MediaQuery.of(context).size.height * 1.9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Hello',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w900,
                            fontSize: 50.0,
                            color: Theme.of(context).colorScheme.onSurface,
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
                            color: Color(0xFF500450),
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          "Welcome back you've \nbeen missed",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 17.0,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Username',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.0,
                            color: Theme.of(context).colorScheme.onSurface,
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
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          cursorColor: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Password',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.0,
                            color: Theme.of(context).colorScheme.onSurface,
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
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
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
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 20.0),
                        child: Row(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Checkbox(
                                  activeColor: const Color(0xFF500450),
                                  checkColor: Colors.white,
                                  value: _rememberMe,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _rememberMe = value!;
                                    });
                                  },
                                ),
                                Text(
                                  "Remember me",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontFamily: 'Poppins',
                                    fontSize: 12.0,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ForgotPassword(
                                        key: UniqueKey(),
                                        onToggleDarkMode:
                                            widget.onToggleDarkMode,
                                        isDarkMode: widget.isDarkMode),
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
                                  color: Color(0xFF500450),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      Container(
                        width: double.infinity,
                        height: (60 / MediaQuery.of(context).size.height) *
                            MediaQuery.of(context).size.height,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ElevatedButton(
                          onPressed: () {
                            _submitForm();
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return Colors.white;
                                }
                                return const Color(0xFF500450);
                              },
                            ),
                            foregroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return const Color(0xFF500450);
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
                      // SizedBox(
                      //     height: MediaQuery.of(context).size.height * 0.02),
                      // const Center(
                      //   child: Text(
                      //     'or continue with',
                      //     style: TextStyle(
                      //       fontFamily: 'Poppins',
                      //       fontSize: 13.0,
                      //       fontWeight: FontWeight.bold,
                      //       color: Colors.grey,
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(
                      //     height: MediaQuery.of(context).size.height * 0.02),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Container(
                      //       height: (60 / MediaQuery.of(context).size.height) *
                      //           MediaQuery.of(context).size.height,
                      //       padding:
                      //           const EdgeInsets.symmetric(horizontal: 20.0),
                      //       child: ElevatedButton(
                      //         onPressed: () {},
                      //         style: ButtonStyle(
                      //           backgroundColor:
                      //               WidgetStateProperty.resolveWith<Color>(
                      //             (Set<WidgetState> states) {
                      //               if (states.contains(WidgetState.pressed)) {
                      //                 return Colors.white;
                      //               }
                      //               return const Color(0xFFEEF1F4);
                      //             },
                      //           ),
                      //           foregroundColor:
                      //               WidgetStateProperty.resolveWith<Color>(
                      //             (Set<WidgetState> states) {
                      //               if (states.contains(WidgetState.pressed)) {
                      //                 return Colors.white;
                      //               }
                      //               return Colors.grey;
                      //             },
                      //           ),
                      //           elevation: WidgetStateProperty.all<double>(0),
                      //           shape: WidgetStateProperty.all<
                      //               RoundedRectangleBorder>(
                      //             const RoundedRectangleBorder(
                      //               borderRadius:
                      //                   BorderRadius.all(Radius.circular(15)),
                      //             ),
                      //           ),
                      //         ),
                      //         child: Row(
                      //           children: [
                      //             Image.asset(
                      //               'images/FacebookIcon.png',
                      //               height: 25,
                      //             ),
                      //             SizedBox(
                      //                 width: MediaQuery.of(context).size.width *
                      //                     0.03),
                      //             const Text(
                      //               'Facebook',
                      //               style: TextStyle(
                      //                 fontFamily: 'Poppins',
                      //                 fontWeight: FontWeight.bold,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //     Container(
                      //       height: (60 / MediaQuery.of(context).size.height) *
                      //           MediaQuery.of(context).size.height,
                      //       padding:
                      //           const EdgeInsets.symmetric(horizontal: 20.0),
                      //       child: ElevatedButton(
                      //         onPressed: () {
                      //           //_handleSignIn(context);
                      //         },
                      //         style: ButtonStyle(
                      //           backgroundColor:
                      //               WidgetStateProperty.resolveWith<Color>(
                      //             (Set<WidgetState> states) {
                      //               if (states.contains(WidgetState.pressed)) {
                      //                 return Colors.white;
                      //               }
                      //               return const Color(0xFFEEF1F4);
                      //             },
                      //           ),
                      //           foregroundColor:
                      //               WidgetStateProperty.resolveWith<Color>(
                      //             (Set<WidgetState> states) {
                      //               if (states.contains(WidgetState.pressed)) {
                      //                 return Colors.white;
                      //               }
                      //               return Colors.grey;
                      //             },
                      //           ),
                      //           elevation: WidgetStateProperty.all<double>(0),
                      //           shape: WidgetStateProperty.all<
                      //               RoundedRectangleBorder>(
                      //             const RoundedRectangleBorder(
                      //               borderRadius:
                      //                   BorderRadius.all(Radius.circular(15)),
                      //             ),
                      //           ),
                      //         ),
                      //         child: Row(
                      //           children: [
                      //             Image.asset(
                      //               'images/GoogleIcon.png',
                      //               height: 25,
                      //             ),
                      //             SizedBox(
                      //                 width: MediaQuery.of(context).size.width *
                      //                     0.03),
                      //             const Text(
                      //               'Google',
                      //               style: TextStyle(
                      //                 fontFamily: 'Poppins',
                      //                 fontWeight: FontWeight.bold,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
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
                              width: MediaQuery.of(context).size.width * 0.03),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUpPage(
                                      key: UniqueKey(),
                                      onToggleDarkMode: widget.onToggleDarkMode,
                                      isDarkMode: widget.isDarkMode),
                                ),
                              );
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) =>
                              //         SelectCountry(key: UniqueKey(),
                              //             onToggleDarkMode: widget.onToggleDarkMode,
                              //             isDarkMode: widget.isDarkMode),
                              //   ),
                              // );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF500450),
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
