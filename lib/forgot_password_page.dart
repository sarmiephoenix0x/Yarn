import 'package:flutter/material.dart';
import 'package:yarn/sign_up_otp.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  ForgotPasswordState createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPassword>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  bool isLoading2 = false;
  int? _selectedRadioValue;
  bool _showInitialContent = true;
  final FocusNode _emailOrPhoneFocusNode = FocusNode();
  final TextEditingController emailOrPhoneController = TextEditingController();

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
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            "Don’t worry! it happens. Please select the email or number associated with your account.",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 17.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          // Animation duration
                          child: _showInitialContent
                              ? Column(
                                  children: [
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
                                          activeColor: const Color(0xFF1877F2),
                                          groupValue: _selectedRadioValue,
                                          onChanged: (int? value) {
                                            setState(() {
                                              _selectedRadioValue = value;
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
                                                      0.05),
                                              const Expanded(
                                                flex: 10,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'via Email:',
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                      ),
                                                    ),
                                                    Text(
                                                      'example@youremail.com',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          controlAffinity: ListTileControlAffinity
                                              .trailing, // Align radio button to the right
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.02),
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
                                          activeColor: const Color(0xFF1877F2),
                                          groupValue: _selectedRadioValue,
                                          onChanged: (int? value) {
                                            setState(() {
                                              _selectedRadioValue = value;
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
                                                      0.05),
                                              const Expanded(
                                                flex: 10,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'via SMS:',
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                      ),
                                                    ),
                                                    Text(
                                                      '+234-1234-5678-9',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          controlAffinity: ListTileControlAffinity
                                              .trailing, // Align radio button to the right
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: Text(
                                        'Email ID / Mobile number',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 16.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: TextFormField(
                                        controller: emailOrPhoneController,
                                        focusNode: _emailOrPhoneFocusNode,
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          decoration: TextDecoration.none,
                                        ),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            borderSide: const BorderSide(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        cursorColor: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).viewInsets.bottom),
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
                            return const Color(0xFF1877F2);
                          },
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.pressed)) {
                              return const Color(0xFF1877F2);
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
                      onPressed: () {
                        if (emailOrPhoneController.text.isNotEmpty) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SignUpOTPPage(key: UniqueKey()),
                            ),
                          );
                        } else {
                          _showCustomSnackBar(
                            context,
                            'Please enter an email address or a phone number.',
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
                            return const Color(0xFF1877F2);
                          },
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.pressed)) {
                              return const Color(0xFF1877F2);
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
