import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yarn/select_country.dart';
import 'package:yarn/sign_in_page.dart';

class SignUpPage extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  final String? fcmToken;

  const SignUpPage(
      {super.key,
      required this.onToggleDarkMode,
      required this.isDarkMode,
      this.fcmToken});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with WidgetsBindingObserver {
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectCountry(
            key: UniqueKey(),
            onToggleDarkMode: widget.onToggleDarkMode,
            isDarkMode: widget.isDarkMode,
            username: username,
            password: password),
      ),
    );

    setState(() {
      isLoading = false;
    });
    // Send the POST request
    // final response = await http.post(
    //   Uri.parse('https://yarnapi-n2dw.onrender.com/api/auth/sign-up'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({
    //     'username': username,
    //     'password': password,
    //   }),
    // );
    //
    // final responseData = json.decode(response.body);
    //
    // print('Response Data: $responseData');
    //
    // if (response.statusCode == 200) {
    //   // The response format: {status, data: {userId, token, username}}
    //   final Map<String, dynamic> data = responseData['data'];
    //   final String token = data['token'];
    //   final int userId = data['userId'];
    //   final String userName = data['username'];
    //
    //   // Store the token and user information
    //   await storage.write(key: 'yarnAccessToken', value: token);
    //   await prefs.setString('user', jsonEncode({
    //     'userId': userId,
    //     'username': userName,
    //   }));
    //
    //   // Show success message
    //   _showCustomSnackBar(
    //     context,
    //     'Account created!',
    //     isError: false,
    //   );
    //
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) =>
    //           SelectCountry(key: UniqueKey(),
    //               onToggleDarkMode: widget.onToggleDarkMode,
    //               isDarkMode: widget.isDarkMode),
    //     ),
    //   );
    // } else if (response.statusCode == 400) {
    //   setState(() {
    //     isLoading = false;
    //   });
    //   final String message = responseData['message'];
    //
    //   // Handle validation error
    //   _showCustomSnackBar(
    //     context,
    //     'Error: $message',
    //     isError: true,
    //   );
    // } else {
    //   setState(() {
    //     isLoading = false;
    //   });
    //   // Handle other unexpected responses
    //   _showCustomSnackBar(
    //     context,
    //     'An unexpected error occurred.',
    //     isError: true,
    //   );
    // }
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
                      ? MediaQuery.of(context).size.height * 1.1
                      : MediaQuery.of(context).size.height * 1.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Hello!',
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
                          "Signup to get Started",
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
                                  'Sign Up',
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
                            "Already have an account?",
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
                                  builder: (context) => SignInPage(
                                      key: UniqueKey(),
                                      onToggleDarkMode: widget.onToggleDarkMode,
                                      isDarkMode: widget.isDarkMode),
                                ),
                              );
                            },
                            child: const Text(
                              "Login",
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
