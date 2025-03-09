import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/auth_password_field.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../controllers/reset_password_controller.dart';

class ResetPassword extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  final int userId;
  final String otp;
  const ResetPassword(
      {super.key,
      required this.onToggleDarkMode,
      required this.isDarkMode,
      required this.userId,
      required this.otp});

  @override
  ResetPasswordState createState() => ResetPasswordState();
}

class ResetPasswordState extends State<ResetPassword>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ResetPasswordController(
          onToggleDarkMode: widget.onToggleDarkMode,
          isDarkMode: widget.isDarkMode,
          userId: widget.userId,
          otp: widget.otp),
      child: Consumer<ResetPasswordController>(
          builder: (context, resetPasswordController, child) {
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
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1),
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
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
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
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        AuthPasswordField(
                          label: 'New Password',
                          controller:
                              resetPasswordController.passwordController,
                          focusNode: resetPasswordController.passwordFocusNode,
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        AuthPasswordField(
                          label: 'Confirm New Password',
                          controller:
                              resetPasswordController.password2Controller,
                          focusNode: resetPasswordController.password2FocusNode,
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
                        onPressed: () async {
                          if (resetPasswordController
                                      .password2Controller.text.isNotEmpty &&
                                  resetPasswordController.isLoading == false ||
                              resetPasswordController
                                      .passwordController.text.isNotEmpty &&
                                  resetPasswordController.isLoading == false) {
                            await resetPasswordController
                                .resetPassword(context);
                          } else {
                            CustomSnackbar.show(
                              'All fields are required.',
                              isError: true,
                            );
                          }
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
                                  BorderRadius.all(Radius.circular(35)),
                            ),
                          ),
                        ),
                        child: resetPasswordController.isLoading
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
      }),
    );
  }
}
