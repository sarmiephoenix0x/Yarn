import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SearchPageController extends ChangeNotifier {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _profileImage = '';
  TabController? _explorerTabController;
  Map<String, bool> _isSaveMap = {};
  Map<String, bool> _isFollowingMap = {};
  bool _isLoading = true; // Loading state
  List<dynamic> _pages = [];
  String _errorMessage = '';
  final storage = const FlutterSecureStorage();
  int? userId;
  List<dynamic> locationsList = [];
  List<Map<String, dynamic>> _filteredLocationsList = [];
  bool _isLoading2 = true;

  TickerProvider vsync;

  SearchPageController({required this.vsync}) {
    initialize();
  }

//public getters
  bool get isLoading => _isLoading;
  bool get isLoading2 => _isLoading2;
  String get errorMessage => _errorMessage;
  List get pages => _pages;
  List<Map<String, dynamic>> get filteredLocationsList =>
      _filteredLocationsList;
  Map<String, bool> get isFollowingMap => _isFollowingMap;
  TabController? get explorerTabController => _explorerTabController;
  String get profileImage => _profileImage;

  TextEditingController get searchController => _searchController;

  FocusNode get searchFocusNode => _searchFocusNode;

  void setIsFollowingMap(String id, bool value) {
    _isFollowingMap[id] = value;
    notifyListeners();
  }

  void initialize() {
    fetchLocations();
    fetchPages();
    _explorerTabController = TabController(length: 3, vsync: vsync);
  }

  Future<void> fetchLocations() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('https://yarnapi-fuu0.onrender.com/api/locations'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        locationsList = List<Map<String, dynamic>>.from(data['data']);
        _filteredLocationsList =
            List.from(locationsList); // Initialize filtered list
        _isFollowingMap = {
          for (var loc in locationsList)
            loc['id'].toString(): loc['isFollowing'] ?? false
        };
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = 'Failed to load locations';
        _isLoading = false;
        notifyListeners();
      }
    } catch (error) {
      _errorMessage = 'An error occurred. Please try again later.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPages() async {
    userId = await getUserIdFromPrefs();

    _isLoading = true; // Start loading
    notifyListeners();

    try {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');

      final url = 'https://yarnapi-fuu0.onrender.com/api/pages';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      print("Author Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Check if the 'status' is "Success" and extract the 'data' array
        if (jsonResponse['status'] == 'Success') {
          final List<dynamic> pages = jsonResponse['data'];

          _pages = pages; // Set the pages list
          _isLoading = false; // Stop loading after success
          notifyListeners();
        } else {
          _errorMessage = 'Failed to load pages'; // Handle unexpected responses
          _isLoading = false; // Stop loading after failure
          notifyListeners();
        }
      } else {
        _errorMessage = 'Failed to load pages';
        _isLoading = false; // Stop loading after failure
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please try again later.';
      _isLoading = false; // Stop loading after error
      notifyListeners();
    }
  }

  Future<int?> getUserIdFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the saved 'user' data
    String? userData = prefs.getString('user');

    // Check if the 'user' data exists
    if (userData != null) {
      // Decode the JSON-encoded string to a Map
      Map<String, dynamic> userMap = jsonDecode(userData);

      // Access the userId from the Map
      return userMap['userId'];
    }

    // Return null if no 'user' data is found
    return null;
  }

  void searchLocations(String query) {
    if (query.isEmpty) {
      // Show all if the query is empty
      _filteredLocationsList = List<Map<String, dynamic>>.from(locationsList);
    } else {
      _filteredLocationsList = locationsList
          .where((location) {
            final locationName = location['name']?.toString().toLowerCase();
            final searchQuery = query.toLowerCase();
            return locationName != null && locationName.contains(searchQuery);
          })
          .toList()
          .cast<
              Map<String,
                  dynamic>>(); // Ensure the result is cast to List<Map<String, dynamic>>
    }
    notifyListeners();
  }
}
