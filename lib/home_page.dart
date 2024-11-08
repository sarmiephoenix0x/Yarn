import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yarn/chat_page.dart';
import 'package:yarn/main.dart';
import 'package:yarn/user_profile.dart';
import 'package:yarn/video_player.dart';
import 'comments_page.dart';
import 'details_page.dart';
import 'messages_page.dart';
import 'notification_page.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:signalr_core/signalr_core.dart';
import 'create_community.dart';
import 'create_page.dart';
import 'create_post.dart';

class HomePage extends StatefulWidget {
  final int selectedIndex;
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;

  const HomePage(
      {super.key,
      required this.selectedIndex,
      required this.onToggleDarkMode,
      required this.isDarkMode});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, RouteAware {
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _profileImage = '';
  TabController? latestTabController;
  TabController? profileTab;
  bool isLiked = false;
  final CarouselController _controller = CarouselController();
  Map<String, bool> _isFollowingMap = {};
  List<dynamic> posts = [];
  bool isLoading = true;
  int currentPage = 0;
  bool hasMore = true;
  final storage = const FlutterSecureStorage();
  Map<int, bool> _isLikedMap =
      {}; // Map to store the like status of each post by postId
  Map<int, int> _likesMap =
      {}; // Map to store the number of likes for each post by postId
  Map<int, int> _commentsMap =
      {}; // Map to store the number of comments for each post by postId
  int? userId;
  String? _detectedCountry;
  String? _detectedState;
  String? _detectedCity;
  Position? _position;
  HubConnection? _hubConnection;
  bool _hasFetchedData = false;
  final ScrollController _timelineScrollController = ScrollController();
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _timelineScrollController.addListener(() {
      if (_timelineScrollController.position.pixels >=
              _timelineScrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          hasMore) {
        _fetchPosts(loadMore: true); // Load the next page when near the end
      }
    });
    _startSignalRConnection();
    if (!_hasFetchedData) {
      fetchUserProfilePic();
      _fetchPosts();
      _hasFetchedData = true;
    }
    latestTabController = TabController(length: 7, vsync: this);
    profileTab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    latestTabController?.dispose();
    profileTab?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute? modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      if (!_hasFetchedData) {
        _fetchPosts();
        fetchUserProfilePic();
        _hasFetchedData = true;
      }
      routeObserver.subscribe(this, modalRoute);
    }
  }

  void _startSignalRConnection() async {
    _hubConnection = HubConnectionBuilder()
        .withUrl("https://yarnapi-n2dw.onrender.com/postHub")
        .build();

    _hubConnection?.onclose((error) {
      print("Connection closed: $error");
    });

    _hubConnection?.on("PostLiked", (message) {
      print("Yarn Liked Signal");
      int postId = message![0];
      setState(() {
        _isLikedMap[postId] = true;
        _likesMap[postId] = (_likesMap[postId] ?? 0) + 1;
      });
    });

    _hubConnection?.on("PostUnliked", (message) {
      print("Yarn UnLiked Signal");
      int postId = message![0];
      setState(() {
        _isLikedMap[postId] = false;
        _likesMap[postId] = (_likesMap[postId] ?? 0) - 1;
      });
    });

    _hubConnection?.on("PostCommented", (message) {
      int postId = message![0];
      setState(() {
        _commentsMap[postId] = (_commentsMap[postId] ?? 0) + 1;
      });
    });

    await _hubConnection?.start();
    print("SignalR connection started");
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    _position = await Geolocator.getCurrentPosition();
    await _getAddressFromLatLng(_position!); // Fetch address
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
    userId = await getUserIdFromPrefs();
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final url = 'https://yarnapi-n2dw.onrender.com/api/users/$userId';
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

        setState(() {
          final profilePictureUrl = responseData['data']['personalInfo']
                  ?['profilePictureUrl']
              ?.toString()
              .trim();

          _profileImage =
              (profilePictureUrl != null && profilePictureUrl.isNotEmpty)
                  ? '$profilePictureUrl/download?project=66e4476900275deffed4'
                  : '';
        });

        print("Profile Pic Loaded${response.body}");
        print(_profileImage);
      } else {
        print('Error fetching profile Pic: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error: $error');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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

  Future<void> _fetchPosts({bool loadMore = false, int pageNum = 1}) async {
    if (loadMore && isLoadingMore) return;
    if (mounted) {
      if (loadMore) {
        setState(() {
          isLoadingMore = true;
        });
      } else {
        setState(() {
          isLoading = true;
        });
      }
    }

    await _getLocation();

    try {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      if (accessToken == null) {
        print('No access token found');
        _showCustomSnackBar(
          context,
          'Authentication failed. Please log in again.',
          isError: true,
        );
        if (mounted) {
          setState(() {
            isLoading = false;
            isLoadingMore = false;
          });
        }
        return;
      }

      // Reset posts and pagination when starting a new load
      if (pageNum == 1) {
        setState(() {
          posts.clear(); // Clear existing posts for fresh data
          hasMore = true; // Reset 'hasMore' for pagination
          currentPage = 1; // Reset to page 1
        });
      }

      final url = Uri.parse(
          'https://yarnapi-n2dw.onrender.com/api/posts/home/$_detectedCity/$pageNum');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $accessToken',
      });

      // Print response for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        // Assuming posts are inside a 'data' field
        final List<dynamic> fetchedPosts = responseBody['data'] ?? [];

        if (fetchedPosts.isEmpty) {
          print('No yarns available');
          _showCustomSnackBar(
            context,
            'No yarns to display at the moment.',
            isError: false,
          );
          if (mounted) {
            setState(() {
              hasMore = false; // No more posts available
              isLoading = false; // Hide loading indicator
              isLoadingMore = false;
            });
          }
          return;
        }

        if (mounted) {
          setState(() {
            if (loadMore) {
              posts.addAll(fetchedPosts); // Append new data
            } else {
              posts = fetchedPosts; // Set initial load
            } // Add fetched posts to the list
            currentPage = pageNum; // Update the current page
            hasMore =
                fetchedPosts.length > 0; // Check if more posts are available
            isLoading = false; // Hide loading indicator
            isLoadingMore = false;
          });
        }
      } else if (response.statusCode == 400) {
        print('Error 400: ${response.body}');
        _showCustomSnackBar(
          context,
          'Failed to load yarns. Bad request.',
          isError: true,
        );
      } else {
        print('Unexpected error: ${response.body}');
        _showCustomSnackBar(
          context,
          'An unexpected error occurred.',
          isError: true,
        );
      }
    } catch (e) {
      print('Exception: $e');
      if (mounted) {
        _showCustomSnackBar(
          context,
          'Failed to load yarns.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Ensure loading indicator is hidden
          isLoadingMore = false;
        });
      }
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

  Future<void> _submitComment(
      int postId, TextEditingController commentController) async {
    final String comment = commentController.text.trim();
    if (comment.isEmpty) {
      _showCustomSnackBar(
        context,
        'Please enter a comment.',
        isError: true,
      );
      return;
    }

    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final uri = Uri.parse(
        'https://yarnapi-n2dw.onrender.com/api/posts/$postId/comments');
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
        _showCustomSnackBar(
          context,
          'Error adding comment. Invalid response from server.',
          isError: true,
        );
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        _showCustomSnackBar(
          context,
          'Error adding comment: ${errorData['message'] ?? 'Unknown error'}',
          isError: true,
        );
      } catch (e) {
        // If the response is not valid JSON, show the raw response text
        print('Error response: ${response.body}');
        _showCustomSnackBar(
          context,
          'Error adding comment. Server returned an unexpected response.',
          isError: true,
        );
      }
    }
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.post_add),
              title: Text('Create Yarn'),
              onTap: () {
                _hasFetchedData = false;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatePost(key: UniqueKey()),
                  ),
                );
                // Navigator.pop(context); // Close the bottom sheet
              },
            ),
            ListTile(
              leading: Icon(Icons.pageview),
              title: Text('Create Page'),
              onTap: () {
                _hasFetchedData = false;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatePage(key: UniqueKey()),
                  ),
                );
                // Navigator.pop(context); // Close the bottom sheet
              },
            ),
            ListTile(
              leading: Icon(Icons.group_add),
              title: Text('Create Community'),
              onTap: () {
                _hasFetchedData = false;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateCommunity(key: UniqueKey()),
                  ),
                );
                // Navigator.pop(context); // Close the bottom sheet
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateOptions(context),
        backgroundColor: const Color(0xFF500450),
        shape: const CircleBorder(),
        child: Image.asset(
          'images/User-talk.png',
          height: 30,
          fit: BoxFit.cover,
        ),
      ),
      body: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Color(0xFF500450).withOpacity(0.8),
            elevation: 2,
            titleSpacing: 20,
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/AppLogo.png',
                    height: 45,
                  ),
                  const Spacer(),
                  _buildIconButton('images/NotificationIcon.png', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationPage(
                          key: UniqueKey(),
                          selectedIndex: widget.selectedIndex,
                        ),
                      ),
                    );
                  }),
                  _buildIconButton('images/ChatImg.png', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MeassagesPage(
                          key: UniqueKey(),
                          senderId: userId!,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchPosts,
              child: isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF500450)),
                    )
                  : posts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.article_outlined,
                                  size: 100, color: Colors.grey.shade600),
                              const SizedBox(height: 20),
                              Text(
                                'No yarns available at the moment.',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => _fetchPosts(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF500450),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Retry',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _timelineScrollController,
                          itemCount: posts.length + 1,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (index == posts.length) {
                              return hasMore
                                  ? const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                            color: Color(0xFF500450)),
                                      ),
                                    )
                                  : const Center(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 16),
                                        child: Text('No more yarns'),
                                      ),
                                    );
                            }

                            final post = posts[index];
                            return _buildPostItem(post);
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(dynamic post) {
    // Extract necessary data from the post
    String headerImg = post['headerImageUrl'] != null
        ? "${post['headerImageUrl']}/download?project=66e4476900275deffed4"
        : '';
    String authorImg = post['creatorProfilePictureUrl'] != null
        ? "${post['creatorProfilePictureUrl']}/download?project=66e4476900275deffed4"
        : '';
    String authorName = post['creator'] ?? 'Anonymous';
    bool anonymous = post['isAnonymous'] ?? false;
    bool verified =
        false; // Assuming verification info not provided in post data
    String location = post['creatorCity'] ??
        'Some location'; // Replace with actual location if available
    String description = post['content'] ?? 'No description';
    List<String> postMedia = [
      // Process image URLs, filtering out any null or empty values
      ...List<String>.from(post['imagesUrl'] ?? [])
          .where((url) =>
              url?.trim().isNotEmpty ??
              false) // Trim and check for non-empty URLs
          .map((url) => "$url/download?project=66e4476900275deffed4")
          .toList(),

      // Process video URLs, filtering out any null or empty values
      ...List<String>.from(post['videosUrl'] ?? [])
          .where((url) =>
              url?.trim().isNotEmpty ??
              false) // Trim and check for non-empty URLs
          .map((url) => "$url/download?project=66e4476900275deffed4")
          .toList(),
    ];

    print(postMedia);

    List<String> labels = [];

    if (post['labels'] is List && post['labels'].isNotEmpty) {
      // Decode the first item in the list, which should be a string with the actual label list encoded
      String labelsString = post['labels'][0];

      // Decode the string (i.e., "[\"Test\",\"Trump\"]") into a List
      labels = List<String>.from(jsonDecode(labelsString));
    }

    String time = post['datePosted'] ?? 'Unknown time';
    bool isLiked = _isLikedMap[post['postId']] ?? false;
    bool isFollowing = false; // Same assumption for following
    int likes = post['likesCount'];
    int comments = post['commentsCount'];
    int creatorUserId = post['creatorId'];
    ValueNotifier<int> _current = ValueNotifier<int>(0);

    Color originalIconColor = IconTheme.of(context).color ?? Colors.black;

    Future<void> _toggleLike() async {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      final uri = Uri.parse(
          'https://yarnapi-n2dw.onrender.com/api/posts/toggle-like/${post['postId']}');

      // Optimistically update the like status and likes count immediately
      setState(() {
        _isLikedMap[post['postId']] = !(_isLikedMap[post['postId']] ?? false);

        likes = _isLikedMap[post['postId']] == true ? likes + 1 : likes - 1;
      });

      final response = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        setState(() {
          // Revert optimistic update
          _isLikedMap[post['postId']] = !(_isLikedMap[post['postId']] ?? false);

          likes = _isLikedMap[post['postId']] == true ? likes + 1 : likes - 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${errorData['message']}')));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsPage(
                key: UniqueKey(),
                postId: post['postId'],
                postImg: postMedia,
                authorImg: authorImg,
                headerImg: headerImg,
                description: description,
                authorName: authorName,
                verified: verified,
                anonymous: anonymous,
                time: time,
                isFollowing: isFollowing,
                likes: likes.toString(),
                comments: comments.toString(),
                isLiked: isLiked,
                userId: creatorUserId,
                senderId: userId!,
              ),
            ),
          );
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  if (anonymous == false) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfile(
                          key: UniqueKey(),
                          userId: creatorUserId,
                          senderId: userId!,
                        ),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      if (!anonymous)
                        if (authorImg.isEmpty)
                          _buildProfilePlaceholder()
                        else
                          _buildProfileImage(authorImg),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                      Expanded(
                        flex: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAuthorDetails(
                                authorName, verified, anonymous),
                            if (postMedia.isEmpty)
                              _buildLocationAndTime(location, time),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // if (!anonymous) _buildFollowButton(isFollowing, authorName),
                    ],
                  ),
                ),
              ),
              if (postMedia.isNotEmpty) _buildPostImages(postMedia, _current),
              if (labels.isNotEmpty) _buildLabels(labels),
              // _buildInteractionRow(isLiked, postImg),
              if (postMedia.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked == true
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isLiked == true ? Colors.red : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              // Toggle the like status for this post
                              _toggleLike();
                            });
                          },
                        ),
                        Text(
                          likes.toString(),
                          style: TextStyle(
                            fontFamily: 'Inconsolata',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CommentsPage(
                                        key: UniqueKey(),
                                        postId: post['postId'],
                                        userId: creatorUserId,
                                        senderId: userId!,
                                      )),
                            );
                          },
                        ),
                        Text(
                          comments.toString(),
                          style: TextStyle(
                            fontFamily: 'Inconsolata',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ValueListenableBuilder<int>(
                      valueListenable: _current,
                      builder: (context, index, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            postMedia.length,
                            (index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Image.asset(
                                _current.value == index
                                    ? "images/ActiveElipses.png"
                                    : "images/InactiveElipses.png",
                                width:
                                    (10 / MediaQuery.of(context).size.width) *
                                        MediaQuery.of(context).size.width,
                                height:
                                    (10 / MediaQuery.of(context).size.height) *
                                        MediaQuery.of(context).size.height,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {},
                    ),
                  ]),
                ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              if (postMedia.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Text(
                        location,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Color(0xFF4E4B66),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Image.asset(
                            "images/TimeStampImg.png",
                            height: 20,
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.03),
                          Text(
                            time,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  description,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  maxLines: 3,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18.0,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              // if (postImg.isEmpty) _buildInteractionRow(isLiked, postImg),
              if (postMedia.isEmpty) ...[
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                              isLiked == true
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isLiked == true
                                  ? Colors.red
                                  : originalIconColor),
                          onPressed: () {
                            _toggleLike();
                          },
                        ),
                        Text(
                          likes.toString(),
                          style: TextStyle(
                            fontFamily: 'Inconsolata',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CommentsPage(
                                        key: UniqueKey(),
                                        postId: post['postId'],
                                        userId: creatorUserId,
                                        senderId: userId!,
                                      )),
                            );
                          },
                        ),
                        Text(
                          comments.toString(),
                          style: TextStyle(
                            fontFamily: 'Inconsolata',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ValueListenableBuilder<int>(
                      valueListenable: _current,
                      builder: (context, index, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            postMedia.length,
                            (index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Image.asset(
                                _current.value == index
                                    ? "images/ActiveElipses.png"
                                    : "images/InactiveElipses.png",
                                width:
                                    (10 / MediaQuery.of(context).size.width) *
                                        MediaQuery.of(context).size.width,
                                height:
                                    (10 / MediaQuery.of(context).size.height) *
                                        MediaQuery.of(context).size.height,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {},
                    ),
                  ]),
                ),
              ],
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              _buildCommentInput(_profileImage, post['postId']),
              Divider(color: Theme.of(context).colorScheme.onSurface),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePlaceholder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(55),
      child: Container(
        width: 50,
        height: 50,
        color: Colors.grey,
        child: Image.asset(
          'images/ProfileImg.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProfileImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(55),
      child: Container(
        width: 50,
        height: 50,
        color: Colors.grey,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(color: Colors.grey); // Fallback if image fails
          },
        ),
      ),
    );
  }

  Widget _buildAuthorDetails(String authorName, bool verified, bool anonymous) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!anonymous) ...[
          Row(
            children: [
              Flexible(
                child: Text(
                  authorName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              //if (verified) Image.asset('images/verified.png', height: 20),
            ],
          ),
          Flexible(
            child: Text(
              '@$authorName',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey,
              ),
            ),
          ),
        ] else
          const Text(
            'Anonymous',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildLocationAndTime(String location, String time) {
    return Row(
      children: [
        Expanded(
          child: Text(
            location,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 10),
        Row(
          children: [
            Image.asset("images/TimeStampImg.png", height: 20),
            SizedBox(width: 5),
            Text(
              time,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFollowButton(bool isFollowing, String authorName) {
    return InkWell(
      onTap: () {
        setState(() {
          _isFollowingMap[authorName] = !isFollowing;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isFollowing ? const Color(0xFF500450) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isFollowing
                ? Colors.transparent
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          isFollowing ? "Following" : "Follow",
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildPostImages(
      List<String> mediaUrls, ValueNotifier<int> currentIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: CarouselSlider(
        options: CarouselOptions(
          autoPlay: false,
          enlargeCenterPage: false,
          aspectRatio: 14 / 9,
          viewportFraction: 1.0,
          enableInfiniteScroll: true,
          onPageChanged: (index, reason) {
            setState(() {
              currentIndex.value = index; // Update the current index
            });
          },
        ),
        items: mediaUrls.map((url) {
          if (url.endsWith('.mp4')) {
            // If the URL is a video
            return AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoPlayerWidget(url: url),
            );
          } else {
            // If the URL is an image
            return Image.network(
              url,
              fit: BoxFit.cover,
              width: double.infinity,
            );
          }
        }).toList(),
      ),
    );
  }

  Widget _buildInteractionRow(bool isLiked, List<String> postImg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.grey),
            onPressed: () {
              setState(() {
                isLiked = !isLiked;
              });
            },
          ),
          const Spacer(),
          IconButton(icon: const Icon(Icons.comment), onPressed: () {}),
          const Spacer(),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildCommentInput(String imageUrl, int postId) {
    final TextEditingController commentController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          if (imageUrl.isEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(55),
              child: Container(
                width: (30 / MediaQuery.of(context).size.width) *
                    MediaQuery.of(context).size.width,
                height: (30 / MediaQuery.of(context).size.height) *
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
                width: (25 / MediaQuery.of(context).size.width) *
                    MediaQuery.of(context).size.width,
                height: (25 / MediaQuery.of(context).size.height) *
                    MediaQuery.of(context).size.height,
                color: Colors.grey,
                child: Image.network(
                  imageUrl,
                  // Use the communityProfilePictureUrl or a default image
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                        color: Colors.grey); // Fallback if image fails
                  },
                ),
              ),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: commentController,
              style: TextStyle(
                fontSize: 16.0,
                color: Theme.of(context).colorScheme.onSurface,
                decoration: TextDecoration.none,
              ),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                filled: false,
                fillColor: Colors.grey[200],
              ),
              minLines: 1,
              maxLines: null,
              cursorColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF500450)),
            onPressed: () {
              _submitComment(postId, commentController);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLabels(List<String> labels) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Wrap(
        spacing: 8.0, // Space between chips
        runSpacing: 6.0, // Space between rows of chips
        children: labels.map((label) {
          return Chip(
            label: Text(label, style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blueAccent,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIconButton(String assetPath, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1), // Soft background
          ),
          child: Image.asset(
            assetPath,
            height: 35, // Icon size
          ),
        ),
      ),
    );
  }
}
