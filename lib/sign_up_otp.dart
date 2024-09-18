import 'package:flutter/material.dart';
import 'package:yarn/reset_password.dart';

class SignUpOTPPage extends StatefulWidget {
  const SignUpOTPPage({super.key});

  @override
  SignUpOTPPageState createState() => SignUpOTPPageState();
}

class SignUpOTPPageState extends State<SignUpOTPPage> {
  final int _numberOfFields = 4;
  List<TextEditingController> controllers = [];
  List<FocusNode> focusNodes = [];
  List<String> inputs = List.generate(4, (index) => '');

  @override
  void initState() {
    super.initState();
    controllers =
        List.generate(_numberOfFields, (index) => TextEditingController());
    focusNodes = List.generate(_numberOfFields, (index) => FocusNode());
    focusNodes[0].requestFocus(); // Focus on the first field initially

    // for (var i = 0; i < _numberOfFields; i++) {
    //   controllers[i].addListener(() => onKeyPressed(controllers[i].text, i));
    // }
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void onKeyPressed(String value, int index) {
    setState(() {
      if (value.isEmpty) {
        // Handle backspace
        for (int i = inputs.length - 1; i >= 0; i--) {
          if (inputs[i].isNotEmpty) {
            inputs[i] = '';
            if (i > 0) {
              FocusScope.of(context).requestFocus(focusNodes[i - 1]);
            }
            controllers[i].selection =
                TextSelection.collapsed(offset: controllers[i].text.length);
            break;
          }
        }
      } else if (index != -1) {
        // Handle text input
        inputs[index] = value;
        controllers[index].selection =
            TextSelection.collapsed(offset: controllers[index].text.length);

        if (index < _numberOfFields - 1) {
          // Move focus to the next field
          FocusScope.of(context).requestFocus(focusNodes[index + 1]);
        }

        bool allFieldsFilled = inputs.every((element) => element.isNotEmpty);
        if (allFieldsFilled) {
          // Handle all fields filled case
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => CreateAccount_Profile_Page(
          //         key: UniqueKey(), isLoadedFromFirstPage: "false"),
          //   ),
          // );
        }
      }
    });
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
                    const Center(
                      child: Text(
                        "Enter the OTP sent to +234-1234-5678-9",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(_numberOfFields, (index) {
                        return SizedBox(
                          width: 50,
                          child: TextFormField(
                            controller: controllers[index],
                            focusNode: focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            decoration: InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            cursorColor: Colors.black,
                            enabled: index == 0 ||
                                controllers[index - 1].text.isNotEmpty,
                            onChanged: (value) {
                              if (value.length == 1) {
                                onKeyPressed(value, index);
                              } else if (value.isEmpty) {
                                onKeyPressed(value, index);
                              }
                            },
                            onFieldSubmitted: (value) {
                              if (value.isNotEmpty) {
                                onKeyPressed(value, index);
                              }
                            },
                          ),
                        );
                      }),
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
                    const Center(
                      child: Text(
                        "Resend it",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Container(
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
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ResetPassword(key: UniqueKey()),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.pressed)) {
                                    return Colors.white;
                                  }
                                  return const Color(0xFF000099);
                                },
                              ),
                              foregroundColor:
                                  WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.pressed)) {
                                    return const Color(0xFF000099);
                                  }
                                  return Colors.white;
                                },
                              ),
                              elevation: WidgetStateProperty.all<double>(4.0),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(35)),
                                ),
                              ),
                            ),
                            child: const Text(
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
