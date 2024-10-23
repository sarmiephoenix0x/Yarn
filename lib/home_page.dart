import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yarn/chat_page.dart';
import 'package:yarn/user_profile.dart';
import 'comments_page.dart';
import 'details_page.dart';
import 'messages_page.dart';
import 'notification_page.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:signalr_core/signalr_core.dart';

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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
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

  @override
  void initState() {
    super.initState();
    _startSignalRConnection();
    fetchUserProfilePic();
    latestTabController = TabController(length: 7, vsync: this);
    profileTab = TabController(length: 2, vsync: this);
    _fetchPosts();
  }

  @override
  void dispose() {
    super.dispose();
    latestTabController?.dispose();
    profileTab?.dispose();
  }

  void _startSignalRConnection() async {
    _hubConnection = HubConnectionBuilder()
        .withUrl("https://yarnapi-n2dw.onrender.com/postHub")
        .build();

    _hubConnection?.onclose((error) {
      print("Connection closed: $error");
    });

    _hubConnection?.on("PostLiked", (message) {
      print("Post Liked Signal");
      int postId = message![0];
      setState(() {
        _isLikedMap[postId] = true;
        _likesMap[postId] = (_likesMap[postId] ?? 0) + 1;
      });
    });

    _hubConnection?.on("PostUnliked", (message) {
      print("Post UnLiked Signal");
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

  Future<void> _fetchPosts({int pageNum = 1}) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
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
          });
        }
        return;
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
          print('No posts available');
          _showCustomSnackBar(
            context,
            'No posts to display at the moment.',
            isError: false,
          );
          if (mounted) {
            setState(() {
              hasMore = false;
              isLoading = false;
            });
          }
          return;
        }
        if (mounted) {
          setState(() {
            posts.addAll(fetchedPosts);
            currentPage = pageNum;
            hasMore = fetchedPosts.length > 0;
            isLoading = false;
          });
        }
      } else if (response.statusCode == 400) {
        print('Error 400: ${response.body}');
        _showCustomSnackBar(
          context,
          'Failed to load posts. Bad request.',
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
      _showCustomSnackBar(
        context,
        'Failed to load posts.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'images/AppLogo.png',
                    height: 50,
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationPage(
                            key: UniqueKey(),
                            selectedIndex: widget.selectedIndex,
                          ),
                        ),
                      );
                    },
                    child: Image.asset(
                      'images/NotificationIcon.png',
                      height: 50,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // int someReceiverId = 1;
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => ChatPage(
                      //         receiverId: someReceiverId,
                      //         senderId: userId!,
                      //         receiverName: "Philip",
                      //         profilePic: _profileImage), // Pass the receiverId
                      //   ),
                      // );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MeassagesPage(
                            key: UniqueKey(),
                            senderId: userId!,
                          ),
                        ),
                      );
                    },
                    child: Image.asset(
                      'images/ChatImg.png',
                      height: 50,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF500450)))
                : posts.isEmpty
                    ? Center(
                        // Display this if the posts list is empty
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.article_outlined,
                                size: 100, color: Colors.grey),
                            const SizedBox(height: 20),
                            const Text(
                              'No posts available at the moment.',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () =>
                                  _fetchPosts(), // Allow user to retry
                              child: const Text(
                                'Retry',
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: posts.length + 1,
                        itemBuilder: (context, index) {
                          if (index == posts.length) {
                            // Check if more posts are available
                            return hasMore
                                ? ElevatedButton(
                                    onPressed: () =>
                                        _fetchPosts(pageNum: currentPage + 1),
                                    child: const Text('Load More'),
                                  )
                                : const Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      child: Text('No more posts'),
                                    ),
                                  );
                          }

                          final post = posts[index];
                          return _buildPostItem(post);
                        },
                      ),

            // post(
            //     _profileImage,
            //     _profileImage,
            //     "Lagos State | Agege LGA",
            //     "Ukrainian President Volodymyr Zelensky has accused European countries that continue to buy Russian oil of earning their money in other people's blood.\nIn an interview with the BBC, President Zelensky singled out Germany and Hungary, accusing them of blocking efforts to embargo energy sales, from which Russia stands to make up to £250bn (\$326bn) this year.\nThere has been a growing frustration among Ukraine's leadership with Berlin, which has backed some sanctions against Russia but so far resisted calls to back tougher action on oil sales.",
            //     [
            //       "images/TrendingImg.png",
            //       "images/TrendingImg.png",
            //       "images/TrendingImg.png",
            //     ],
            //     "Author",
            //     "@username",
            //     "4h ago",
            //     true,
            //     false),
            // post(
            //     _profileImage,
            //     _profileImage,
            //     "Lagos State | Agege LGA",
            //     "Ukrainian President Volodymyr Zelensky has accused European countries that continue to buy Russian oil of earning their money in other people's blood.\nIn an interview with the BBC, President Zelensky singled out Germany and Hungary, accusing them of blocking efforts to embargo energy sales, from which Russia stands to make up to £250bn (\$326bn) this year.\nThere has been a growing frustration among Ukraine's leadership with Berlin, which has backed some sanctions against Russia but so far resisted calls to back tougher action on oil sales.",
            //     [],
            //     "Author2",
            //     "@username",
            //     "4h ago",
            //     false,
            //     false),
            // post(
            //     _profileImage,
            //     _profileImage,
            //     "Lagos State | Agege LGA",
            //     "Ukrainian President Volodymyr Zelensky has accused European countries that continue to buy Russian oil of earning their money in other people's blood.\nIn an interview with the BBC, President Zelensky singled out Germany and Hungary, accusing them of blocking efforts to embargo energy sales, from which Russia stands to make up to £250bn (\$326bn) this year.\nThere has been a growing frustration among Ukraine's leadership with Berlin, which has backed some sanctions against Russia but so far resisted calls to back tougher action on oil sales.",
            //     [],
            //     "Author2",
            //     "@username",
            //     "4h ago",
            //     false,
            //     true),
          ],
        ),
      ],
    );
  }

  Widget _buildPostItem(dynamic post) {
    // Extract necessary data from the post
    String authorImg = post['headerImageUrl'] != null
        ? "${post['headerImageUrl']}/download?project=66e4476900275deffed4"
        : '';
    String authorName = post['creator'] ?? 'Anonymous';
    bool anonymous = post['isAnonymous'] ?? false;
    bool verified =
        false; // Assuming verification info not provided in post data
    String location = post['creatorCity'] ??
        'Some location'; // Replace with actual location if available
    String description = post['content'] ?? 'No description';
    List<String> postImg = List<String>.from(post['ImagesUrl'] ?? []);
    String time = post['datePosted'] ?? 'Unknown time';
    bool isLiked = _isLikedMap[post['postId']] ?? false;
    bool isFollowing = false; // Same assumption for following
    int likes = post['likesCount'];
    int comments = post['commentsCount'];
    int creatorUserId = post['creatorId'];
    int _current = 0;

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
                postImg: postImg,
                authorImg: authorImg,
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
                            if (postImg.isEmpty)
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
              if (postImg.isNotEmpty) _buildPostImages(postImg),
              // _buildInteractionRow(isLiked, postImg),
              if (postImg.isNotEmpty)
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        postImg.length,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Image.asset(
                            _current == index
                                ? "images/ActiveElipses.png"
                                : "images/InactiveElipses.png",
                            width: (10 / MediaQuery.of(context).size.width) *
                                MediaQuery.of(context).size.width,
                            height: (10 / MediaQuery.of(context).size.height) *
                                MediaQuery.of(context).size.height,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {},
                    ),
                  ]),
                ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              if (postImg.isNotEmpty)
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
              if (postImg.isEmpty) ...[
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        postImg.length,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Image.asset(
                            _current == index
                                ? "images/ActiveElipses.png"
                                : "images/InactiveElipses.png",
                            width: (10 / MediaQuery.of(context).size.width) *
                                MediaQuery.of(context).size.width,
                            height: (10 / MediaQuery.of(context).size.height) *
                                MediaQuery.of(context).size.height,
                          ),
                        ),
                      ),
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
              _buildCommentInput(authorImg, post['postId']),
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

  Widget _buildPostImages(List<String> postImg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: CarouselSlider(
        options: CarouselOptions(
          autoPlay: false,
          enlargeCenterPage: false,
          aspectRatio: 14 / 9,
          viewportFraction: 1.0,
          enableInfiniteScroll: true,
        ),
        items: postImg.map((item) {
          return Image.network(
            item,
            fit: BoxFit.cover,
            width: double.infinity,
          );
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
}
