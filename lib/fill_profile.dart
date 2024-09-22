import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yarn/main_app.dart';

import 'news_sources.dart';

class FillProfile extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  final String selectedState;
  final String countryIsoCode;

  const FillProfile({
    super.key,
    required this.onToggleDarkMode,
    required this.isDarkMode,
    required this.selectedState,
    required this.countryIsoCode,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FillProfileState createState() => _FillProfileState();
}

class _FillProfileState extends State<FillProfile> with WidgetsBindingObserver {
  final FocusNode _surnameFocusNode = FocusNode();
  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  final FocusNode _dobFocusNode = FocusNode();

  final TextEditingController surnameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  bool dropDownTapped = false;

  final storage = const FlutterSecureStorage();
  late SharedPreferences prefs;
  bool isLoading = false;
  String _profileImage = '';
  final double maxWidth = 360;
  final double maxHeight = 360;
  final ImagePicker _picker = ImagePicker();
  final maskFormatter = MaskTextInputFormatter(
    mask: '+###-##-####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  String? userId;
  String? userName;

  @override
  void initState() {
    super.initState();
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _registerUser() async {
    if (prefs == null) {
      await _initializePrefs();
    }
    final userDataString = prefs.getString('user');

    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      setState(() {
        userId = userData['userId'].toString();
      });
    }
    final String email = emailController.text.trim();
    final String surname = surnameController.text.trim();
    final String firstName = firstNameController.text.trim();
    final String phoneNumber = phoneNumberController.text.trim();
    final String dob = dobController.text.trim();
    final occupation = 'Student';
    final PageToFollowIds = []; // Define based on your requirements
    final CommunityToJoinIds = []; // Define based on your requirements

    if (surname.isEmpty ||
        firstName.isEmpty ||
        email.isEmpty ||
        phoneNumber.isEmpty ||
        dob.isEmpty) {
      _showCustomSnackBar(
        context,
        'All fields are required.',
        isError: true,
      );

      return;
    }

    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      _showCustomSnackBar(
        context,
        'Please enter a valid email address.',
        isError: true,
      );

      return;
    }

    if (phoneNumber.length < 11) {
      _showCustomSnackBar(
        context,
        'Phone number must be at least 11 characters.',
        isError: true,
      );

      return;
    }

    setState(() {
      isLoading = true;
    });
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final response = await http.post(
      Uri.parse('https://yarnapi.onrender.com/api/auth/sign-up-details'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'userId': userId,
        'firstName': firstName,
        'surname': surname,
        'email': email,
        'phone': phoneNumber,
        'gender': 'male', // Replace with actual gender input
        'dateOfBirth': dob,
        'state': widget.selectedState,
        'country': widget.countryIsoCode,
        'occupation': occupation,
        'profilePicture': _profileImage, // You'll need to handle file uploads
        'PageToFollowIds': PageToFollowIds,
        'CommunityToJoinIds': CommunityToJoinIds,
      }),
    );
    final Map<String, dynamic> responseData = jsonDecode(response.body);

    print('Response Data: $responseData');

    if (response.statusCode == 200) {
      final userDataString = prefs.getString('user');

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        setState(() {
          userName = userData['username'].toString();
        });
      }

      // Handle successful response
      _showCustomSnackBar(
        context,
        'Sign up complete! Welcome, $userName',
        isError: false,
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewsSources(
              key: UniqueKey(),
              onToggleDarkMode: widget.onToggleDarkMode,
              isDarkMode: widget.isDarkMode),
        ),
      );
    } else if (response.statusCode == 400) {
      setState(() {
        isLoading = false;
      });
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String error = responseData['error'];
      final List<dynamic> data = responseData['data']['email'];

      // Handle validation error
      _showCustomSnackBar(
        context,
        'Error: $error - $data',
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
  void dispose() {
    // Clean up the controllers when the widget is disposed
    surnameController.dispose();
    firstNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    dobController.dispose();
    super.dispose();
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

  Future<void> _selectImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      final decodedImage =
          await decodeImageFromList(imageFile.readAsBytesSync());

      if (decodedImage.width > maxWidth || decodedImage.height > maxHeight) {
        var cropper = ImageCropper();
        CroppedFile? croppedImage = await cropper.cropImage(
            sourcePath: imageFile.path,
            aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Crop Image',
                toolbarColor: Colors.black,
                toolbarWidgetColor: Colors.white,
                lockAspectRatio: false,
              ),
              IOSUiSettings(
                minimumAspectRatio: 1.0,
              ),
            ]);

        if (croppedImage != null) {
          setState(() {
            _profileImage = croppedImage.path;
          });
        }
      } else {
        // Image is within the specified resolution, no need to crop
        setState(() {
          _profileImage = pickedFile.path;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd-MMMM-yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Center(
                    child: SizedBox(
                      height: orientation == Orientation.portrait
                          ? MediaQuery.of(context).size.height * 1.25
                          : MediaQuery.of(context).size.height * 2.05,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.05),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
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
                                Text(
                                  'Fill your Profile',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22.0,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.1),
                                const Spacer(),
                              ],
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.05),
                          Center(
                            child: Stack(
                              children: [
                                if (_profileImage.isEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(55),
                                    child: Container(
                                      width: (111 /
                                              MediaQuery.of(context)
                                                  .size
                                                  .width) *
                                          MediaQuery.of(context).size.width,
                                      height: (111 /
                                              MediaQuery.of(context)
                                                  .size
                                                  .height) *
                                          MediaQuery.of(context).size.height,
                                      color: Colors.grey,
                                      child: Image.asset(
                                        'images/ProfileImg.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                else
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(55),
                                    child: Container(
                                      width: (111 /
                                              MediaQuery.of(context)
                                                  .size
                                                  .width) *
                                          MediaQuery.of(context).size.width,
                                      height: (111 /
                                              MediaQuery.of(context)
                                                  .size
                                                  .height) *
                                          MediaQuery.of(context).size.height,
                                      color: Colors.grey,
                                      child: Image.file(
                                        File(_profileImage),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () {
                                      _selectImage();
                                    },
                                    child: Image.asset(
                                      height: 35,
                                      'images/EditProfileImg.png',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.05),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              'First Name',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.0,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: TextFormField(
                              controller: firstNameController,
                              focusNode: _firstNameFocusNode,
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
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              cursorColor:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              'Surname',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.0,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: TextFormField(
                              controller: surnameController,
                              focusNode: _surnameFocusNode,
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
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              cursorColor:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              'Email',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.0,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
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
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              cursorColor:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              'Phone Number',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.0,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: TextFormField(
                              controller: phoneNumberController,
                              focusNode: _phoneNumberFocusNode,
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
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                counterText: '',
                              ),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                maskFormatter,
                              ],
                              cursorColor:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              'Date of Birth',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.0,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: GestureDetector(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() {
                                    dobController.text = _formatDate(picked);
                                  });
                                }
                              },
                              child: AbsorbPointer(
                                // Prevent TextFormField from opening keyboard
                                child: TextFormField(
                                  controller: dobController,
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                    counterText: '',
                                  ),
                                  cursorColor:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.05),
                        ],
                      ),
                    ),
                  ),
                ),
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
                            // _registerUser();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewsSources(
                                    key: UniqueKey(),
                                    onToggleDarkMode: widget.onToggleDarkMode,
                                    isDarkMode: widget.isDarkMode),
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
          ),
        );
      },
    );
  }
}
