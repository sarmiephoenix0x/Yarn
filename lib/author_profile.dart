import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'details_page.dart';

class AuthorProfilePage extends StatefulWidget {
  final int pageId;
  final int senderId;
  final String profileImage;
  final String pageName;
  final String pageDescription;

  const AuthorProfilePage({
    super.key,
    required this.pageId,
    required this.senderId,
    required this.profileImage,
    required this.pageName,
    required this.pageDescription,
  });

  @override
  State<AuthorProfilePage> createState() => _AuthorProfilePageState();
}

class _AuthorProfilePageState extends State<AuthorProfilePage>
    with TickerProviderStateMixin {
  int _selectedIndex = 1;
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<bool> _hasNotification = [false, false, false, false];
  TabController? latestTabController;
  TabController? profileTab;
  bool isFollowing = false;
  Map<String, bool> _isFollowingMap = {};
  List<dynamic> posts = [];
  bool isLoading = true;
  int currentPage = 0;
  bool hasMore = true;
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    latestTabController = TabController(length: 7, vsync: this);
    profileTab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    latestTabController?.dispose();
    profileTab?.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _fetchPosts({int pageNum = 1}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      if (accessToken == null) {
        print('No access token found');
        _showCustomSnackBar(
          context,
          'Authentication failed. Please log in again.',
          isError: true,
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      final url = Uri.parse(
          'https://yarnapi.onrender.com/api/posts/page/${widget.pageId}/$pageNum');
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
          setState(() {
            hasMore = false;
            isLoading = false;
          });
          return;
        }

        setState(() {
          posts.addAll(fetchedPosts);
          currentPage = pageNum;
          hasMore = fetchedPosts.length > 0;
          isLoading = false;
        });
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
      setState(() {
        isLoading = false;
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

  Future<void> followUser() async {
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final url =
        'https://yarnapi.onrender.com/api/pages/${widget.pageId}/follow';
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
        'https://yarnapi.onrender.com/api/pages/${widget.pageId}/unfollow';
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
      body: ListView(
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
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Image.asset(
                        'images/BackButton.png',
                        height: 25,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.more_vert),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    if (widget.profileImage.isEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(55),
                        child: Container(
                          width: (80 / MediaQuery.of(context).size.width) *
                              MediaQuery.of(context).size.width,
                          height: (80 / MediaQuery.of(context).size.height) *
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
                          width: (80 / MediaQuery.of(context).size.width) *
                              MediaQuery.of(context).size.width,
                          height: (80 / MediaQuery.of(context).size.height) *
                              MediaQuery.of(context).size.height,
                          color: Colors.grey,
                          child: Image.file(
                            File(widget.profileImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    const Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "0",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          Text(
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
                    const Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "0",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          Text(
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
                    const Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "0",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          Text(
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
                child: Text(
                  widget.pageName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  widget.pageDescription,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  maxLines: 3,
                  style: const TextStyle(
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
                        if (isFollowing) {
                          unfollowUser();
                        } else {
                          followUser();
                        }
                      },
                      child: Container(
                        width: (150 / MediaQuery.of(context).size.width) *
                            MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: isFollowing
                              ? const Color(0xFF500450)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isFollowing
                                ? Colors.transparent
                                : const Color(0xFF500450).withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: isFollowing
                            ? Text(
                                "Following",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              )
                            : const Text(
                                "+ Follow",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  color: Color(0xFF500450),
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
                          "Website",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              SizedBox(
                height: (400 / MediaQuery.of(context).size.height) *
                    MediaQuery.of(context).size.height,
                child: isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF500450)))
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
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
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
                                        onPressed: () => _fetchPosts(
                                            pageNum: currentPage + 1),
                                        child: const Text('Load More'),
                                      )
                                    : const Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 16),
                                          child: Text('No more posts'),
                                        ),
                                      );
                              }

                              final post = posts[index];
                              return _buildPostItem(post);
                            },
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget timeline(String img, String continent, String description,
      String authorImg, String authorName, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Row(
        children: [
          if (widget.profileImage.isEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                width: (110 / MediaQuery.of(context).size.width) *
                    MediaQuery.of(context).size.width,
                height: (130 / MediaQuery.of(context).size.height) *
                    MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Image.asset(
                  img,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                width: (50 / MediaQuery.of(context).size.width) *
                    MediaQuery.of(context).size.width,
                height: (50 / MediaQuery.of(context).size.height) *
                    MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Image.file(
                  File(widget.profileImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      continent,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.0,
                        color: Colors.grey,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Text(
                  description,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  maxLines: 3,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Row(
                  children: [
                    Row(
                      children: [
                        if (widget.profileImage.isEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(55),
                            child: Container(
                              width: (25 / MediaQuery.of(context).size.width) *
                                  MediaQuery.of(context).size.width,
                              height:
                                  (25 / MediaQuery.of(context).size.height) *
                                      MediaQuery.of(context).size.height,
                              color: Colors.grey,
                              child: Image.asset(
                                authorImg,
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
                              height:
                                  (25 / MediaQuery.of(context).size.height) *
                                      MediaQuery.of(context).size.height,
                              color: Colors.grey,
                              child: Image.file(
                                File(widget.profileImage),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.01),
                        Text(
                          authorName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                            color: Color(0xFF4E4B66),
                          ),
                        ),
                      ],
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
                            fontSize: 13.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(dynamic post) {
    // Extract necessary data from the post
    String authorImg = post['headerImageUrl'] != null 
  ? "${post['headerImageUrl']}/download" 
  : '';
    String authorName = post['creator'] ?? 'Anonymous';
    bool anonymous = post['isAnonymous'] ?? false;
    bool verified =
        false; // Assuming verification info not provided in post data
    String location =
        'Some location'; // Replace with actual location if available
    String description = post['content'] ?? 'No description';
    List<String> postImg = List<String>.from(post['ImagesUrl'] ?? []);
    String time = post['datePosted'] ?? 'Unknown time';
    bool isLiked = false; // Assume you have a way to track likes
    bool isFollowing = false; // Same assumption for following
    int likes = post['likesCount'];
    int comments = post['commentsCount'];
    int creatorUserId = post['creatorId'];
    int _current = 0;

    Color originalIconColor = IconTheme.of(context).color ?? Colors.black;

    Future<void> _toggleLike() async {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      final uri = Uri.parse(
          'https://yarnapi.onrender.com/api/posts/toggle-like/${post['postId']}');

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
        print(isLiked);
      } else {
        final errorData = json.decode(response.body);
        // Handle error - you might want to show a dialog or a Snackbar
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
                senderId: widget.senderId,
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
                          onPressed: () {},
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
                          onPressed: () {},
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
              decoration: InputDecoration(
                hintText: 'Add comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
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
