import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/custom_snackbar.dart';
import '../../controllers/forgot_password_page_controller.dart';

class ForgotPassword extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;

  const ForgotPassword(
      {super.key, required this.onToggleDarkMode, required this.isDarkMode});

  @override
  ForgotPasswordState createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPassword>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ForgotPasswordPageController(
          onToggleDarkMode: widget.onToggleDarkMode,
          isDarkMode: widget.isDarkMode),
      child: Consumer<ForgotPasswordPageController>(
          builder: (context, forgotPasswordPageController, child) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: Stack(
            // Use a Stack to wrap the content and button
            children: [
              Column(
                // Wrap SingleChildScrollView with a Column
                children: [
                  Expanded(
                    // Use Expanded to allow SingleChildScrollView to take available space
                    child: SingleChildScrollView(
                      // Use SingleChildScrollView for scrolling
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.1),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (forgotPasswordPageController
                                              .showInitialContent ==
                                          true) {
                                        Navigator.pop(context);
                                      } else {
                                        forgotPasswordPageController
                                            .setShowInitialContent(true);
                                      }
                                    },
                                    child: Image.asset(
                                      'images/BackButton.png',
                                      height: 25,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text(
                                "Forgot \nPassword?",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 40.0,
                                  color: Color(0xFF4E4B66),
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
                                "Don’t worry! it happens. Please select the email or number associated with your account.",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 17.0,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              child: forgotPasswordPageController
                                      .showInitialContent
                                  ? Column(
                                      children: [
                                        // Email Option
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0),
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20.0,
                                                horizontal: 20.0),
                                            color: const Color(0xFFEEF1F4),
                                            child: RadioListTile<int>(
                                              value: 1,
                                              activeColor:
                                                  const Color(0xFF500450),
                                              groupValue:
                                                  forgotPasswordPageController
                                                      .selectedRadioValue,
                                              onChanged: (int? value) {
                                                forgotPasswordPageController
                                                    .setSelectedRadioValue(
                                                        value!);
                                              },
                                              title: Row(
                                                children: [
                                                  Image.asset(
                                                    'images/Mail.png',
                                                    height: 55,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.05,
                                                  ),
                                                  Expanded(
                                                    flex: 10,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          'via Email:',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            color: Color(
                                                                0xFF500450),
                                                          ),
                                                        ),
                                                        const Text(
                                                          'example@youremail.com',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xFF500450),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              controlAffinity:
                                                  ListTileControlAffinity
                                                      .trailing,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.02),
                                        // SMS Option
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0),
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20.0,
                                                horizontal: 20.0),
                                            color: const Color(0xFFEEF1F4),
                                            child: RadioListTile<int>(
                                              value: 2,
                                              activeColor:
                                                  const Color(0xFF500450),
                                              groupValue:
                                                  forgotPasswordPageController
                                                      .selectedRadioValue,
                                              onChanged: (int? value) {
                                                forgotPasswordPageController
                                                    .setSelectedRadioValue(
                                                        value!);
                                              },
                                              title: Row(
                                                children: [
                                                  Image.asset(
                                                    'images/Messages.png',
                                                    height: 55,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.05,
                                                  ),
                                                  Expanded(
                                                    flex: 10,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          'via SMS:',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            color: Color(
                                                                0xFF500450),
                                                          ),
                                                        ),
                                                        const Text(
                                                          '+234-1234-5678-9',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xFF500450),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              controlAffinity:
                                                  ListTileControlAffinity
                                                      .trailing,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : (forgotPasswordPageController
                                              .selectedRadioValue ==
                                          1
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Email Form
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20.0),
                                              child: Text(
                                                'Email',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 16.0,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20.0),
                                              child: TextFormField(
                                                controller:
                                                    forgotPasswordPageController
                                                        .emailController,
                                                focusNode:
                                                    forgotPasswordPageController
                                                        .emailFocusNode,
                                                style: const TextStyle(
                                                  fontSize: 16.0,
                                                  decoration:
                                                      TextDecoration.none,
                                                ),
                                                decoration: InputDecoration(
                                                  labelText: '',
                                                  labelStyle: const TextStyle(
                                                    color: Colors.grey,
                                                    fontFamily: 'Poppins',
                                                    fontSize: 12.0,
                                                  ),
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .never,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    borderSide: BorderSide(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                    ),
                                                  ),
                                                ),
                                                cursorColor: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Phone Number Form
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20.0),
                                              child: Text(
                                                'Phone Number',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 16.0,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20.0),
                                              child: IntlPhoneField(
                                                decoration: InputDecoration(
                                                  labelText: 'Phone Number',
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    borderSide:
                                                        const BorderSide(
                                                            color:
                                                                Colors.black),
                                                  ),
                                                  counterText: '',
                                                ),
                                                initialCountryCode:
                                                    'NG', // Set initial country code
                                                onChanged: (phone) {
                                                  forgotPasswordPageController
                                                      .setPhoneNumber(
                                                          phone.completeNumber);
                                                },
                                                onCountryChanged: (country) {
                                                  print(
                                                      'Country changed to: ${country.name}');
                                                },
                                              ),
                                            ),
                                          ],
                                        )),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).viewInsets.bottom),
                          ]),
                    ),
                  ),
                ],
              ),
              if (forgotPasswordPageController.showInitialContent == true)
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              width: 0.5,
                              color: Colors.black.withOpacity(0.15))),
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
                            if (forgotPasswordPageController
                                    .selectedRadioValue !=
                                null) {
                              forgotPasswordPageController
                                  .setShowInitialContent(false);
                            } else {
                              CustomSnackbar.show(
                                'Please select an option.',
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
                          child: forgotPasswordPageController.isLoading
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
                )
              else
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              width: 0.5,
                              color: Colors.black.withOpacity(0.15))),
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
                            if (forgotPasswordPageController
                                    .selectedRadioValue ==
                                1) {
                              if (forgotPasswordPageController
                                  .emailController.text.isNotEmpty) {
                                await forgotPasswordPageController
                                    .forgotPassword(context);
                              } else {
                                CustomSnackbar.show(
                                  'Please enter an email address.',
                                  isError: true,
                                );
                              }
                            } else {
                              if (forgotPasswordPageController
                                  .phoneNumber.isNotEmpty) {
                                await forgotPasswordPageController
                                    .forgotPassword(context);
                              } else {
                                CustomSnackbar.show(
                                  'Please enter a phone number.',
                                  isError: true,
                                );
                              }
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
                          child: forgotPasswordPageController.isLoading
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
