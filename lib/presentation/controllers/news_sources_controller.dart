import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:async/async.dart';

import '../../core/widgets/custom_snackbar.dart';
import '../screens/main_app/main_app.dart';

class NewsSourcesController extends ChangeNotifier {
  bool _isLoading = false;
  final storage = const FlutterSecureStorage();
  late SharedPreferences prefs;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Map<String, bool> _isFollowingMap = {};
  String userId = '';
  String? userName;
  List<dynamic> communities = [];
  List<dynamic> _filteredCommunities = [];
  bool _isError = false;
  bool _isLoading2 = true;

  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  final String emailWidget;
  final String surnameWidget;
  final String firstNameWidget;
  final String phoneNumberWidget;
  final String dobWidget;
  final String stateWidget;
  final String countryWidget;
  final String occupationWidget;
  final String? jobTitleWidget;
  final String? companyWidget;
  final int? yearJoinedWidget;
  final String selectedGenderWidget;
  final String profileImageWidget;

  NewsSourcesController(
      {required this.onToggleDarkMode,
      required this.isDarkMode,
      required this.emailWidget,
      required this.surnameWidget,
      required this.firstNameWidget,
      required this.phoneNumberWidget,
      required this.dobWidget,
      required this.stateWidget,
      required this.countryWidget,
      required this.occupationWidget,
      this.jobTitleWidget,
      this.companyWidget,
      this.yearJoinedWidget,
      required this.selectedGenderWidget,
      required this.profileImageWidget}) {
    initialize();
  }

//public getters
  bool get isLoading => _isLoading;
  bool get isLoading2 => _isLoading2;
  bool get isError => _isError;
  List get filteredCommunities => _filteredCommunities;
  Map<String, bool> get isFollowingMap => _isFollowingMap;

  TextEditingController get searchController => _searchController;

  FocusNode get searchFocusNode => _searchFocusNode;

  void setIsFollowingMap(String key, bool value) {
    _isFollowingMap[key] = value;
    notifyListeners();
  }

  void initialize() {
    _initializePrefs();
    fetchCommunities();
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
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

    final String email = emailWidget;
    final String surname = surnameWidget;
    final String firstName = firstNameWidget;
    final String phoneNumber = phoneNumberWidget;
    final String dob = dobWidget;
    final String state = stateWidget;
    final String country = countryWidget;
    final String occupation =
        occupationWidget; // Replace with actual occupation input
    final String? jobTitle = jobTitleWidget;
    final String? company = companyWidget;
    final int? yearJoined = yearJoinedWidget;

    final List<int> pageToFollowIds = [];
    final List<int> communityToJoinIds = [];

    _isLoading = true;
    notifyListeners();

    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final url =
        Uri.parse('https://yarnapi-fuu0.onrender.com/api/auth/sign-up-details');

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..fields['userId'] = userId
      ..fields['firstName'] = firstName
      ..fields['surname'] = surname
      ..fields['email'] = email
      ..fields['phone'] = phoneNumber
      ..fields['gender'] = selectedGenderWidget
      ..fields['dateOfBirth'] = dob
      ..fields['state'] = state
      ..fields['country'] = country
      ..fields['occupation'] = occupation;

    if (jobTitle != null && jobTitle.isNotEmpty) {
      request.fields['jobTitle'] = jobTitle;
    }
    if (company != null && company.isNotEmpty) {
      request.fields['company'] = company;
    }
    if (yearJoined != null) {
      request.fields['yearJoined'] = yearJoined.toString();
    }
    if (pageToFollowIds.isNotEmpty) {
      request.fields['PageToFollowIds'] = pageToFollowIds.join(',');
    }
    if (communityToJoinIds.isNotEmpty) {
      request.fields['CommunityToJoinIds'] = communityToJoinIds.join(',');
    }

    // Check if widget.profileImage is a local file (not an HTTP URL) before uploading
    if (profileImageWidget != null &&
        profileImageWidget is File &&
        !profileImageWidget.startsWith('http')) {
      File imageFile = File(profileImageWidget);

      // Ensure the image file exists before adding it to the request
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

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final userDataString = prefs.getString('user');

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);

        userName = userData['username'].toString();
        notifyListeners();
      }

      CustomSnackbar.show(
        'Sign up complete! Welcome, $userName',
        isError: false,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainApp(
              key: UniqueKey(),
              onToggleDarkMode: onToggleDarkMode,
              isDarkMode: isDarkMode),
        ),
      );
    } else if (response.statusCode == 400) {
      _isLoading = false;
      notifyListeners();
      final responseData = jsonDecode(response.body);
      // final String error = responseData['error'];
      // final List<dynamic> data = responseData['data']['email'];
      final String message = responseData['message'];
      print(message);

      CustomSnackbar.show(
        message,
        isError: true,
      );
    } else {
      _isLoading = false;
      notifyListeners();
      CustomSnackbar.show(
        'An unexpected error occurred.',
        isError: true,
      );
    }
  }

  Future<void> fetchCommunities() async {
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    try {
      final response = await http.get(
        Uri.parse('https://yarnapi-fuu0.onrender.com/api/communities/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List && data.isNotEmpty) {
          communities = data; // Assuming data is a list of communities
          _filteredCommunities = communities; // Initialize with all communities
        } else {
          // Handle empty list case
          communities = [];
          _filteredCommunities = [];
        }
        _isError = false; // Reset error state
        notifyListeners();
      } else {
        _isError = true; // Set error state on non-200 response
        notifyListeners();
        // Handle error (e.g., show a snackbar or alert)
        print('Failed to load communities: ${response.body}');
      }
    } catch (e) {
      _isError = true; // Set error state on exception
      notifyListeners();
      print('Error fetching communities: $e');
    } finally {
      _isLoading2 = false; // Stop loading
      notifyListeners();
    }
  }

  void filterCommunities(String query) {
    final filtered = communities.where((community) {
      return community['name'].toLowerCase().contains(query.toLowerCase()) ||
          community['creator'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    _filteredCommunities =
        filtered; // Update filtered list based on search query
    notifyListeners();
  }
}
