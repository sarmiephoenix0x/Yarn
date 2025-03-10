import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_core/signalr_core.dart';

import '../../core/widgets/custom_snackbar.dart';

class UserProfileController extends ChangeNotifier {
  String _profileImage = '';
  TabController? _latestTabController;
  TabController? _profileTab;
  bool _isFollowing = false;
  String? _userName;
  String? _occupation;
  int _followers = 0;
  int _following = 0;
  int _posts = 0;
  int _locations = 0;

  // Variables for managing timeline posts
  List<dynamic> _timelinePosts = [];
  bool _isLoadingTimeline = false;
  bool _hasMoreTimeline = true;
  int _currentPageTimeline = 1;

  // Variables for managing community posts
  List<dynamic> _communityPosts = [];
  bool _isLoadingCommunity = false;
  bool _hasMoreCommunity = true;
  int _currentPageCommunity = 1;

  // Error tracking variable
  bool _isError = false;
  final storage = const FlutterSecureStorage();

  final CarouselController _controller = CarouselController();
  Map<String, bool> _isFollowingMap = {};

  bool _isLoading = true;
  Map<int, bool> _isLikedMap = {};
  Map<int, int> _likesMap = {};
  Map<int, int> _commentsMap = {};
  bool _hasFetchedData = false;
  bool _isLoadingMoreTimeline = false;
  bool _isLoadingMoreCommunity = false;
  final ScrollController _timelineScrollController = ScrollController();
  final ScrollController _communityScrollController = ScrollController();
  Map<int, ValueNotifier<bool>> _isLikedNotifiers = {};
  Map<int, ValueNotifier<int>> _likesNotifier = {};

  TickerProvider vsync;
  final int userId;

  UserProfileController({required this.vsync, required this.userId}) {
    initialize();
  }

//public getters
  bool get isLoading => _isLoading;
  String get profileImage => _profileImage;
  String? get userName => _userName;
  int get followers => _followers;
  int get following => _following;
  int get posts => _posts;
  int get locations => _locations;
  String? get occupation => _occupation;
  bool get isLoadingTimeline => _isLoadingTimeline;
  bool get hasMoreTimeline => _hasMoreTimeline;
  List get timelinePosts => _timelinePosts;
  bool get isLoadingCommunity => _isLoadingCommunity;
  List get communityPosts => _communityPosts;
  bool get hasMoreCommunity => _hasMoreCommunity;
  TabController? get profileTab => _profileTab;
  Map<int, ValueNotifier<bool>> get isLikedNotifiers => _isLikedNotifiers;
  Map<int, ValueNotifier<int>> get likesNotifier => _likesNotifier;
  Map<String, bool> get isFollowingMap => _isFollowingMap;
  Map<int, int> get commentsMap => _commentsMap;
  bool get hasFetchedData => _hasFetchedData;
  bool get isFollowing => _isFollowing;

  ScrollController get timelineScrollController => _timelineScrollController;
  ScrollController get communityScrollController => _communityScrollController;

  void resetHasFetchedData(bool value) {
    _hasFetchedData = value;
    notifyListeners();
  }

  void initialize() {
    _timelineScrollController.addListener(() {
      if (_timelineScrollController.position.pixels >=
              _timelineScrollController.position.maxScrollExtent - 200 &&
          !isLoadingTimeline &&
          hasMoreTimeline) {
        fetchMyTimelinePosts(
            loadMore: true); // Load the next page when near the end
      }
    });

    _communityScrollController.addListener(() {
      if (_communityScrollController.position.pixels >=
              _communityScrollController.position.maxScrollExtent - 200 &&
          !isLoadingCommunity &&
          hasMoreCommunity) {
        fetchMyCommunityPosts(
            loadMore: true); // Load the next page when near the end
      }
    });
    if (!_hasFetchedData) {
      fetchUserProfile();
      fetchMyTimelinePosts();
      fetchMyCommunityPosts();
      _hasFetchedData = true;
      notifyListeners();
    }
    // _fetchUserData();
    _latestTabController = TabController(length: 7, vsync: vsync);
    _profileTab = TabController(length: 2, vsync: vsync);
  }

  void didChangeDependenciesCall() {
    if (!_hasFetchedData) {
      fetchUserProfile();
      fetchMyTimelinePosts();
      fetchMyCommunityPosts();
      _hasFetchedData = true;
      notifyListeners();
    }
  }

  Future<void> fetchMyTimelinePosts(
      {bool loadMore = false, int pageNum = 1}) async {
    if (loadMore && (_isLoadingMoreTimeline || !hasMoreTimeline)) return;

    if (loadMore) {
      _isLoadingMoreTimeline = true;
    } else {
      _isLoadingTimeline = true;
    }
    notifyListeners();

    try {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      final url = Uri.parse(
          'https://yarnapi-fuu0.onrender.com/api/posts/my-timeline/$pageNum');

      if (pageNum == 1 && !loadMore) {
        timelinePosts.clear();
        _hasMoreTimeline = true;
        notifyListeners();
      }

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $accessToken',
      });

      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> fetchedPosts = responseBody['data'] ?? [];

        if (fetchedPosts.isEmpty && pageNum == 1) {
          CustomSnackbar.show(
            'No timeline yarns available at the moment.',
            isError: false,
          );
        }

        if (loadMore) {
          final newPosts = fetchedPosts.where((post) {
            return !timelinePosts.any(
                (existingPost) => existingPost['postId'] == post['postId']);
          }).toList();

          if (newPosts.isEmpty) {
            _hasMoreTimeline = false;
            CustomSnackbar.show('No more timeline yarns to load.',
                isError: false);
          } else {
            timelinePosts.addAll(newPosts);
            _hasMoreTimeline = true;
          }
        } else {
          _timelinePosts = fetchedPosts;
          _hasMoreTimeline = fetchedPosts.isNotEmpty;
        }
        _currentPageTimeline = pageNum;
        notifyListeners();
      } else {
        CustomSnackbar.show('Failed to load timeline yarns.', isError: true);
      }
    } catch (e) {
      CustomSnackbar.show('Failed to load timeline yarns.', isError: true);
    } finally {
      _isLoadingTimeline = false;
      _isLoadingMoreTimeline = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyCommunityPosts(
      {bool loadMore = false, int pageNum = 1}) async {
    if (loadMore && (_isLoadingMoreCommunity || !hasMoreCommunity)) return;

    if (loadMore) {
      _isLoadingMoreCommunity = true;
    } else {
      _isLoadingCommunity = true;
    }
    notifyListeners();

    try {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      final url = Uri.parse(
          'https://yarnapi-fuu0.onrender.com/api/posts/my-community/$pageNum');

      if (pageNum == 1 && !loadMore) {
        communityPosts.clear();
        _hasMoreCommunity = true;
        notifyListeners();
      }

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> fetchedPosts = responseBody['data'] ?? [];

        if (fetchedPosts.isEmpty && pageNum == 1) {
          CustomSnackbar.show(
            'No community yarns available at the moment.',
            isError: false,
          );
        }

        if (loadMore) {
          final newPosts = fetchedPosts.where((post) {
            return !communityPosts.any(
                (existingPost) => existingPost['postId'] == post['postId']);
          }).toList();

          if (newPosts.isEmpty) {
            _hasMoreCommunity = false;
            CustomSnackbar.show('No more community yarns to load.',
                isError: false);
          } else {
            communityPosts.addAll(newPosts);
            _hasMoreCommunity = true;
          }
        } else {
          _communityPosts = fetchedPosts;
          _hasMoreCommunity = fetchedPosts.isNotEmpty;
        }
        _currentPageCommunity = pageNum;
        notifyListeners();
      } else {
        CustomSnackbar.show('Failed to load community yarns.', isError: true);
      }
    } catch (e) {
      CustomSnackbar.show('Failed to load community yarns.', isError: true);
    } finally {
      _isLoadingCommunity = false;
      _isLoadingMoreCommunity = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserProfile() async {
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

        _followers = responseData['data']['followersCount'];
        _following = responseData['data']['followingsCount'];
        _posts = responseData['data']['postsCount'];
        _locations = responseData['data']['followedLocationCount'];
        _userName = responseData['data']['username'];
        _occupation = responseData['data']['occupation'];
        final profilePictureUrl = responseData['data']['personalInfo']
                ?['profilePictureUrl']
            ?.toString()
            .trim();

        _profileImage =
            (profilePictureUrl != null && profilePictureUrl.isNotEmpty)
                ? '$profilePictureUrl/download?project=66e4476900275deffed4'
                : '';
        _isLoading = false;
        notifyListeners();

        print("Profile Loaded${response.body}");
        print(_profileImage);
      } else {
        print('Error fetching profile: ${response.statusCode}');

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

  Future<void> followUser() async {
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final url = 'https://yarnapi-fuu0.onrender.com/api/users/follow/$userId';
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}), // Add an empty body if required
      );

      if (response.statusCode == 200) {
        // Check if response body is not empty before parsing
        if (response.body.isNotEmpty) {
          final responseData = json.decode(response.body);
          print('Follow successful: ${responseData['message']}');
        } else {
          print('Follow successful: No response body');
        }

        _isFollowing = true;
        notifyListeners();
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Follow error: $error');
    }
  }

  Future<void> unfollowUser() async {
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final url = 'https://yarnapi-fuu0.onrender.com/api/users/unfollow/$userId';
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}), // Add an empty body if required
      );

      if (response.statusCode == 200) {
        // Check if response body is not empty before parsing
        if (response.body.isNotEmpty) {
          final responseData = json.decode(response.body);
          print('Unfollow successful: ${responseData['message']}');
        } else {
          print('Unfollow successful: No response body');
        }

        _isFollowing = false;
        notifyListeners();
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Unfollow error: $error');
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
