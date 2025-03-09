import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/widgets/custom_snackbar.dart';
import '../screens/main_app/main_app.dart';
import '../screens/sign_in_page/widgets/dialogs/sign_in_error.dart';
import '../screens/sign_in_page/widgets/dialogs/prompt_user_for_permission.dart';

class SignInPageController extends ChangeNotifier {
  final FocusNode _userNameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();
  late SharedPreferences prefs;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool isGoogleLoading = false;

  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;

  SignInPageController(
      {required this.onToggleDarkMode, required this.isDarkMode}) {
    initialize();
  }

//public getters
  bool get isLoading => _isLoading;
  bool get rememberMe => _rememberMe;

  TextEditingController get userNameController => _userNameController;
  TextEditingController get passwordController => _passwordController;

  FocusNode get userNameFocusNode => _userNameFocusNode;
  FocusNode get passwordFocusNode => _passwordFocusNode;

  void setRememberMe(bool? value) {
    _rememberMe = value!;
    notifyListeners();
  }

  void setIsGoogleLoading(bool value) {
    isGoogleLoading = value;
    notifyListeners();
  }

  void initialize() {
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/user.gender.read',
      'https://www.googleapis.com/auth/user.birthday.read',
    ],
  );

  Future<void> handleSignIn(BuildContext context) async {
    try {
      print('Attempting Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        isGoogleLoading = true;
        notifyListeners();
        print('Google Sign-In successful. Retrieving authentication token...');
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        String authToken = googleAuth.idToken!;
        print('Authentication Token: $authToken');

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);

        final String? fullName = googleUser.displayName;
        final String? email = googleUser.email;

        final List<String>? nameParts = fullName?.split(' ');
        final String? firstName = nameParts?.first;
        final String surname = nameParts!.length > 1 ? nameParts.last : '';
      } else {
        isGoogleLoading = false;
        notifyListeners();
        print('Google Sign-In canceled.');
      }
    } on PlatformException catch (e) {
      print('PlatformException: $e');
      if (e.code == 'sign_in_required') {
        promptUserForPermission(
            e, context, handlePermissionGranted, handlePermissionDenied);
      } else {
        showSignInErrorDialog(e, context, setIsGoogleLoading);
      }
    } catch (error) {
      isGoogleLoading = false;
      notifyListeners();
      print('Error during Google Sign-In: $error');
      showSignInErrorDialog(error, context, setIsGoogleLoading);
    }
  }

  void handlePermissionGranted(BuildContext context) {
    print('User granted permission.');
  }

  void handlePermissionDenied(BuildContext context) {
    print('User denied permission.');
  }

  Future<void> submitForm(BuildContext context) async {
    if (prefs == null) {
      await _initializePrefs();
    }

    final String username = userNameController.text.trim();
    final String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      CustomSnackbar.show(
        'All fields are required.',
        isError: true,
      );
      return;
    }

    // Validate password length
    if (password.length < 6) {
      CustomSnackbar.show(
        'Password must be at least 6 characters.',
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

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'username': username,
        'password': password,
      };

      if (shouldSendFCMToken && currentFCMToken != null) {
        requestBody['firebaseToken'] = currentFCMToken;
      }

      // Send the POST request
      final response = await http.post(
        Uri.parse('https://yarnapi-fuu0.onrender.com/api/auth/sign-in'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      print('Response Status: ${response.statusCode}');
      print('Response Body Length: ${response.body.length}');
      print('Response Body: "${response.body}"');
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // The response format: {status, data: {userId, token, username}}
        final Map<String, dynamic> data = responseData['data'];
        final String token = data['token'];
        final int userId = data['userId'];
        final String userName = data['username'];

        // Store the token and user information
        await storage.write(key: 'yarnAccessToken', value: token);
        await prefs.setString(
          'user',
          jsonEncode({
            'userId': userId,
            'username': userName,
          }),
        );

        // Update the stored FCM token if it was sent
        if (shouldSendFCMToken && currentFCMToken != null) {
          await prefs.setString('fcmToken', currentFCMToken);
        }

        // Show success message
        CustomSnackbar.show(
          'Sign In Successful!',
          isError: false,
        );

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
        _isLoading = false;
        notifyListeners();
        final String message = responseData['message'];

        // Handle validation error
        CustomSnackbar.show(
          'Error: $message',
          isError: true,
        );
      } else {
        _isLoading = false;
        notifyListeners();
        // Handle other unexpected responses
        CustomSnackbar.show(
          'An unexpected error occurred.',
          isError: true,
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error: $e');
      CustomSnackbar.show(
        'An error occurred. Please try again later.',
        isError: true,
      );
    }
  }
}
