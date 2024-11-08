import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:yarn/user_profile.dart';

import 'comments_page.dart';

class DetailsPage extends StatefulWidget {
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
  final bool isFollowing;
  final String likes;
  final String comments;
  final bool isLiked;
  final int senderId;
  final List<String> labels;

  const DetailsPage(
      {super.key,
      required this.postId,
      required this.postImg,
      required this.authorImg,
      required this.headerImg,
      required this.description,
      required this.authorName,
      required this.verified,
      required this.anonymous,
      required this.time,
      required this.isFollowing,
      required this.likes,
      required this.comments,
      required this.isLiked,
      required this.userId,
      required this.senderId,
      required this.labels});

  @override
  DetailsPageState createState() => DetailsPageState();
}

class DetailsPageState extends State<DetailsPage> {
  late Future<Map<String, dynamic>?> _newsFuture;
  final storage = const FlutterSecureStorage();
  final GlobalKey _key = GlobalKey();
  final FocusNode _commentFocusNode = FocusNode();

  final TextEditingController commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;
  bool isLiked = false;
  bool isBookmarked = false;
  final CarouselController _controller = CarouselController();
  int _current = 0;
  bool isFollowing = false;
  int likes = 0;
  int? localUserId;
  bool isMe = false;

  void _showPopupMenu(BuildContext context) async {
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

  @override
  void initState() {
    super.initState();
    fetchLocalUserProfile();
    isFollowing = widget.isFollowing;
    isLiked = widget.isLiked; // Set initial liked state
    likes = int.parse(widget.likes);
    _scrollController.addListener(() {
      if (_scrollController.offset <= 0) {
        if (_isRefreshing) {
          // Logic to cancel refresh if needed
          setState(() {
            _isRefreshing = false;
          });
        }
      }
    });
  }

  Future<void> fetchLocalUserProfile() async {
    localUserId = await getUserIdFromPrefs();
    if (widget.userId == localUserId) {
      setState(() {
        isMe = true;
      });
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('$isMe')),
      // );
    }
  }

  Future<void> _toggleLike() async {
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final uri = Uri.parse(
        'https://yarnapi-n2dw.onrender.com/api/posts/toggle-like/${widget.postId}');

    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        // Toggle the liked state and update the like count
        isLiked = !isLiked;
        likes = isLiked ? likes + 1 : likes - 1;
      });
    } else {
      final errorData = json.decode(response.body);
      // Handle error - you might want to show a dialog or a Snackbar
      print('Error toggling like: ${errorData['message']}');
      _showCustomSnackBar(
        context,
        'Error: ${errorData['message']}',
        isError: true,
      );
    }
  }

  String _formatUpvotes(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K'; // Appends 'K' for 1000+
    } else {
      return count.toString();
    }
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

  Future<void> followUser() async {
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final url =
        'https://yarnapi-n2dw.onrender.com/api/users/follow/${widget.userId}';
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

        setState(() {
          isFollowing = true;
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Follow error: $error');
    }
  }

  Future<void> unfollowUser() async {
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final url =
        'https://yarnapi-n2dw.onrender.com/api/users/unfollow/${widget.userId}';
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

        setState(() {
          isFollowing = false;
        });
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

  @override
  Widget build(BuildContext context) {
    Color originalIconColor = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) {
        return Center(
          child: SizedBox(
            height: orientation == Orientation.portrait
                ? MediaQuery.of(context).size.height
                : MediaQuery.of(context).size.height * 1.5,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Image.asset(
                                'images/BackButton.png',
                                height: 25,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(Icons.share),
                              onPressed: () {},
                            ),
                            SizedBox(
                              key: _key,
                              child: IconButton(
                                icon: const Icon(Icons.more_vert_outlined),
                                onPressed: () {
                                  // _showPopupMenu(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: InkWell(
                          onTap: () {
                            if (widget.anonymous == false) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserProfile(
                                    key: UniqueKey(),
                                    userId: widget.userId,
                                    senderId: widget.senderId,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Row(
                            children: [
                              if (widget.anonymous == false)
                                if (widget.authorImg.isEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(55),
                                    child: Container(
                                      width: (50 /
                                              MediaQuery.of(context)
                                                  .size
                                                  .width) *
                                          MediaQuery.of(context).size.width,
                                      height: (50 /
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
                                      width: (50 /
                                              MediaQuery.of(context)
                                                  .size
                                                  .width) *
                                          MediaQuery.of(context).size.width,
                                      height: (50 /
                                              MediaQuery.of(context)
                                                  .size
                                                  .height) *
                                          MediaQuery.of(context).size.height,
                                      color: Colors.grey,
                                      child: Image.network(
                                        widget.authorImg,
                                        // Use the communityProfilePictureUrl or a default image
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                              color: Colors
                                                  .grey); // Fallback if image fails
                                        },
                                      ),
                                    ),
                                  ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.01,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.anonymous == false) ...[
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              widget.authorName,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (widget.verified == true)
                                            Image.asset(
                                              'images/verified.png',
                                              height: 20,
                                            ),
                                        ],
                                      ),
                                    ] else ...[
                                      Text(
                                        'Anonymous',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                    // SizedBox(
                                    //   height:
                                    //       MediaQuery.of(context).size.height *
                                    //           0.01,
                                    // ),
                                    // Text(
                                    //   widget.time,
                                    //   overflow: TextOverflow.ellipsis,
                                    //   style: TextStyle(
                                    //     color: Colors.grey,
                                    //     fontSize: 16,
                                    //     fontFamily: 'Poppins',
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              if (widget.anonymous == false)
                                if (isMe == false)
                                  InkWell(
                                    onTap: () {
                                      // setState(() {
                                      //   isFollowing = !isFollowing;
                                      // });

                                      if (isFollowing) {
                                        unfollowUser();
                                      } else {
                                        followUser();
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isFollowing
                                            ? const Color(0xFF500450)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isFollowing
                                              ? Colors.transparent
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.2),
                                          width: 2,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      child: isFollowing
                                          ? Text(
                                              "Following",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Poppins',
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                            )
                                          : Text(
                                              "Follow",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Poppins',
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                            ),
                                    ),
                                  )
                            ],
                          ),
                        ),
                      ),
                      if (widget.headerImg.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 30.0, bottom: 10.0, left: 0.0, right: 0.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(0),
                            child: Image.network(
                              widget.headerImg,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      // Text(
                      //   "Ukraine's President Zelensky to BBC: Blood money being paid for Russian oil",
                      //   style: TextStyle(
                      //     fontSize: 20,
                      //     fontFamily: 'Poppins',
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: MediaQuery.of(context).size.height * 0.03,
                      // ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          widget.time,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: _buildLabels(widget.labels),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(bottom: 76.0, left: 20, right: 20),
                        child: Text(
                          widget.description,
                          style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20, // Distance from the bottom of the screen
                  right: 20, // Distance from the right side of the screen
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Like button with count
                      Column(
                        children: [
                          FloatingActionButton(
                            onPressed: () {
                              if (!isLiked) {
                                _toggleLike();
                              }
                            },
                            backgroundColor:
                                isLiked ? Colors.red : Colors.grey.shade300,
                            mini: true,
                            child: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(
                              height: 4), // Space between FAB and number
                          Text(
                            widget.likes, // Replace with dynamic like count
                            style: const TextStyle(
                              fontFamily: 'Inconsolata',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                          height:
                              16), // Space between Like and Comment sections

                      // Comment button with count
                      Column(
                        children: [
                          FloatingActionButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CommentsPage(
                                    key: UniqueKey(),
                                    postId: widget.postId,
                                    userId: widget.userId,
                                    senderId: widget.senderId,
                                  ),
                                ),
                              );
                            },
                            backgroundColor: Colors.grey.shade300,
                            mini: true,
                            child: const Icon(
                              Icons.comment,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(
                              height: 4), // Space between FAB and number
                          Text(
                            widget
                                .comments, // Replace with dynamic comment count
                            style: const TextStyle(
                              fontFamily: 'Inconsolata',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                          height:
                              16), // Space between Comment and Bookmark sections

                      // Bookmark button (no count needed)
                      FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            isBookmarked = !isBookmarked;
                          });
                        },
                        backgroundColor:
                            isBookmarked ? Colors.blue : Colors.grey.shade300,
                        mini: true,
                        child: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLabels(List<String> labels) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Wrap(
        spacing: 8.0, // Space between chips
        runSpacing: 6.0, // Space between rows of chips
        children: labels.map((label) {
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: Colors.grey, // Use your preferred color
              borderRadius:
                  BorderRadius.circular(30), // Rounded pill-like shape
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ], // Shadow for depth
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Inter',
                color: Colors.black,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
