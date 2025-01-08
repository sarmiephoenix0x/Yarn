import 'package:flutter/material.dart';
import 'package:yarn/sign_up_otp.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';

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
  bool isLoading = false;
  bool isLoading2 = false;
  int? _selectedRadioValue;
  bool _showInitialContent = true;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  String phoneNumber = '';

  @override
  void initState() {
    super.initState();
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

  Future<void> forgotPassword() async {
    setState(() {
      isLoading = true;
    });

    // Send the POST request
    final response = await http.post(
      Uri.parse('https://yarnapi-fuu0.onrender.com/api/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': emailController.text.trim()}),
    );

// Check if the response is in JSON format or plain text
    if (response.headers['content-type']?.contains('application/json') ==
        true) {
      final responseData = json.decode(response.body); // Parse as JSON

      print('Response Data: $responseData');
    } else {
      // If it's not JSON, handle it as plain text
      final responseText = response.body;
      print('Response Text: $responseText');
    }

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpOTPPage(
            key: UniqueKey(),
            onToggleDarkMode: widget.onToggleDarkMode,
            isDarkMode: widget.isDarkMode,
            phoneNumber: phoneNumber,
            email: emailController.text.trim(),
          ),
        ),
      );
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => SignUpOTPPage(
      //       key: UniqueKey(),
      //       onToggleDarkMode: widget.onToggleDarkMode,
      //       isDarkMode: widget.isDarkMode,
      //       phoneNumber: phoneNumber,
      //     ),
      //   ),
      // );
    } else if (response.statusCode == 400) {
      final responseData = json.decode(response.body);
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
  }

  @override
  Widget build(BuildContext context) {
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
                            height: MediaQuery.of(context).size.height * 0.1),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (_showInitialContent == true) {
                                    Navigator.pop(context);
                                  } else {
                                    setState(() {
                                      _showInitialContent = true;
                                    });
                                  }
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
                            height: MediaQuery.of(context).size.height * 0.02),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            "Don’t worry! it happens. Please select the email or number associated with your account.",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 17.0,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: _showInitialContent
                              ? Column(
                                  children: [
                                    // Email Option
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20.0, horizontal: 20.0),
                                        color: const Color(0xFFEEF1F4),
                                        child: RadioListTile<int>(
                                          value: 1,
                                          activeColor: const Color(0xFF500450),
                                          groupValue: _selectedRadioValue,
                                          onChanged: (int? value) {
                                            setState(() {
                                              _selectedRadioValue = value!;
                                            });
                                          },
                                          title: Row(
                                            children: [
                                              Image.asset(
                                                'images/Mail.png',
                                                height: 55,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
                                              ),
                                              Expanded(
                                                flex: 10,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'via Email:',
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        color:
                                                            Color(0xFF500450),
                                                      ),
                                                    ),
                                                    const Text(
                                                      'example@youremail.com',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF500450),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          controlAffinity:
                                              ListTileControlAffinity.trailing,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.02),
                                    // SMS Option
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20.0, horizontal: 20.0),
                                        color: const Color(0xFFEEF1F4),
                                        child: RadioListTile<int>(
                                          value: 2,
                                          activeColor: const Color(0xFF500450),
                                          groupValue: _selectedRadioValue,
                                          onChanged: (int? value) {
                                            setState(() {
                                              _selectedRadioValue = value!;
                                            });
                                          },
                                          title: Row(
                                            children: [
                                              Image.asset(
                                                'images/Messages.png',
                                                height: 55,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05,
                                              ),
                                              Expanded(
                                                flex: 10,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'via SMS:',
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        color:
                                                            Color(0xFF500450),
                                                      ),
                                                    ),
                                                    const Text(
                                                      '+234-1234-5678-9',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Color(0xFF500450),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          controlAffinity:
                                              ListTileControlAffinity.trailing,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : (_selectedRadioValue == 1
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Email Form
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
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
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0),
                                          child: TextFormField(
                                            controller: emailController,
                                            focusNode: _emailFocusNode,
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              decoration: TextDecoration.none,
                                            ),
                                            decoration: InputDecoration(
                                              labelText: '',
                                              labelStyle: const TextStyle(
                                                color: Colors.grey,
                                                fontFamily: 'Poppins',
                                                fontSize: 12.0,
                                              ),
                                              floatingLabelBehavior:
                                                  FloatingLabelBehavior.never,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
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
                                          padding: const EdgeInsets.symmetric(
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
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0),
                                          child: IntlPhoneField(
                                            decoration: InputDecoration(
                                              labelText: 'Phone Number',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: const BorderSide(
                                                    color: Colors.black),
                                              ),
                                              counterText: '',
                                            ),
                                            initialCountryCode:
                                                'NG', // Set initial country code
                                            onChanged: (phone) {
                                              setState(() {
                                                phoneNumber =
                                                    phone.completeNumber;
                                              });
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
                            height: MediaQuery.of(context).viewInsets.bottom),
                      ]),
                ),
              ),
            ],
          ),
          if (_showInitialContent == true)
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
                        if (_selectedRadioValue != null) {
                          setState(() {
                            _showInitialContent = false;
                          });
                        } else {
                          _showCustomSnackBar(
                            context,
                            'Please select an option.',
                            isError: true,
                          );
                        }
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
            )
          else
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
                        if (_selectedRadioValue == 1) {
                          if (emailController.text.isNotEmpty) {
                            await forgotPassword();
                          } else {
                            _showCustomSnackBar(
                              context,
                              'Please enter an email address.',
                              isError: true,
                            );
                          }
                        } else {
                          if (phoneNumber.isNotEmpty) {
                            await forgotPassword();
                          } else {
                            _showCustomSnackBar(
                              context,
                              'Please enter a phone number.',
                              isError: true,
                            );
                          }
                        }
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
    );
  }
}
