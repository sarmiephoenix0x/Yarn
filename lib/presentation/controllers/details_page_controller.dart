import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../core/widgets/custom_snackbar.dart';

class DetailsPageController extends ChangeNotifier {
  late Future<Map<String, dynamic>?> _newsFuture;
  final storage = const FlutterSecureStorage();
  final GlobalKey _key = GlobalKey();
  final FocusNode _commentFocusNode = FocusNode();

  final TextEditingController commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;
  bool _isLiked = false;
  bool _isBookmarked = false;
  final CarouselController _controller = CarouselController();
  int _current = 0;
  bool _isFollowing = false;
  int likes = 0;
  int? localUserId;
  bool _isMe = false;

  final int userId;
  final int postId;
  final List<String> postImg;
  final String authorImg;
  final String headerImg;
  final String description;
  final String authorName;
  final bool verified;
  final bool anonymous;
  final String time;
  final bool isFollowingWidget;
  final String likesWidget;
  final String comments;
  final bool isLikedWidget;
  final int senderId;
  final List<String> labels;

  DetailsPageController(
      {required this.postId,
      required this.postImg,
      required this.authorImg,
      required this.headerImg,
      required this.description,
      required this.authorName,
      required this.verified,
      required this.anonymous,
      required this.time,
      required this.isFollowingWidget,
      required this.likesWidget,
      required this.comments,
      required this.isLikedWidget,
      required this.senderId,
      required this.labels,
      required this.userId}) {
    initialize();
  }

//public getters
  GlobalKey get key => _key;
  bool get isMe => _isMe;
  bool get isFollowing => _isFollowing;
  bool get isLiked => _isLiked;
  bool get isBookmarked => _isBookmarked;

  void setIsBookmarked(bool value) {
    _isBookmarked = value;
    notifyListeners();
  }

  void initialize() {
    fetchLocalUserProfile();
    _isFollowing = isFollowingWidget;
    _isLiked = isLikedWidget; // Set initial liked state
    likes = int.parse(likesWidget);
    _scrollController.addListener(() {
      if (_scrollController.offset <= 0) {
        if (_isRefreshing) {
          // Logic to cancel refresh if needed

          _isRefreshing = false;
          notifyListeners();
        }
      }
    });
  }

  void showPopupMenu(BuildContext context) async {
    final RenderBox renderBox =
        _key.currentContext!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx,
          position.dy + renderBox.size.height,
          position.dx + renderBox.size.width,
          position.dy),
      items: [
        PopupMenuItem<String>(
          value: 'Share',
          child: Row(
            children: [
              Image.asset(
                'images/share-box-line.png',
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              const Text(
                'Share',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'Report',
          child: Row(
            children: [
              Image.asset(
                'images/feedback-line.png',
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              const Text(
                'Report',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'Save',
          child: Row(
            children: [
              Image.asset(
                'images/save-line.png',
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              const Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'Open',
          child: Row(
            children: [
              Image.asset(
                'images/basketball-line.png',
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              const Text(
                'Open in browser',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value != null) {
        _handleMenuSelection(value);
      }
    });
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'Share':
        break;
      case 'Report':
        break;
      case 'Save':
        break;
      case 'Open':
        break;
    }
  }

  Future<void> fetchLocalUserProfile() async {
    localUserId = await getUserIdFromPrefs();
    if (userId == localUserId) {
      _isMe = true;
      notifyListeners();
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('$isMe')),
      // );
    }
  }

  Future<void> toggleLike() async {
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final uri = Uri.parse(
        'https://yarnapi-fuu0.onrender.com/api/posts/toggle-like/$postId');

    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Toggle the liked state and update the like count
      _isLiked = !isLiked;
      likes = isLiked ? likes + 1 : likes - 1;
      notifyListeners();
    } else {
      final errorData = json.decode(response.body);
      // Handle error - you might want to show a dialog or a Snackbar
      print('Error toggling like: ${errorData['message']}');
      CustomSnackbar.show(
        'Error: ${errorData['message']}',
        isError: true,
      );
    }
  }

  String formatUpvotes(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K'; // Appends 'K' for 1000+
    } else {
      return count.toString();
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
}
