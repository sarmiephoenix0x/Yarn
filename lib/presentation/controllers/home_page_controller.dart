import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:signalr_core/signalr_core.dart';

import '../../core/widgets/custom_snackbar.dart';
import '../../core/widgets/location_dialog.dart';

class HomePageController extends ChangeNotifier {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _profileImage = '';
  TabController? _latestTabController;
  TabController? _profileTab;
  bool isLiked = false;
  final CarouselController _controller = CarouselController();
  Map<String, bool> _isFollowingMap = {};
  List<dynamic> _posts = [];
  bool _isLoading = true;
  int currentPage = 0;
  bool _hasMore = true;
  final storage = const FlutterSecureStorage();
  Map<int, bool> _isLikedMap =
      {}; // Map to store the like status of each post by postId
  Map<int, int> _likesMap =
      {}; // Map to store the number of likes for each post by postId
  Map<int, int> _commentsMap =
      {}; // Map to store the number of comments for each post by postId
  int? _userId;
  String? _detectedCountry;
  String? _detectedState;
  String? _detectedCity;
  Position? _position;
  bool _hasFetchedData = false;
  final ScrollController _timelineScrollController = ScrollController();
  bool _isLoadingMore = false;
  Map<int, ValueNotifier<bool>> _isLikedNotifiers = {};
  Map<int, ValueNotifier<int>> _likesNotifier = {};

  TickerProvider vsync;
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  final HubConnection? hubConnection;

  HomePageController(
      {required this.onToggleDarkMode,
      required this.isDarkMode,
      required this.hubConnection,
      required this.vsync}) {
    initialize();
  }

//public getters
  bool get isLoading => _isLoading;
  String get profileImage => _profileImage;
  int? get userId => _userId;
  List get posts => _posts;
  TabController? get profileTab => _profileTab;
  TabController? get latestTabController => _latestTabController;
  Map<int, ValueNotifier<bool>> get isLikedNotifiers => _isLikedNotifiers;
  Map<int, ValueNotifier<int>> get likesNotifier => _likesNotifier;
  Map<String, bool> get isFollowingMap => _isFollowingMap;
  Map<int, int> get commentsMap => _commentsMap;
  bool get hasFetchedData => _hasFetchedData;
  bool get hasMore => _hasMore;

  ScrollController get timelineScrollController => _timelineScrollController;
  TextEditingController get searchController => _searchController;

  FocusNode get searchFocusNode => _searchFocusNode;

  void resetHasFetchedData(bool value) {
    _hasFetchedData = value;
  }

  void initialize() {
    _timelineScrollController.addListener(() {
      if (_timelineScrollController.position.pixels >=
              _timelineScrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          _hasMore) {
        fetchPosts(loadMore: true); // Load the next page when near the end
      }
    });
    startSignalRConnection();
    if (!_hasFetchedData) {
      fetchUserProfilePic();
      fetchPosts();
      _hasFetchedData = true;
    }
    _latestTabController = TabController(length: 7, vsync: vsync);
    _profileTab = TabController(length: 2, vsync: vsync);
  }

  void didChangeDependenciesCall() {
    if (!_hasFetchedData) {
      fetchPosts();
      fetchUserProfilePic();
      _hasFetchedData = true;
    }
  }

  void startSignalRConnection() async {
    hubConnection?.on("PostLiked", (message) {
      print("Yarn Liked Signal");
      int postId = message![0];
      int likeCounts = message[1]; // Assuming likeCounts is the second item

      // Update the local maps and notifiers
      _isLikedMap[postId] = true;
      _likesMap[postId] = likeCounts; // Update likes count directly

      // Ensure likesNotifier is initialized for the postId
      if (!_likesNotifier.containsKey(postId)) {
        _likesNotifier[postId] = ValueNotifier<int>(likeCounts);
      } else {
        _likesNotifier[postId]!.value =
            likeCounts; // Update likes count in notifier
      }

      _isLikedNotifiers[postId]?.value = true; // Update liked state
      notifyListeners();
      print(likeCounts);
    });

    hubConnection?.on("PostUnliked", (message) {
      print("Yarn UnLiked Signal");
      int postId = message![0];
      int likeCounts = message[1]; // Assuming likeCounts is the second item

      // Update the local maps and notifiers
      _isLikedMap[postId] = false;
      _likesMap[postId] = likeCounts; // Update likes count directly

      // Ensure likesNotifier is initialized for the postId
      if (!_likesNotifier.containsKey(postId)) {
        _likesNotifier[postId] = ValueNotifier<int>(likeCounts);
      } else {
        _likesNotifier[postId]!.value =
            likeCounts; // Update likes count in notifier
      }

      _isLikedNotifiers[postId]?.value = false; // Update liked state
      notifyListeners();
      print(likeCounts);
    });

    hubConnection?.on("PostCommented", (message) {
      print("Yarn Commented Signal");
      int postId = message![0];
      int commentCounts =
          message[1]; // Assuming commentCounts is the second item

      _commentsMap[postId] = commentCounts; // Update comments count directly
      notifyListeners();
      print(commentCounts);
    });
  }

  Future<void> getLocation(BuildContext context) async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Show a dialog to inform the user about the need for location services
      showLocationDialog(context, "Location Required",
          "This app requires location access to provide accurate information and a better experience. Please enable location services in your settings.");
      return;
    }

    // Check and request location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Request permission if it's denied
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Show a dialog if permission is not granted
        showLocationDialog(context, "Location Permission Needed",
            "This app requires location permissions to function correctly. Please allow access in your settings.");
        return;
      }
    }

    // Retrieve the current position
    Position _position = await Geolocator.getCurrentPosition();

    // Fetch address from coordinates if _position is not null
    if (_position != null) {
      await _getAddressFromLatLng(_position);
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // Detected country, state, and city
        _detectedCountry = place.country;
        _detectedState = place.administrativeArea;
        _detectedCity = place.locality;

        print(
            'Detected country: $_detectedCountry, state: $_detectedState, city: $_detectedCity');
      }
    } catch (e) {
      print('Error in _getAddressFromLatLng: $e');
    }
  }

  Future<void> fetchUserProfilePic() async {
    _userId = await getUserIdFromPrefs();
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final url = 'https://yarnapi-fuu0.onrender.com/api/users/$userId';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        final profilePictureUrl = responseData['data']['personalInfo']
                ?['profilePictureUrl']
            ?.toString()
            .trim();

        _profileImage =
            (profilePictureUrl != null && profilePictureUrl.isNotEmpty)
                ? '$profilePictureUrl/download?project=66e4476900275deffed4'
                : '';
        notifyListeners();

        print("Profile Pic Loaded${response.body}");
        print(_profileImage);
      } else {
        print('Error fetching profile Pic: ${response.statusCode}');

        _isLoading = false;
        notifyListeners();
      }
    } catch (error) {
      print('Error: $error');

      _isLoading = false;
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

  Future<void> fetchPosts({bool loadMore = false, int pageNum = 1}) async {
    if (loadMore && (_isLoadingMore || !_hasMore)) return;

    _isLoading = !loadMore;
    _isLoadingMore = loadMore;
    if (!loadMore && pageNum == 1) {
      _posts.clear(); // Clear only on initial load
    }
    notifyListeners();

    try {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      if (accessToken == null) {
        CustomSnackbar.show('Authentication failed. Please log in again.',
            isError: true);
        _isLoading = _isLoadingMore = false;
        notifyListeners();
        return;
      }

      final url = Uri.parse(
          'https://yarnapi-fuu0.onrender.com/api/posts/home/$_detectedCity/$pageNum');
      final response = await http
          .get(url, headers: {'Authorization': 'Bearer $accessToken'});
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> fetchedPosts = responseBody['data'] ?? [];

        if (loadMore) {
          final newPosts = fetchedPosts.where((post) {
            return !_posts.any(
                (existingPost) => existingPost['postId'] == post['postId']);
          }).toList();

          if (newPosts.isEmpty) {
            // If there are no new posts, we’ve reached the end.
            _hasMore = false;
            CustomSnackbar.show('No more yarns to load.', isError: false);
          } else {
            _posts.addAll(newPosts);
            _hasMore = true;
          }
        } else {
          _posts = fetchedPosts;
          _hasMore = fetchedPosts.isNotEmpty;
        }

        currentPage = pageNum;
        notifyListeners();
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      CustomSnackbar.show('Failed to load yarns.', isError: true);
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void _handleErrorResponse(http.Response response) {
    if (response.statusCode == 400) {
      print('Error 400: ${response.body}');
      CustomSnackbar.show(
        'Failed to load yarns. Bad request.',
        isError: true,
      );
    } else {
      print('Unexpected error: ${response.body}');
      CustomSnackbar.show(
        'An unexpected error occurred.',
        isError: true,
      );
    }
  }

  Future<void> submitComment(
      int postId, TextEditingController commentController) async {
    final String comment = commentController.text.trim();
    if (comment.isEmpty) {
      CustomSnackbar.show(
        'Please enter a comment.',
        isError: true,
      );
      return;
    }

    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final uri = Uri.parse(
        'https://yarnapi-fuu0.onrender.com/api/posts/$postId/comments');
    // Log the comment and URL for debugging
    print("Submitting Comment:");
    print("Comment: $comment");
    print("POST URL: $uri");

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'Comment': comment}),
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);
        print('Comment added successfully: ${responseData['message']}');
        commentController.clear(); // Clear the input field after submission
      } catch (e) {
        print('Error parsing response: $e');
        CustomSnackbar.show(
          'Error adding comment. Invalid response from server.',
          isError: true,
        );
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        CustomSnackbar.show(
          'Error adding comment: ${errorData['message'] ?? 'Unknown error'}',
          isError: true,
        );
      } catch (e) {
        // If the response is not valid JSON, show the raw response text
        print('Error response: ${response.body}');
        CustomSnackbar.show(
          'Error adding comment. Server returned an unexpected response.',
          isError: true,
        );
      }
    }
  }

  Future<void> toggleLike(
      BuildContext context, dynamic post, int creatorUserId) async {
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final uri = Uri.parse(
        'https://yarnapi-fuu0.onrender.com/api/posts/toggle-like/${post['postId']}');

    bool currentLikedState = isLikedNotifiers[post['postId']]!.value;

    isLikedNotifiers[post['postId']]!.value = !currentLikedState;

    if (isLikedNotifiers[post['postId']]!.value) {
      likesNotifier[post['postId']]!.value++;
    } else {
      likesNotifier[post['postId']]!.value =
          (likesNotifier[post['postId']]!.value > 0)
              ? likesNotifier[post['postId']]!.value - 1
              : 0;
    }
    notifyListeners();
    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);

      // Revert optimistic update if the API call fails
      isLikedNotifiers[post['postId']]!.value =
          currentLikedState; // revert to old state

      // Update the likes count based on the reverted state
      likesNotifier[post['postId']]!.value = currentLikedState
          ? likesNotifier[post['postId']]!.value - 1
          : likesNotifier[post['postId']]!.value + 1;
      notifyListeners();
      CustomSnackbar.show(
        'Error: ${errorData['message']}',
        isError: true,
      );
    }
    print("Test: ${likesNotifier[post['postId']]!.value}");
    print("IDs: $userId $creatorUserId");
  }
}
