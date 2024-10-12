import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yarn/settings.dart';

import 'comments_page.dart';
import 'create_community.dart';
import 'create_page.dart';
import 'create_post.dart';
import 'details_page.dart';
import 'followers_page.dart';
import 'followings_page.dart';
import 'edit_page.dart';

class AccountPage extends StatefulWidget {
  final int selectedIndex;
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;

  const AccountPage(
      {super.key,
      required this.selectedIndex,
      required this.onToggleDarkMode,
      required this.isDarkMode});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with TickerProviderStateMixin {
  String _profileImage = '';
  TabController? latestTabController;
  TabController? profileTab;
  String? userName;
  String? occupation;
  int followers = 0;
  int following = 0;
  int posts = 0;

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
  int? userId;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    _fetchMyTimelinePosts();
    _fetchMyCommunityPosts();
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

  Future<void> _fetchMyTimelinePosts({int pageNum = 1}) async {
    setState(() {
      isLoadingTimeline = true;
    });

    try {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      final url = Uri.parse(
          'https://yarnapi.onrender.com/api/posts/my-timeline/$pageNum');

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> fetchedPosts = responseBody['data'] ?? [];

        setState(() {
          timelinePosts.addAll(fetchedPosts);
          currentPageTimeline = pageNum;
          hasMoreTimeline = fetchedPosts.length > 0;
          isLoadingTimeline = false;
        });
      } else {
        _showCustomSnackBar(
          context,
          'Failed to load timeline posts.',
          isError: true,
        );
      }
    } catch (e) {
      _showCustomSnackBar(
        context,
        'Failed to load timeline posts.',
        isError: true,
      );
    } finally {
      setState(() {
        isLoadingTimeline = false;
      });
    }
  }

  Future<void> _fetchMyCommunityPosts({int pageNum = 1}) async {
    setState(() {
      isLoadingCommunity = true;
    });

    try {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      final url = Uri.parse(
          'https://yarnapi.onrender.com/api/posts/my-community/$pageNum');

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> fetchedPosts = responseBody['data'] ?? [];

        setState(() {
          communityPosts.addAll(fetchedPosts);
          currentPageCommunity = pageNum;
          hasMoreCommunity = fetchedPosts.length > 0;
          isLoadingCommunity = false;
        });
      } else {
        _showCustomSnackBar(
          context,
          'Failed to load community posts.',
          isError: true,
        );
      }
    } catch (e) {
      _showCustomSnackBar(
        context,
        'Failed to load community posts.',
        isError: true,
      );
    } finally {
      setState(() {
        isLoadingCommunity = false;
      });
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
    final url = 'https://yarnapi.onrender.com/api/users/$userId';
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
          followers = responseData['data']['followersCount'];
          following = responseData['data']['followingsCount'];
          posts = responseData['data']['postsCount'];
          userName = responseData['data']['username'];
          occupation = responseData['data']['occupation'];
          _profileImage = responseData['personalInfo']?['profilePictureUrl'] != null 
    ? responseData['personalInfo']['profilePictureUrl'] + '/download' 
    : '';
          isLoading = false;
        });
        print("Profile Loaded${response.body}");
        _showCustomSnackBar(
          context,
          _profileImage,
          isError: true,
        );
        print(_profileImage);
      } else {
        print('Error fetching profile: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        isLoading = false;
      });
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
              title: Text('Create Post'),
              onTap: () {
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
    final uri =
        Uri.parse('https://yarnapi.onrender.com/api/posts/$postId/comments');
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
          : ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
                                      onToggleDarkMode: widget.onToggleDarkMode,
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
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
                                height:
                                    (80 / MediaQuery.of(context).size.height) *
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
                                height:
                                    (80 / MediaQuery.of(context).size.height) *
                                        MediaQuery.of(context).size.height,
                                color: Colors.grey,
                                child: Image.network(
                                  _profileImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                        color: Colors
                                            .grey); // Fallback if image fails
                                  },
                                ),
                              ),
                            ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.02),
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
                                          )),
                                );
                              },
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    followers.toString(),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  const Text(
                                    "Followers",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16.0,
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
                                  Text(
                                    following.toString(),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  const Text(
                                    "Following",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16.0,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  posts.toString(),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                                const Text(
                                  "Posts",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
                              width: (150 / MediaQuery.of(context).size.width) *
                                  MediaQuery.of(context).size.width,
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
                              width: (150 / MediaQuery.of(context).size.width) *
                                  MediaQuery.of(context).size.width,
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
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
                      indicatorColor: Colors.black,
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
                                          const Icon(Icons.article_outlined,
                                              size: 100, color: Colors.grey),
                                          const SizedBox(height: 20),
                                          const Text(
                                            'No timeline posts available at the moment.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey),
                                          ),
                                          const SizedBox(height: 20),
                                          ElevatedButton(
                                            onPressed: () =>
                                                _fetchMyTimelinePosts(),
                                            // Retry fetching timeline posts
                                            child: const Text('Retry'),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      // Remove NeverScrollableScrollPhysics to enable scrolling
                                      itemCount: timelinePosts.length + 1,
                                      itemBuilder: (context, index) {
                                        if (index == timelinePosts.length) {
                                          return hasMoreTimeline
                                              ? ElevatedButton(
                                                  onPressed: () =>
                                                      _fetchMyTimelinePosts(
                                                          pageNum:
                                                              currentPageTimeline +
                                                                  1),
                                                  child:
                                                      const Text('Load More'),
                                                )
                                              : const Center(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 16),
                                                    child: Text(
                                                        'No more timeline posts'),
                                                  ),
                                                );
                                        }

                                        final post = timelinePosts[index];
                                        return timeline(post);
                                      },
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
                                          const Icon(Icons.group_outlined,
                                              size: 100, color: Colors.grey),
                                          const SizedBox(height: 20),
                                          const Text(
                                            'No community posts available at the moment.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey),
                                          ),
                                          const SizedBox(height: 20),
                                          ElevatedButton(
                                            onPressed: () =>
                                                _fetchMyCommunityPosts(),
                                            // Retry fetching community posts
                                            child: const Text('Retry'),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      // Remove NeverScrollableScrollPhysics to enable scrolling
                                      itemCount: communityPosts.length + 1,
                                      itemBuilder: (context, index) {
                                        if (index == communityPosts.length) {
                                          return hasMoreCommunity
                                              ? ElevatedButton(
                                                  onPressed: () =>
                                                      _fetchMyCommunityPosts(
                                                          pageNum:
                                                              currentPageCommunity +
                                                                  1),
                                                  child:
                                                      const Text('Load More'),
                                                )
                                              : const Center(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 16),
                                                    child: Text(
                                                        'No more community posts'),
                                                  ),
                                                );
                                        }

                                        final post = communityPosts[index];
                                        return communityWidget(post);
                                      },
                                    ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateOptions(context);
        },
        backgroundColor: const Color(0xFF500450),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
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
    String authorImg = post['headerImageUrl'] ?? '';
    String authorName = post['creator'] ?? 'Anonymous';
    bool anonymous = post['isAnonymous'] ?? false;
    bool verified =
        false; // Assuming verification info not provided in post data
    String location =
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
        'https://yarnapi.onrender.com/api/posts/toggle-like/${post['postId']}',
      );

      // Optimistically update the like status and likes count immediately
      setState(() {
        _isLikedMap[post['postId']] = !isLiked; // Toggle like
        likes = _isLikedMap[post['postId']] == true
            ? likes + 1
            : likes - 1; // Update like count
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

        // Revert the optimistic update if the server request fails
        setState(() {
          _isLikedMap[post['postId']] = !isLiked; // Revert like
          likes = _isLikedMap[post['postId']] == true
              ? likes + 1
              : likes - 1; // Revert like count
        });

        // Show error message
        print('Error toggling like: ${errorData['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${errorData['message']}')),
        );
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
              Padding(
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
                          _buildAuthorDetails(authorName, verified, anonymous),
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
                                      postId: post['postId'])),
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
                                      postId: post['postId'])),
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

  Widget timeline(dynamic post) {
    String authorImg = post['headerImageUrl'] ?? '';
    String authorName = post['creator'] ?? 'Anonymous';
    bool anonymous = post['isAnonymous'] ?? false;
    bool verified =
        false; // Assuming verification info not provided in post data
    String location =
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
        'https://yarnapi.onrender.com/api/posts/toggle-like/${post['postId']}',
      );

      // Optimistically update the like status and likes count immediately
      setState(() {
        _isLikedMap[post['postId']] = !isLiked; // Toggle like
        likes = _isLikedMap[post['postId']] == true
            ? likes + 1
            : likes - 1; // Update like count
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

        // Revert the optimistic update if the server request fails
        setState(() {
          _isLikedMap[post['postId']] = !isLiked; // Revert like
          likes = _isLikedMap[post['postId']] == true
              ? likes + 1
              : likes - 1; // Revert like count
        });

        // Show error message
        print('Error toggling like: ${errorData['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${errorData['message']}')),
        );
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
              Padding(
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
                          _buildAuthorDetails(authorName, verified, anonymous),
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
                                      postId: post['postId'])),
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
                                      postId: post['postId'])),
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

  Widget _buildTab(String name) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(name),
      ),
    );
  }
}
