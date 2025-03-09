import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/auth_label.dart';
import '../../../core/widgets/auth_password_field.dart';
import '../../../core/widgets/auth_text_field.dart';
import '../../controllers/sign_up_page_controller.dart';
import '../sign_in_page/sign_in_page.dart';

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
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return ChangeNotifierProvider(
          create: (context) => SignUpPageController(
              onToggleDarkMode: widget.onToggleDarkMode,
              isDarkMode: widget.isDarkMode),
          child: Consumer<SignUpPageController>(
              builder: (context, signUpPageController, child) {
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
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
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
                              height:
                                  MediaQuery.of(context).size.height * 0.05),
                          AuthLabel(
                            title: 'Username',
                          ),
                          AuthTextField(
                            controller: signUpPageController.userNameController,
                            focusNode: signUpPageController.userNameFocusNode,
                          ),

                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          AuthLabel(
                            title: 'Password',
                          ),

                          AuthPasswordField(
                            controller: signUpPageController.passwordController,
                            focusNode: signUpPageController.passwordFocusNode,
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
                                      value: signUpPageController.rememberMe,
                                      onChanged: (bool? value) {
                                        signUpPageController
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
                                signUpPageController.submitForm(context);
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
                              child: signUpPageController.isLoading
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
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.03),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignInPage(
                                          key: UniqueKey(),
                                          onToggleDarkMode:
                                              widget.onToggleDarkMode,
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
          }),
        );
      },
    );
  }
}
