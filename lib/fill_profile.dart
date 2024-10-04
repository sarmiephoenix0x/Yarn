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
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:path/path.dart' as path;
import 'package:async/async.dart';

class FillProfile extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  final String selectedState;
  final String countryIsoCode;
  final String selectedCity;
  final String username;
  final String password;

  const FillProfile({
    super.key,
    required this.onToggleDarkMode,
    required this.isDarkMode,
    required this.selectedState,
    required this.countryIsoCode,
    required this.selectedCity, required this.username, required this.password,
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
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController yearJoinedController = TextEditingController();

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
  String userId = '';
  String? userName;
  String selectedGender = 'Male';
  String phoneNumber = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
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
    return DateFormat('dd/MM/yyyy').format(date);
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

    // Extracting user details from controllers
    final String email = emailController.text.trim();
    final String surname = surnameController.text.trim();
    final String firstName = firstNameController.text.trim();
    final String dob = dobController.text.trim();
    final String occupation = 'Student';  // Default value
    final String? jobTitle = jobTitleController.text.trim();
    final String? company = companyController.text.trim();
    final String? yearJoined = yearJoinedController.text.trim();

    // Validating required fields
    if (surname.isEmpty ||
        firstName.isEmpty ||
        email.isEmpty ||
        phoneNumber.isEmpty ||
        dob.isEmpty ||
        widget.selectedState.isEmpty ||
        widget.countryIsoCode.isEmpty) {
      _showCustomSnackBar(
        context,
        'All required fields must be filled.',
        isError: true,
      );
      return;
    }

    // Validating email format
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      _showCustomSnackBar(
        context,
        'Please enter a valid email address.',
        isError: true,
      );
      return;
    }

    // Validating phone number
    if (!_formKey.currentState!.validate()) {
      _showCustomSnackBar(
        context,
        'Please provide a valid phone number.',
        isError: true,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final url = Uri.parse('https://yarnapi.onrender.com/api/auth/sign-up');
    final request = http.MultipartRequest('POST', url)
      // ..headers['Authorization'] = 'Bearer $accessToken'
      // ..fields['userId'] = userId
      ..fields['username'] = widget.username
      ..fields['password'] = widget.password
      ..fields['firstName'] = firstName
      ..fields['surname'] = surname
      ..fields['email'] = email
      ..fields['phone'] = phoneNumber
      ..fields['gender'] = selectedGender
      ..fields['dateOfBirth'] = dob
      ..fields['state'] = widget.selectedState
      ..fields['country'] = widget.countryIsoCode
      ..fields['occupation'] = occupation
      ..fields['city'] = widget.selectedCity;

    // Adding optional fields if not empty
    if (jobTitle != null && jobTitle.isNotEmpty) {
      request.fields['jobTitle'] = jobTitle;
    }
    if (company != null && company.isNotEmpty) {
      request.fields['company'] = company;
    }
    if (yearJoined != null && yearJoined.isNotEmpty) {
      request.fields['yearJoined'] = yearJoined;
    }

    // Handling profile picture upload if it's a local file
    if (_profileImage != null && _profileImage is File && !_profileImage.startsWith('http')) {
      File imageFile = File(_profileImage);
      if (await imageFile.exists()) {
        var stream = http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
        var length = await imageFile.length();
        request.files.add(http.MultipartFile(
          'profile_photo',
          stream,
          length,
          filename: path.basename(imageFile.path),
        ));
      } else {
        print('Image file not found. Skipping image upload.');
      }
    } else {
      print('Skipping image upload as the profile image is from an HTTP source.');
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Success: Saving the user data
        final Map<String, dynamic> data = responseData['data'];
        await storage.write(key: 'yarnAccessToken', value: data['token']);
        await prefs.setString('user', jsonEncode({
          'userId': data['userId'],
          'username': data['username'],
          'firstName': firstName,
          'surname': surname,
          'email': email,
          'phone': phoneNumber,
          'gender': selectedGender,
          'dateOfBirth': dob,
          'state': widget.selectedState,
          'country': widget.countryIsoCode,
          'occupation': occupation,
          'jobTitle': jobTitle,
          'company': company,
          'yearJoined': yearJoined,
          'profilePicture': _profileImage,
          'city': widget.selectedCity,
        }));

        _showCustomSnackBar(context, 'Account created!', isError: false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainApp(
              key: UniqueKey(),
              onToggleDarkMode: widget.onToggleDarkMode,
              isDarkMode: widget.isDarkMode,
            ),
          ),
        );
      } else if (response.statusCode == 400) {
        final String message = responseData['message'];
        _showCustomSnackBar(context, message, isError: true);
      } else {
        _showCustomSnackBar(context, 'An unexpected error occurred.', isError: true);
      }
    } catch (e) {
      _showCustomSnackBar(context, 'An error occurred: $e', isError: true);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
                          ? MediaQuery
                          .of(context)
                          .size
                          .height * 1.35
                          : MediaQuery
                          .of(context)
                          .size
                          .height * 2.15,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height:
                              MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.05),
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
                                    Theme
                                        .of(context)
                                        .colorScheme
                                        .onSurface,
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
                                    Theme
                                        .of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                                SizedBox(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width *
                                        0.1),
                                const Spacer(),
                              ],
                            ),
                          ),
                          SizedBox(
                              height:
                              MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.05),
                          Center(
                            child: Stack(
                              children: [
                                if (_profileImage.isEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(55),
                                    child: Container(
                                      width: (111 /
                                          MediaQuery
                                              .of(context)
                                              .size
                                              .width) *
                                          MediaQuery
                                              .of(context)
                                              .size
                                              .width,
                                      height: (111 /
                                          MediaQuery
                                              .of(context)
                                              .size
                                              .height) *
                                          MediaQuery
                                              .of(context)
                                              .size
                                              .height,
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
                                          MediaQuery
                                              .of(context)
                                              .size
                                              .width) *
                                          MediaQuery
                                              .of(context)
                                              .size
                                              .width,
                                      height: (111 /
                                          MediaQuery
                                              .of(context)
                                              .size
                                              .height) *
                                          MediaQuery
                                              .of(context)
                                              .size
                                              .height,
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
                              MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.05),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              'First Name',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.0,
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .onSurface,
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
                                    Theme
                                        .of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                              ),
                              cursorColor:
                              Theme
                                  .of(context)
                                  .colorScheme
                                  .onSurface,
                            ),
                          ),
                          SizedBox(
                              height:
                              MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.02),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              'Surname',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.0,
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .onSurface,
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
                                    Theme
                                        .of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                              ),
                              cursorColor:
                              Theme
                                  .of(context)
                                  .colorScheme
                                  .onSurface,
                            ),
                          ),
                          SizedBox(
                              height:
                              MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.02),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              'Email',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.0,
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .onSurface,
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
                                    Theme
                                        .of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                              ),
                              cursorColor:
                              Theme
                                  .of(context)
                                  .colorScheme
                                  .onSurface,
                            ),
                          ),
                          SizedBox(
                              height:
                              MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.02),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              'Phone Number',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.0,
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .onSurface,
                              ),
                            ),
                          ),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: IntlPhoneField(
                                    decoration: InputDecoration(
                                      labelText: 'Phone Number',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      counterText: '',
                                    ),
                                    initialCountryCode: 'NG',
                                    // Set initial country code
                                    onChanged: (phone) {
                                      setState(() {
                                        phoneNumber = phone.completeNumber;
                                      });
                                    },
                                    onCountryChanged: (country) {
                                      print(
                                          'Country changed to: ${country
                                              .name}');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                              height:
                              MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.02),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gender',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16.0,
                                    color:
                                    Theme
                                        .of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),

                                // Add some space between label and field
                                DropdownButtonFormField<String>(
                                  value: selectedGender,
                                  // Default value is now "Male"
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Theme
                                            .of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                  ),
                                  items: ['Male', 'Female', 'Other']
                                      .map((String gender) {
                                    return DropdownMenuItem<String>(
                                      value: gender,
                                      child: Text(gender),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedGender = newValue!;
                                    });
                                  },
                                  hint: Text(
                                    'Select Gender',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16.0,
                                      color: Theme
                                          .of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                              height:
                              MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.02),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              'Date of Birth',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.0,
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .onSurface,
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
                                    // Format the date in dd/MM/yyyy format before updating the controller
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
                                        color: Theme
                                            .of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                    counterText: '',
                                  ),
                                  cursorColor:
                                  Theme
                                      .of(context)
                                      .colorScheme
                                      .onSurface,
                                ),
                              ),
                            ),
                          ),
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
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: Container(
                        width: double.infinity,
                        height: (60 / MediaQuery
                            .of(context)
                            .size
                            .height) *
                            MediaQuery
                                .of(context)
                                .size
                                .height,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => NewsSources(
                            //       key: UniqueKey(),
                            //       onToggleDarkMode: widget.onToggleDarkMode,
                            //       isDarkMode: widget.isDarkMode,
                            //       email: emailController.text.trim(),
                            //       surname: surnameController.text.trim(),
                            //       firstName: firstNameController.text.trim(),
                            //       phoneNumber: phoneNumber,
                            //       dob: dobController.text.trim(),
                            //       state: widget.selectedState,
                            //       country: widget.countryIsoCode,
                            //       occupation: 'Student',
                            //       selectedGender: selectedGender,
                            //       _profileImage: _profileImage,
                            //     ),
                            //   ),
                            // );
                            _registerUser();
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
