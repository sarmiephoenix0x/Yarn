import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yarn/analytics.dart';
import 'package:yarn/settings.dart';
import 'package:yarn/video_player.dart';
import 'comments_page.dart';
import 'create_community.dart';
import 'create_page.dart';
import 'create_post.dart';
import 'details_page.dart';
import 'followers_page.dart';
import 'followings_page.dart';
import 'edit_page.dart';
import 'package:yarn/user_profile.dart';
import 'locations_followed.dart';
import 'package:signalr_core/signalr_core.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class AccountPage extends StatefulWidget {
  final int selectedIndex;
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  final HubConnection? hubConnection;

  const AccountPage(
      {super.key,
      required this.selectedIndex,
      required this.onToggleDarkMode,
      required this.isDarkMode,
      this.hubConnection});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with TickerProviderStateMixin, RouteAware {
  String _profileImage = '';
  TabController? latestTabController;
  TabController? profileTab;
  String? userName;
  String? occupation;
  int followers = 0;
  int following = 0;
  int posts = 0;
  int locations = 0;

  // Variables for managing timeline posts
  List<dynamic> timelinePosts = [];
  bool isLoadingTimeline = false;
  bool hasMoreTimeline = true;
  int currentPageTimeline = 1;

  // Variables for managing community posts
  List<dynamic> communityPosts = [];
  bool isLoadingCommunity = false;
  bool hasMoreCommunity = true;
  int currentPageCommunity = 1;

  // Error tracking variable
  bool isError = false;
  final storage = const FlutterSecureStorage();

  final CarouselController _controller = CarouselController();
  Map<String, bool> _isFollowingMap = {};

  bool isLoading = true;
  Map<int, bool> _isLikedMap = {};
  Map<int, int> _likesMap = {};
  Map<int, int> _commentsMap = {};
  int? userId;
  bool _hasFetchedData = false;
  bool isLoadingMoreTimeline = false;
  bool isLoadingMoreCommunity = false;
  final ScrollController _timelineScrollController = ScrollController();
  final ScrollController _communityScrollController = ScrollController();
  Map<int, ValueNotifier<bool>> _isLikedNotifiers = {};
  Map<int, ValueNotifier<int>> likesNotifier = {};

  @override
  void initState() {
    super.initState();
    _startSignalRConnection();
    _timelineScrollController.addListener(() {
      if (_timelineScrollController.position.pixels >=
              _timelineScrollController.position.maxScrollExtent - 200 &&
          !isLoadingTimeline &&
          hasMoreTimeline) {
        _fetchMyTimelinePosts(
            loadMore: true); // Load the next page when near the end
      }
    });

    _communityScrollController.addListener(() {
      if (_communityScrollController.position.pixels >=
              _communityScrollController.position.maxScrollExtent - 200 &&
          !isLoadingCommunity &&
          hasMoreCommunity) {
        _fetchMyCommunityPosts(
            loadMore: true); // Load the next page when near the end
      }
    });
    if (!_hasFetchedData) {
      fetchUserProfile();
      _fetchMyTimelinePosts();
      _fetchMyCommunityPosts();
      _hasFetchedData = true;
    }
    // _fetchUserData();
    latestTabController = TabController(length: 7, vsync: this);
    profileTab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    latestTabController?.dispose();
    profileTab?.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute? modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      if (!_hasFetchedData) {
        fetchUserProfile();
        _fetchMyTimelinePosts();
        _fetchMyCommunityPosts();
        _hasFetchedData = true;
      }
      routeObserver.subscribe(this, modalRoute);
    }
  }

  void _startSignalRConnection() async {
    widget.hubConnection?.on("PostLiked", (message) {
      print("Yarn Liked Signal");
      int postId = message![0];
      int likeCounts = message[1]; // Assuming likeCounts is the second item
      setState(() {
        // Update the local maps and notifiers
        _isLikedMap[postId] = true;
        _likesMap[postId] = likeCounts; // Update likes count directly

        // Ensure likesNotifier is initialized for the postId
        if (!likesNotifier.containsKey(postId)) {
          likesNotifier[postId] = ValueNotifier<int>(likeCounts);
        } else {
          likesNotifier[postId]!.value =
              likeCounts; // Update likes count in notifier
        }

        _isLikedNotifiers[postId]?.value = true; // Update liked state
      });
      print(likeCounts);
    });

    widget.hubConnection?.on("PostUnliked", (message) {
      print("Yarn UnLiked Signal");
      int postId = message![0];
      int likeCounts = message[1]; // Assuming likeCounts is the second item
      setState(() {
        // Update the local maps and notifiers
        _isLikedMap[postId] = false;
        _likesMap[postId] = likeCounts; // Update likes count directly

        // Ensure likesNotifier is initialized for the postId
        if (!likesNotifier.containsKey(postId)) {
          likesNotifier[postId] = ValueNotifier<int>(likeCounts);
        } else {
          likesNotifier[postId]!.value =
              likeCounts; // Update likes count in notifier
        }

        _isLikedNotifiers[postId]?.value = false; // Update liked state
      });
      print(likeCounts);
    });

    widget.hubConnection?.on("PostCommented", (message) {
      print("Yarn Commented Signal");
      int postId = message![0];
      int commentCounts =
          message[1]; // Assuming commentCounts is the second item
      setState(() {
        _commentsMap[postId] = commentCounts; // Update comments count directly
      });
      print(commentCounts);
    });
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user');

    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      setState(() {
        userName = userData['username'].toString(); // Cast to string if needed
      });
    }
  }

  Future<void> _fetchMyTimelinePosts(
      {bool loadMore = false, int pageNum = 1}) async {
    if (loadMore && (isLoadingMoreTimeline || !hasMoreTimeline)) return;

    if (mounted) {
      setState(() {
        if (loadMore) {
          isLoadingMoreTimeline = true;
        } else {
          isLoadingTimeline = true;
        }
      });
    }

    try {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      final url = Uri.parse(
          'https://yarnapi-n2dw.onrender.com/api/posts/my-timeline/$pageNum');

      if (pageNum == 1 && !loadMore) {
        setState(() {
          timelinePosts.clear();
          hasMoreTimeline = true;
        });
      }

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> fetchedPosts = responseBody['data'] ?? [];

        if (fetchedPosts.isEmpty && pageNum == 1) {
          _showCustomSnackBar(
            context,
            'No timeline yarns available at the moment.',
            isError: false,
          );
        }

        setState(() {
          if (loadMore) {
            final newPosts = fetchedPosts.where((post) {
              return !timelinePosts.any(
                  (existingPost) => existingPost['postId'] == post['postId']);
            }).toList();

            if (newPosts.isEmpty) {
              hasMoreTimeline = false;
              _showCustomSnackBar(context, 'No more timeline yarns to load.',
                  isError: false);
            } else {
              timelinePosts.addAll(newPosts);
              hasMoreTimeline = true;
            }
          } else {
            timelinePosts = fetchedPosts;
            hasMoreTimeline = fetchedPosts.isNotEmpty;
          }
          currentPageTimeline = pageNum;
        });
      } else {
        _showCustomSnackBar(context, 'Failed to load timeline yarns.',
            isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showCustomSnackBar(context, 'Failed to load timeline yarns.',
            isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingTimeline = false;
          isLoadingMoreTimeline = false;
        });
      }
    }
  }

  Future<void> _fetchMyCommunityPosts(
      {bool loadMore = false, int pageNum = 1}) async {
    if (loadMore && (isLoadingMoreCommunity || !hasMoreCommunity)) return;

    if (mounted) {
      setState(() {
        if (loadMore) {
          isLoadingMoreCommunity = true;
        } else {
          isLoadingCommunity = true;
        }
      });
    }

    try {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      final url = Uri.parse(
          'https://yarnapi-n2dw.onrender.com/api/posts/my-community/$pageNum');

      if (pageNum == 1 && !loadMore) {
        setState(() {
          communityPosts.clear();
          hasMoreCommunity = true;
        });
      }

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> fetchedPosts = responseBody['data'] ?? [];

        if (fetchedPosts.isEmpty && pageNum == 1) {
          _showCustomSnackBar(
            context,
            'No community yarns available at the moment.',
            isError: false,
          );
        }

        setState(() {
          if (loadMore) {
            final newPosts = fetchedPosts.where((post) {
              return !communityPosts.any(
                  (existingPost) => existingPost['postId'] == post['postId']);
            }).toList();

            if (newPosts.isEmpty) {
              hasMoreCommunity = false;
              _showCustomSnackBar(context, 'No more community yarns to load.',
                  isError: false);
            } else {
              communityPosts.addAll(newPosts);
              hasMoreCommunity = true;
            }
          } else {
            communityPosts = fetchedPosts;
            hasMoreCommunity = fetchedPosts.isNotEmpty;
          }
          currentPageCommunity = pageNum;
        });
      } else {
        _showCustomSnackBar(context, 'Failed to load community yarns.',
            isError: true);
      }
    } catch (e) {
      _showCustomSnackBar(context, 'Failed to load community yarns.',
          isError: true);
    } finally {
      if (mounted) {
        setState(() {
          isLoadingCommunity = false;
          isLoadingMoreCommunity = false;
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

  Future<void> fetchUserProfile() async {
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
        if (mounted) {
          setState(() {
            followers = responseData['data']['followersCount'];
            following = responseData['data']['followingsCount'];
            posts = responseData['data']['postsCount'];
            locations = responseData['data']['followedLocationCount'];
            userName = responseData['data']['username'];
            occupation = responseData['data']['occupation'];
            final profilePictureUrl = responseData['data']['personalInfo']
                    ?['profilePictureUrl']
                ?.toString()
                .trim();

            _profileImage =
                (profilePictureUrl != null && profilePictureUrl.isNotEmpty)
                    ? '$profilePictureUrl/download?project=66e4476900275deffed4'
                    : '';
            isLoading = false;
          });
        }
        print("Profile Loaded${response.body}");
        print(_profileImage);
      } else {
        print('Error fetching profile: ${response.statusCode}');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
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
    return Scaffold(
      // Add Scaffold to each page
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF500450)),
            )
          : RefreshIndicator(
              onRefresh: fetchUserProfile,
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(),
                            Text(
                              'Profile',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Settings(
                                        key: UniqueKey(),
                                        onToggleDarkMode:
                                            widget.onToggleDarkMode,
                                        isDarkMode: widget.isDarkMode),
                                  ),
                                );
                              },
                              child: Image.asset(
                                'images/Settings.png',
                                height: 30,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            if (_profileImage.isEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(55),
                                child: Container(
                                  width:
                                      (80 / MediaQuery.of(context).size.width) *
                                          MediaQuery.of(context).size.width,
                                  height: (80 /
                                          MediaQuery.of(context).size.height) *
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
                                  width:
                                      (80 / MediaQuery.of(context).size.width) *
                                          MediaQuery.of(context).size.width,
                                  height: (80 /
                                          MediaQuery.of(context).size.height) *
                                      MediaQuery.of(context).size.height,
                                  color: Colors.grey,
                                  child: Image.network(
                                    _profileImage,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey,
                                      ); // Fallback if image fails
                                    },
                                  ),
                                ),
                              ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.02),
                            Expanded(
                              flex: 5,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FollowersPage(
                                        key: UniqueKey(),
                                        senderId: userId!,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person, size: 20),
                                    SizedBox(
                                        height: (4 /
                                                MediaQuery.of(context)
                                                    .size
                                                    .height) *
                                            MediaQuery.of(context).size.height),
                                    Text(
                                      followers.toString(),
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    const Text(
                                      "Foll.",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 10.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FollowingsPage(
                                        key: UniqueKey(),
                                        senderId: userId!,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_outline, size: 20),
                                    SizedBox(
                                        height: (4 /
                                                MediaQuery.of(context)
                                                    .size
                                                    .height) *
                                            MediaQuery.of(context).size.height),
                                    Text(
                                      following.toString(),
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    const Text(
                                      "Foll'ing",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 10.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.article, size: 20),
                                  SizedBox(
                                      height: (4 /
                                              MediaQuery.of(context)
                                                  .size
                                                  .height) *
                                          MediaQuery.of(context).size.height),
                                  Text(
                                    posts.toString(),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  const Text(
                                    "Yarns",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          LocationsFollowedPage(
                                        key: UniqueKey(),
                                        senderId: userId!,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.location_on, size: 20),
                                    SizedBox(
                                        height: (4 /
                                                MediaQuery.of(context)
                                                    .size
                                                    .height) *
                                            MediaQuery.of(context).size.height),
                                    Text(
                                      locations
                                          .toString(), // This would be your number of locations
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    const Text(
                                      "Locations", // The label for locations
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 10.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: //userName != null
                            //?
                            Text(
                          userName ?? 'Unknown User',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        // : const Center(
                        //     // Center the loader if desired
                        //     child: CircularProgressIndicator(
                        //       color: Colors.white,
                        //     ),
                        //   ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          occupation ?? "No Bio",
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 3,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfilePage(
                                      key: UniqueKey(),
                                      profileImgUrl: _profileImage,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: Text(
                                  "Edit profile",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: Text(
                                  "Share profile",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Analytics(
                                      key: UniqueKey(),
                                      senderId: userId!,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: Image.asset(
                                  'images/StatImg.png',
                                  height: 25,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      TabBar(
                        controller: profileTab,
                        tabs: [
                          _buildTab('My Timeline'),
                          _buildTab('My Communities'),
                        ],
                        labelColor: Theme.of(context).colorScheme.onSurface,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inconsolata',
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inconsolata',
                        ),
                        labelPadding: EdgeInsets.zero,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorColor: Theme.of(context).colorScheme.onSurface,
                      ),
                      SizedBox(
                        height: (400 / MediaQuery.of(context).size.height) *
                            MediaQuery.of(context).size.height,
                        child: TabBarView(
                          controller: profileTab,
                          children: [
                            // Timeline Tab
                            isLoadingTimeline
                                ? const Center(
                                    child: CircularProgressIndicator(
                                        color: Color(0xFF500450)))
                                : timelinePosts.isEmpty
                                    ? Center(
                                        // Display this if the timeline posts list is empty
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.article_outlined,
                                                size: 100,
                                                color: Colors.grey.shade600),
                                            const SizedBox(height: 20),
                                            Text(
                                              'No timeline yarns available at the moment.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.grey.shade600),
                                            ),
                                            const SizedBox(height: 20),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _fetchMyTimelinePosts(),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Color(0xFF500450),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: const Text(
                                                'Retry',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : RefreshIndicator(
                                        onRefresh: _fetchMyTimelinePosts,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          controller:
                                              _timelineScrollController, // Add controller for scroll detection
                                          itemCount: timelinePosts.length + 1,
                                          itemBuilder: (context, index) {
                                            if (index == timelinePosts.length) {
                                              return hasMoreTimeline
                                                  ? const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 16),
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                                color: Color(
                                                                    0xFF500450)),
                                                      ),
                                                    )
                                                  : const Center(
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 16),
                                                        child: Text(
                                                            'No more timeline yarns'),
                                                      ),
                                                    );
                                            }

                                            final post = timelinePosts[index];
                                            return timeline(post);
                                          },
                                        ),
                                      ),

                            // Community Tab
                            isLoadingCommunity
                                ? const Center(
                                    child: CircularProgressIndicator(
                                        color: Color(0xFF500450)))
                                : communityPosts.isEmpty
                                    ? Center(
                                        // Display this if the community posts list is empty
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.group_outlined,
                                                size: 100,
                                                color: Colors.grey.shade600),
                                            const SizedBox(height: 20),
                                            Text(
                                              'No community yarns available at the moment.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.grey.shade600),
                                            ),
                                            const SizedBox(height: 20),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _fetchMyCommunityPosts(),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Color(0xFF500450),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: const Text(
                                                'Retry',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : RefreshIndicator(
                                        onRefresh: _fetchMyCommunityPosts,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          controller:
                                              _communityScrollController, // Add controller for scroll detection
                                          itemCount: communityPosts.length + 1,
                                          itemBuilder: (context, index) {
                                            if (index ==
                                                communityPosts.length) {
                                              return hasMoreCommunity
                                                  ? const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 16),
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                                color: Color(
                                                                    0xFF500450)),
                                                      ),
                                                    )
                                                  : const Center(
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 16),
                                                        child: Text(
                                                            'No more community yarns'),
                                                      ),
                                                    );
                                            }

                                            final post = communityPosts[index];
                                            return communityWidget(post);
                                          },
                                        ),
                                      ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateOptions(context);
        },
        backgroundColor: const Color(0xFF500450),
        shape: const CircleBorder(),
        child: Image.asset(
          'images/User-talk.png',
          height: 30,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Widget communityWidget(String img, String name, String description,
  //     String authorImg, String authorName, String time) {
  //   // This is your original community widget code.
  //   // Update it as necessary.
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
  //     child: Row(
  //       children: [
  //         if (img.isEmpty)
  //           ClipRRect(
  //             borderRadius: BorderRadius.circular(5),
  //             child: Container(
  //               width: (110 / MediaQuery.of(context).size.width) *
  //                   MediaQuery.of(context).size.width,
  //               height: (130 / MediaQuery.of(context).size.height) *
  //                   MediaQuery.of(context).size.height,
  //               decoration: BoxDecoration(
  //                 color: Colors.grey,
  //                 borderRadius: BorderRadius.circular(5),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.grey.withOpacity(0.5),
  //                     spreadRadius: 3,
  //                     blurRadius: 5,
  //                   ),
  //                 ],
  //               ),
  //               child: Image.asset(
  //                 img,
  //                 fit: BoxFit.cover,
  //               ),
  //             ),
  //           )
  //         else
  //           ClipRRect(
  //             borderRadius: BorderRadius.circular(5),
  //             child: Container(
  //               width: (110 / MediaQuery.of(context).size.width) *
  //                   MediaQuery.of(context).size.width,
  //               height: (130 / MediaQuery.of(context).size.height) *
  //                   MediaQuery.of(context).size.height,
  //               decoration: BoxDecoration(
  //                 color: Colors.grey,
  //                 borderRadius: BorderRadius.circular(5),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.grey.withOpacity(0.5),
  //                     spreadRadius: 3,
  //                     blurRadius: 5,
  //                   ),
  //                 ],
  //               ),
  //               child: Image.network(
  //                 img, // Use the communityProfilePictureUrl or a default image
  //                 fit: BoxFit.cover,
  //                 errorBuilder: (context, error, stackTrace) {
  //                   return Container(
  //                       color: Colors.grey); // Fallback if image fails
  //                 },
  //               ),
  //             ),
  //           ),
  //         SizedBox(width: MediaQuery.of(context).size.width * 0.02),
  //         Expanded(
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Text(
  //                 name,
  //                 overflow: TextOverflow.ellipsis,
  //                 style: const TextStyle(
  //                   fontFamily: 'Poppins',
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 16.0,
  //                   color: Colors.black,
  //                 ),
  //               ),
  //               SizedBox(height: MediaQuery.of(context).size.height * 0.01),
  //               Text(
  //                 description,
  //                 overflow: TextOverflow.ellipsis,
  //                 softWrap: true,
  //                 maxLines: 3,
  //                 style: TextStyle(
  //                   fontFamily: 'Poppins',
  //                   fontSize: 14.0,
  //                   color: Theme.of(context).colorScheme.onSurface,
  //                 ),
  //               ),
  //               SizedBox(height: MediaQuery.of(context).size.height * 0.01),
  //               Row(
  //                 children: [
  //                   ClipRRect(
  //                     borderRadius: BorderRadius.circular(25),
  //                     child: Container(
  //                       width: 25,
  //                       height: 25,
  //                       child: Image.network(
  //                         authorImg,
  //                         fit: BoxFit.cover,
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(width: MediaQuery.of(context).size.width * 0.01),
  //                   Text(
  //                     authorName,
  //                     overflow: TextOverflow.ellipsis,
  //                     style: const TextStyle(
  //                       fontFamily: 'Poppins',
  //                       fontSize: 14.0,
  //                       color: Color(0xFF4E4B66),
  //                     ),
  //                   ),
  //                   Spacer(),
  //                   Text(
  //                     time,
  //                     overflow: TextOverflow.ellipsis,
  //                     style: const TextStyle(
  //                       fontFamily: 'Poppins',
  //                       fontSize: 13.0,
  //                       color: Colors.grey,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget timeline(String img, String continent, String description,
  //     String authorImg, String authorName, String time) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
  //     child: Row(
  //       children: [
  //         if (_profileImage.isEmpty)
  //           ClipRRect(
  //             borderRadius: BorderRadius.circular(5),
  //             child: Container(
  //               width: (110 / MediaQuery.of(context).size.width) *
  //                   MediaQuery.of(context).size.width,
  //               height: (130 / MediaQuery.of(context).size.height) *
  //                   MediaQuery.of(context).size.height,
  //               decoration: BoxDecoration(
  //                 color: Colors.grey,
  //                 borderRadius: BorderRadius.circular(5),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.grey.withOpacity(0.5),
  //                     spreadRadius: 3,
  //                     blurRadius: 5,
  //                   ),
  //                 ],
  //               ),
  //               child: Image.asset(
  //                 img,
  //                 fit: BoxFit.cover,
  //               ),
  //             ),
  //           )
  //         else
  //           ClipRRect(
  //             borderRadius: BorderRadius.circular(5),
  //             child: Container(
  //               width: (50 / MediaQuery.of(context).size.width) *
  //                   MediaQuery.of(context).size.width,
  //               height: (50 / MediaQuery.of(context).size.height) *
  //                   MediaQuery.of(context).size.height,
  //               decoration: BoxDecoration(
  //                 color: Colors.grey,
  //                 borderRadius: BorderRadius.circular(5),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.grey.withOpacity(0.5),
  //                     spreadRadius: 3,
  //                     blurRadius: 5,
  //                   ),
  //                 ],
  //               ),
  //               child: Image.file(
  //                 File(_profileImage),
  //                 fit: BoxFit.cover,
  //               ),
  //             ),
  //           ),
  //         SizedBox(width: MediaQuery.of(context).size.width * 0.02),
  //         Expanded(
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Row(
  //                 children: [
  //                   Text(
  //                     continent,
  //                     overflow: TextOverflow.ellipsis,
  //                     style: const TextStyle(
  //                       fontFamily: 'Poppins',
  //                       fontSize: 13.0,
  //                       color: Colors.grey,
  //                     ),
  //                   ),
  //                   const Spacer(),
  //                 ],
  //               ),
  //               SizedBox(height: MediaQuery.of(context).size.height * 0.02),
  //               Text(
  //                 description,
  //                 overflow: TextOverflow.ellipsis,
  //                 softWrap: true,
  //                 maxLines: 3,
  //                 style: TextStyle(
  //                   fontFamily: 'Poppins',
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 16.0,
  //                   color: Theme.of(context).colorScheme.onSurface,
  //                 ),
  //               ),
  //               SizedBox(height: MediaQuery.of(context).size.height * 0.01),
  //               Row(
  //                 children: [
  //                   Row(
  //                     children: [
  //                       if (_profileImage.isEmpty)
  //                         ClipRRect(
  //                           borderRadius: BorderRadius.circular(55),
  //                           child: Container(
  //                             width: (25 / MediaQuery.of(context).size.width) *
  //                                 MediaQuery.of(context).size.width,
  //                             height:
  //                                 (25 / MediaQuery.of(context).size.height) *
  //                                     MediaQuery.of(context).size.height,
  //                             color: Colors.grey,
  //                             child: Image.asset(
  //                               authorImg,
  //                               fit: BoxFit.cover,
  //                             ),
  //                           ),
  //                         )
  //                       else
  //                         ClipRRect(
  //                           borderRadius: BorderRadius.circular(55),
  //                           child: Container(
  //                             width: (25 / MediaQuery.of(context).size.width) *
  //                                 MediaQuery.of(context).size.width,
  //                             height:
  //                                 (25 / MediaQuery.of(context).size.height) *
  //                                     MediaQuery.of(context).size.height,
  //                             color: Colors.grey,
  //                             child: Image.file(
  //                               File(_profileImage),
  //                               fit: BoxFit.cover,
  //                             ),
  //                           ),
  //                         ),
  //                       SizedBox(
  //                           width: MediaQuery.of(context).size.width * 0.01),
  //                       Text(
  //                         authorName,
  //                         overflow: TextOverflow.ellipsis,
  //                         style: const TextStyle(
  //                           fontFamily: 'Poppins',
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: 14.0,
  //                           color: Color(0xFF4E4B66),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   const Spacer(),
  //                   Row(
  //                     children: [
  //                       Image.asset(
  //                         "images/TimeStampImg.png",
  //                         height: 20,
  //                       ),
  //                       SizedBox(
  //                           width: MediaQuery.of(context).size.width * 0.03),
  //                       Text(
  //                         time,
  //                         overflow: TextOverflow.ellipsis,
  //                         style: const TextStyle(
  //                           fontFamily: 'Poppins',
  //                           fontSize: 13.0,
  //                           color: Colors.grey,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget communityWidget(dynamic post) {
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
    String location = post['location'] ?? post['creatorCity'];
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
    bool isLiked =
        post['isLiked'] ?? false; // Use the API response for initial state
    if (!_isLikedNotifiers.containsKey(post['postId'])) {
      _isLikedNotifiers[post['postId']] =
          ValueNotifier<bool>(post['isLiked'] ?? false);
    }
    bool isFollowing = false;
    if (!likesNotifier.containsKey(post['postId'])) {
      likesNotifier[post['postId']] =
          ValueNotifier<int>(post['likesCount'] ?? 0);
    }
    ValueNotifier<int> commentsNotifier = ValueNotifier<int>(
        _commentsMap[post['postId']] ?? post['commentsCount'] ?? 0);
    int creatorUserId = post['creatorId'];
    ValueNotifier<int> _current = ValueNotifier<int>(0);

    Color originalIconColor = IconTheme.of(context).color ?? Colors.black;

    Future<void> _toggleLike() async {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      final uri = Uri.parse(
          'https://yarnapi-n2dw.onrender.com/api/posts/toggle-like/${post['postId']}');

      bool currentLikedState = _isLikedNotifiers[post['postId']]!.value;

      setState(() {
        _isLikedNotifiers[post['postId']]!.value = !currentLikedState;

        if (_isLikedNotifiers[post['postId']]!.value) {
          likesNotifier[post['postId']]!.value++;
        } else {
          likesNotifier[post['postId']]!.value =
              (likesNotifier[post['postId']]!.value > 0)
                  ? likesNotifier[post['postId']]!.value - 1
                  : 0;
        }
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
          // Revert optimistic update if the API call fails
          _isLikedNotifiers[post['postId']]!.value =
              currentLikedState; // revert to old state

          // Update the likes count based on the reverted state
          likesNotifier[post['postId']]!.value = currentLikedState
              ? likesNotifier[post['postId']]!.value - 1
              : likesNotifier[post['postId']]!.value + 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${errorData['message']}')));
      }
      print("Test: ${likesNotifier[post['postId']]!.value}");
      print("IDs: $userId $creatorUserId");
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
                likes: likesNotifier[post['postId']]!.value.toString(),
                comments: commentsNotifier.value.toString(),
                isLiked: isLiked,
                userId: creatorUserId,
                senderId: userId!,
                labels: labels,
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
                        ValueListenableBuilder<bool>(
                          valueListenable: _isLikedNotifiers[post['postId']]!,
                          builder: (context, isLiked, child) {
                            return IconButton(
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.grey,
                              ),
                              onPressed: _toggleLike,
                            );
                          },
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: likesNotifier[post['postId']]!,
                          builder: (context, likes, child) {
                            print("Likes updated: $likes");
                            return Text(
                              likes.toString(),
                              style: TextStyle(
                                fontFamily: 'Inconsolata',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            );
                          },
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
                        ValueListenableBuilder<int>(
                          valueListenable: commentsNotifier,
                          builder: (context, comments, child) {
                            return Text(
                              comments.toString(),
                              style: TextStyle(
                                fontFamily: 'Inconsolata',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            );
                          },
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
                        ValueListenableBuilder<bool>(
                          valueListenable: _isLikedNotifiers[post['postId']]!,
                          builder: (context, isLiked, child) {
                            return IconButton(
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.grey,
                              ),
                              onPressed: _toggleLike,
                            );
                          },
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: likesNotifier[post['postId']]!,
                          builder: (context, likes, child) {
                            print("Likes updated: $likes");
                            return Text(
                              likes.toString(),
                              style: TextStyle(
                                fontFamily: 'Inconsolata',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            );
                          },
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
                        ValueListenableBuilder<int>(
                          valueListenable: commentsNotifier,
                          builder: (context, comments, child) {
                            return Text(
                              comments.toString(),
                              style: TextStyle(
                                fontFamily: 'Inconsolata',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            );
                          },
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

  Widget timeline(dynamic post) {
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
    String location = post['location'] ?? post['creatorCity'];
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
    bool isLiked =
        post['isLiked'] ?? false; // Use the API response for initial state
    if (!_isLikedNotifiers.containsKey(post['postId'])) {
      _isLikedNotifiers[post['postId']] =
          ValueNotifier<bool>(post['isLiked'] ?? false);
    }
    bool isFollowing = false;
    if (!likesNotifier.containsKey(post['postId'])) {
      likesNotifier[post['postId']] =
          ValueNotifier<int>(post['likesCount'] ?? 0);
    }
    ValueNotifier<int> commentsNotifier = ValueNotifier<int>(
        _commentsMap[post['postId']] ?? post['commentsCount'] ?? 0);
    int creatorUserId = post['creatorId'];
    ValueNotifier<int> _current = ValueNotifier<int>(0);

    Color originalIconColor = IconTheme.of(context).color ?? Colors.black;

    Future<void> _toggleLike() async {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      final uri = Uri.parse(
          'https://yarnapi-n2dw.onrender.com/api/posts/toggle-like/${post['postId']}');

      bool currentLikedState = _isLikedNotifiers[post['postId']]!.value;

      setState(() {
        _isLikedNotifiers[post['postId']]!.value = !currentLikedState;

        if (_isLikedNotifiers[post['postId']]!.value) {
          likesNotifier[post['postId']]!.value++;
        } else {
          likesNotifier[post['postId']]!.value =
              (likesNotifier[post['postId']]!.value > 0)
                  ? likesNotifier[post['postId']]!.value - 1
                  : 0;
        }
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
          // Revert optimistic update if the API call fails
          _isLikedNotifiers[post['postId']]!.value =
              currentLikedState; // revert to old state

          // Update the likes count based on the reverted state
          likesNotifier[post['postId']]!.value = currentLikedState
              ? likesNotifier[post['postId']]!.value - 1
              : likesNotifier[post['postId']]!.value + 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${errorData['message']}')));
      }
      print("Test: ${likesNotifier[post['postId']]!.value}");
    }

    print("IDs: $userId $creatorUserId");

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
                likes: likesNotifier[post['postId']]!.value.toString(),
                comments: commentsNotifier.value.toString(),
                isLiked: isLiked,
                userId: creatorUserId,
                senderId: userId!,
                labels: labels,
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
                        ValueListenableBuilder<bool>(
                          valueListenable: _isLikedNotifiers[post['postId']]!,
                          builder: (context, isLiked, child) {
                            return IconButton(
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.grey,
                              ),
                              onPressed: _toggleLike,
                            );
                          },
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: likesNotifier[post['postId']]!,
                          builder: (context, likes, child) {
                            print("Likes updated: $likes");
                            return Text(
                              likes.toString(),
                              style: TextStyle(
                                fontFamily: 'Inconsolata',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            );
                          },
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
                        ValueListenableBuilder<int>(
                          valueListenable: commentsNotifier,
                          builder: (context, comments, child) {
                            return Text(
                              comments.toString(),
                              style: TextStyle(
                                fontFamily: 'Inconsolata',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            );
                          },
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
                        ValueListenableBuilder<bool>(
                          valueListenable: _isLikedNotifiers[post['postId']]!,
                          builder: (context, isLiked, child) {
                            return IconButton(
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.grey,
                              ),
                              onPressed: _toggleLike,
                            );
                          },
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: likesNotifier[post['postId']]!,
                          builder: (context, likes, child) {
                            print("Likes updated: $likes");
                            return Text(
                              likes.toString(),
                              style: TextStyle(
                                fontFamily: 'Inconsolata',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            );
                          },
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
                        ValueListenableBuilder<int>(
                          valueListenable: commentsNotifier,
                          builder: (context, comments, child) {
                            return Text(
                              comments.toString(),
                              style: TextStyle(
                                fontFamily: 'Inconsolata',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            );
                          },
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
      children: [
        if (!anonymous) ...[
          Row(
            children: [
              Text(
                authorName,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              //if (verified) Image.asset('images/verified.png', height: 20),
            ],
          ),
          Text(
            '@$authorName',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.grey,
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
        Text(
          location,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
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
            // Update the current index directly without setState
            currentIndex.value = index;
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
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.grey);
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

  Widget _buildTab(String name) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(name),
      ),
    );
  }
}
