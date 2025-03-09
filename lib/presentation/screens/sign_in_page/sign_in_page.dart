import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/widgets/auth_label.dart';
import '../../../core/widgets/auth_password_field.dart';
import '../../../core/widgets/auth_text_field.dart';
import '../../controllers/sign_in_page_controller.dart';
import '../forgot_password_page/forgot_password_page.dart';
import '../sign_up_page/sign_up_page.dart';

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
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return ChangeNotifierProvider(
          create: (context) => SignInPageController(
              onToggleDarkMode: widget.onToggleDarkMode,
              isDarkMode: widget.isDarkMode),
          child: Consumer<SignInPageController>(
              builder: (context, signInPageController, child) {
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
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
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
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
                              height:
                                  MediaQuery.of(context).size.height * 0.05),
                          AuthLabel(
                            title: 'Username',
                          ),
                          AuthTextField(
                            controller: signInPageController.userNameController,
                            focusNode: signInPageController.userNameFocusNode,
                          ),

                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),

                          AuthLabel(
                            title: 'Password',
                          ),

                          AuthPasswordField(
                            controller: signInPageController.passwordController,
                            focusNode: signInPageController.passwordFocusNode,
                            label: '*******************',
                          ),

                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 20.0),
                            child: Row(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Checkbox(
                                      activeColor: const Color(0xFF500450),
                                      checkColor: Colors.white,
                                      value: signInPageController.rememberMe,
                                      onChanged: (bool? value) {
                                        signInPageController
                                            .setRememberMe(value!);
                                      },
                                    ),
                                    Text(
                                      "Remember me",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
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
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          Container(
                            width: double.infinity,
                            height: (60 / MediaQuery.of(context).size.height) *
                                MediaQuery.of(context).size.height,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: ElevatedButton(
                              onPressed: () {
                                signInPageController.submitForm(context);
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
                                shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                ),
                              ),
                              child: signInPageController.isLoading
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
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.03),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUpPage(
                                          key: UniqueKey(),
                                          onToggleDarkMode:
                                              widget.onToggleDarkMode,
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
          }),
        );
      },
    );
  }
}
