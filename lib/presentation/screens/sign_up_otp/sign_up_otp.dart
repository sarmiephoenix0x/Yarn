import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:provider/provider.dart';

import '../../controllers/sign_up_otp_controller.dart';

class SignUpOTPPage extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  final String phoneNumber;
  final String email;
  const SignUpOTPPage(
      {super.key,
      required this.onToggleDarkMode,
      required this.isDarkMode,
      required this.phoneNumber,
      required this.email});

  @override
  SignUpOTPPageState createState() => SignUpOTPPageState();
}

class SignUpOTPPageState extends State<SignUpOTPPage> {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return ChangeNotifierProvider(
          create: (context) => SignUpOtpController(
              onToggleDarkMode: widget.onToggleDarkMode,
              isDarkMode: widget.isDarkMode,
              phoneNumber: widget.phoneNumber,
              email: widget.email),
          child: Consumer<SignUpOtpController>(
              builder: (context, signUpOtpController, child) {
            return Scaffold(
              body: SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    height: orientation == Orientation.portrait
                        ? MediaQuery.of(context).size.height
                        : MediaQuery.of(context).size.height * 1.5,
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
                            height: MediaQuery.of(context).size.height * 0.1),
                        const Center(
                          child: Text(
                            'OTP Verification',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w900,
                              fontSize: 40.0,
                              color: Color(0xFF4E4B66),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        Center(
                          child: Text(
                            "Enter the OTP sent to ${widget.email}",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1),
                        OtpTextField(
                          numberOfFields: 4,
                          fieldWidth: (50 / MediaQuery.of(context).size.width) *
                              MediaQuery.of(context).size.width,
                          focusedBorderColor: const Color(
                              0xFF500450), // Border color when focused
                          enabledBorderColor: Colors.grey,
                          borderColor: Colors.grey,
                          showFieldAsBox: true,
                          onCodeChanged: (String code) {
                            // Handle real-time OTP input changes
                          },
                          onSubmit: (String code) => signUpOtpController
                              .handleOtpInputComplete(code, context),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1),
                        const Center(
                          child: Text(
                            "Didn't receive code?",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        Center(
                          child: Text(
                            "Resend it",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1),
                        if (signUpOtpController.isLoading)
                          const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(vertical: 15.0),
                        //   decoration: BoxDecoration(
                        //     border: Border(
                        //         top: BorderSide(
                        //             width: 0.5,
                        //             color: Colors.black.withOpacity(0.15))),
                        //     color: Colors.white,
                        //   ),
                        //   child: SizedBox(
                        //     width: MediaQuery.of(context).size.width,
                        //     child: Container(
                        //       width: double.infinity,
                        //       height: (60 / MediaQuery.of(context).size.height) *
                        //           MediaQuery.of(context).size.height,
                        //       padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        //       child: ElevatedButton(
                        //         onPressed: () async {
                        //           await submitOtp();
                        //         },
                        //         style: ButtonStyle(
                        //           backgroundColor:
                        //               WidgetStateProperty.resolveWith<Color>(
                        //             (Set<WidgetState> states) {
                        //               if (states.contains(WidgetState.pressed)) {
                        //                 return Colors.white;
                        //               }
                        //               return const Color(0xFF500450);
                        //             },
                        //           ),
                        //           foregroundColor:
                        //               WidgetStateProperty.resolveWith<Color>(
                        //             (Set<WidgetState> states) {
                        //               if (states.contains(WidgetState.pressed)) {
                        //                 return const Color(0xFF500450);
                        //               }
                        //               return Colors.white;
                        //             },
                        //           ),
                        //           elevation: WidgetStateProperty.all<double>(4.0),
                        //           shape: WidgetStateProperty.all<
                        //               RoundedRectangleBorder>(
                        //             const RoundedRectangleBorder(
                        //               borderRadius:
                        //                   BorderRadius.all(Radius.circular(35)),
                        //             ),
                        //           ),
                        //         ),
                        //         child: isLoading
                        //             ? const Center(
                        //                 child: CircularProgressIndicator(
                        //                   color: Colors.white,
                        //                 ),
                        //               )
                        //             : const Text(
                        //                 'Next',
                        //                 style: TextStyle(
                        //                   fontFamily: 'Poppins',
                        //                   fontWeight: FontWeight.bold,
                        //                 ),
                        //               ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
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
