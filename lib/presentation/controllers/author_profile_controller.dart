import 'dart:convert';

import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../core/widgets/custom_snackbar.dart';

class AuthorProfileController extends ChangeNotifier {
  int _selectedIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<bool> _hasNotification = [false, false, false, false];
  TabController? _latestTabController;
  TabController? _profileTab;
  bool _isFollowing = false;
  Map<String, bool> _isFollowingMap = {};
  List<dynamic> _posts = [];
  bool _isLoading = true;
  int _currentPage = 0;
  bool _hasMore = true;
  final storage = const FlutterSecureStorage();
  Map<int, bool> _isLikedMap = {};
  Map<int, int> _commentsMap = {};
  final ScrollController _timelineScrollController = ScrollController();
  bool _isLoadingMore = false;
  Map<int, ValueNotifier<bool>> _isLikedNotifiers = {};
  Map<int, ValueNotifier<int>> _likesNotifier = {};

  TickerProvider vsync;
  final int pageId;
  final int senderId;
  final String profileImage;
  final String pageName;
  final String pageDescription;

  AuthorProfileController(
      {required this.pageId,
      required this.senderId,
      required this.pageName,
      required this.profileImage,
      required this.pageDescription,
      required this.vsync}) {
    initialize();
  }

//public getters
  bool get isLoading => _isLoading;
  List<dynamic> get posts => _posts;
  TabController? get profileTab => _profileTab;
  Map<int, ValueNotifier<bool>> get isLikedNotifiers => _isLikedNotifiers;
  Map<int, ValueNotifier<int>> get likesNotifier => _likesNotifier;
  Map<String, bool> get isFollowingMap => _isFollowingMap;
  Map<int, int> get commentsMap => _commentsMap;
  bool get isFollowing => _isFollowing;
  bool get hasMore => _hasMore;

  ScrollController get timelineScrollController => _timelineScrollController;
  TextEditingController get searchController => _searchController;

  void initialize() {
    _timelineScrollController.addListener(() {
      if (_timelineScrollController.position.pixels >=
              _timelineScrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          _hasMore) {
        fetchPosts(loadMore: true); // Load the next page when near the end
      }
    });
    fetchPosts();
    _latestTabController = TabController(length: 7, vsync: vsync);
    _profileTab = TabController(length: 2, vsync: vsync);
  }

  Future<void> fetchPosts({bool loadMore = false, int pageNum = 1}) async {
    if (loadMore && (_isLoadingMore || !_hasMore)) return;

    _isLoading = !loadMore;
    _isLoadingMore = loadMore;
    if (!loadMore && pageNum == 1) _posts.clear(); // Clear only on initial load
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
          'https://yarnapi-fuu0.onrender.com/api/posts/page/$pageId/$pageNum');
      final response = await http
          .get(url, headers: {'Authorization': 'Bearer $accessToken'});

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
            posts.addAll(newPosts);
            _hasMore = true;
          }
        } else {
          _posts = fetchedPosts;
          _hasMore = fetchedPosts.isNotEmpty;
        }

        _currentPage = pageNum;
        notifyListeners();
      } else {
        handleErrorResponse(response);
      }
    } catch (e) {
      CustomSnackbar.show('Failed to load yarns.', isError: true);
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void handleErrorResponse(http.Response response) {
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

  Future<void> followUser() async {
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final url = 'https://yarnapi-fuu0.onrender.com/api/pages/$pageId/follow';
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
    final url = 'https://yarnapi-fuu0.onrender.com/api/pages/$pageId/unfollow';
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
    print("IDs: $senderId $creatorUserId");
  }
}
