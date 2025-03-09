import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:async/async.dart';

import '../../core/widgets/custom_snackbar.dart';
import '../screens/main_app/main_app.dart';

class FillProfileController extends ChangeNotifier {
  final FocusNode _surnameFocusNode = FocusNode();
  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  final FocusNode _dobFocusNode = FocusNode();

  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _yearJoinedController = TextEditingController();

  bool dropDownTapped = false;

  final storage = const FlutterSecureStorage();
  late SharedPreferences prefs;
  bool _isLoading = false;
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
  String _selectedGender = 'Male';
  String _phoneNumber = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  final String selectedState;
  final String countryIsoCode;
  final String selectedCity;
  final String username;
  final String password;

  FillProfileController(
      {required this.onToggleDarkMode,
      required this.isDarkMode,
      required this.selectedState,
      required this.countryIsoCode,
      required this.selectedCity,
      required this.username,
      required this.password}) {
    initialize();
  }

//public getters
  bool get isLoading => _isLoading;
  String get profileImage => _profileImage;
  GlobalKey<FormState> get formKey => _formKey;
  String? get phoneNumber => _phoneNumber;
  String get selectedGender => _selectedGender;

  TextEditingController get firstNameController => _firstNameController;
  TextEditingController get surnameController => _surnameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get dobController => _dobController;

  FocusNode get firstNameFocusNode => _firstNameFocusNode;
  FocusNode get surnameFocusNode => _surnameFocusNode;
  FocusNode get emailFocusNode => _emailFocusNode;
  FocusNode get dobFocusNode => _dobFocusNode;

  void initialize() {
    _initializePrefs();
  }

  void setDobController(String value) {
    _dobController.text = value;
    notifyListeners();
  }

  void setSelectedGender(String value) {
    _selectedGender = value;
    notifyListeners();
  }

  void setPhoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> selectImage() async {
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
          _profileImage = croppedImage.path;
          notifyListeners();
        }
      } else {
        // Image is within the specified resolution, no need to crop

        _profileImage = pickedFile.path;
        notifyListeners();
      }
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> registerUser(BuildContext context) async {
    if (prefs == null) {
      await _initializePrefs();
    }

    final userDataString = prefs.getString('user');
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);

      userId = userData['userId'].toString();
      notifyListeners();
    }

    // Extracting user details from controllers
    final String email = emailController.text.trim();
    final String surname = surnameController.text.trim();
    final String firstName = firstNameController.text.trim();
    final String dob = dobController.text.trim();
    final String occupation = 'Student'; // Default value
    final String? jobTitle = _jobTitleController.text.trim();
    final String? company = _companyController.text.trim();
    final String? yearJoined = _yearJoinedController.text.trim();

    // Validating required fields
    if (surname.isEmpty ||
        firstName.isEmpty ||
        email.isEmpty ||
        phoneNumber!.isEmpty ||
        dob.isEmpty ||
        selectedState.isEmpty ||
        countryIsoCode.isEmpty) {
      CustomSnackbar.show(
        'All required fields must be filled.',
        isError: true,
      );
      return;
    }

    // Validating email format
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      CustomSnackbar.show(
        'Please enter a valid email address.',
        isError: true,
      );
      return;
    }

    // Validating phone number
    if (!_formKey.currentState!.validate()) {
      CustomSnackbar.show(
        'Please provide a valid phone number.',
        isError: true,
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Fetch the current FCM token
      final FirebaseMessaging messaging = FirebaseMessaging.instance;
      final String? currentFCMToken = await messaging.getToken();

      // Fetch the stored FCM token
      final String? storedFCMToken = prefs.getString('fcmToken');

      // Determine if the token needs to be sent
      final bool shouldSendFCMToken =
          storedFCMToken == null || currentFCMToken != storedFCMToken;

      print('Current FCM Token: $currentFCMToken');
      print('Stored FCM Token: $storedFCMToken');

      final url =
          Uri.parse('https://yarnapi-fuu0.onrender.com/api/auth/sign-up');
      final request = http.MultipartRequest('POST', url)
        ..fields['username'] = username
        ..fields['password'] = password
        ..fields['firstName'] = firstName
        ..fields['surname'] = surname
        ..fields['email'] = email
        ..fields['phone'] = phoneNumber!
        ..fields['gender'] = selectedGender
        ..fields['dateOfBirth'] = dob
        ..fields['state'] = selectedState
        ..fields['country'] = countryIsoCode
        ..fields['occupation'] = occupation
        ..fields['city'] = selectedCity;

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

      // Include FirebaseToken if available
      if (currentFCMToken != null) {
        request.fields['firebaseToken'] = currentFCMToken;
      }

      // Handling profile picture upload if it's a local file
      if (_profileImage != null && !_profileImage.startsWith('http')) {
        File imageFile = File(_profileImage);
        if (await imageFile.exists()) {
          var stream =
              http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
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
        print(
            'Skipping image upload as the profile image is from an HTTP source.');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(response.body);
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      if (response.statusCode == 200) {
        // Success: Saving the user data
        final Map<String, dynamic> data = responseData['data'];
        await storage.write(key: 'yarnAccessToken', value: data['token']);
        await prefs.setString(
          'user',
          jsonEncode({
            'userId': data['userId'],
            'username': data['username'],
            'firstName': firstName,
            'surname': surname,
            'email': email,
            'phone': phoneNumber,
            'gender': selectedGender,
            'dateOfBirth': dob,
            'state': selectedState,
            'country': countryIsoCode,
            'occupation': occupation,
            'jobTitle': jobTitle,
            'company': company,
            'yearJoined': yearJoined,
            'profilePicture': _profileImage,
            'city': selectedCity,
          }),
        );

        // Update stored FCM token
        if (shouldSendFCMToken && currentFCMToken != null) {
          await prefs.setString('fcmToken', currentFCMToken);
        }

        CustomSnackbar.show('Account created!', isError: false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainApp(
              key: UniqueKey(),
              onToggleDarkMode: onToggleDarkMode,
              isDarkMode: isDarkMode,
            ),
          ),
        );
      } else if (response.statusCode == 400) {
        final String message = responseData['message'];
        CustomSnackbar.show(message, isError: true);
      } else {
        CustomSnackbar.show('An unexpected error occurred.', isError: true);
      }
    } catch (e) {
      CustomSnackbar.show('An error occurred: $e', isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
