import 'package:flutter/material.dart';
import 'package:yarn/reset_password.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

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
  String otpCode = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handleOtpInputComplete(String code) async {
    setState(() {
      otpCode = code;
    });
    await submitOtp();
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

  Future<void> submitOtp() async {
    // Show loading indicator
    setState(() {
      isLoading = true;
    });

    try {
      // Send the POST request
      final response = await http.post(
        Uri.parse('https://yarnapi-n2dw.onrender.com/api/auth/otp-submit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email, 'otp': otpCode}),
      );

      final responseData = json.decode(response.body);

      print('Response Data: $responseData');

      if (response.statusCode == 200) {
        // Fetch userId and OTP from response
        final int userId = responseData['data']['userId'];
        final String returnedOtp = responseData['data']['OTP'];

        // Navigate to another page and pass userId and OTP
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPassword(
              key: UniqueKey(),
              onToggleDarkMode: widget.onToggleDarkMode,
              isDarkMode: widget.isDarkMode,
              userId: userId, // Pass userId
              otp: returnedOtp, // Pass OTP
            ),
          ),
        );
      } else if (response.statusCode == 400) {
        setState(() {
          isLoading = false;
        });
        final String message = responseData['message'];
        _showCustomSnackBar(context, 'Error: $message', isError: true);
      } else {
        setState(() {
          isLoading = false;
        });
        _showCustomSnackBar(context, 'An unexpected error occurred.',
            isError: true);
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showCustomSnackBar(context, 'Network error. Please try again.',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
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
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    OtpTextField(
                      numberOfFields: 4,
                      fieldWidth: (50 / MediaQuery.of(context).size.width) *
                          MediaQuery.of(context).size.width,
                      focusedBorderColor:
                          const Color(0xFF500450), // Border color when focused
                      enabledBorderColor: Colors.grey,
                      borderColor: Colors.grey,
                      showFieldAsBox: true,
                      onCodeChanged: (String code) {
                        // Handle real-time OTP input changes
                      },
                      onSubmit: (String code) => handleOtpInputComplete(code),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    if (isLoading)
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
      },
    );
  }
}
