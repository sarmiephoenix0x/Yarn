import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class UserProfile extends StatefulWidget {
  final int userId;
  const UserProfile({
    super.key,
    required this.userId
  });

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with TickerProviderStateMixin {
  String _profileImage = '';
  final TextEditingController searchController = TextEditingController();
  TabController? latestTabController;
  TabController? profileTab;
  bool isFollowing = false;
  bool isLoading = true;
  int currentPage = 0;
  bool hasMore = true;
  final storage = const FlutterSecureStorage();
  String? userName;
  int followers = 0;
  int following = 0;
  int posts = 0;

  Future<void> fetchUserProfile() async {
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final url = 'https://yarnapi.onrender.com/api/users/${widget.userId}';
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
          _profileImage =
              responseData['personalInfo']?['profilePictureUrl'] ?? '';
          isLoading = false;
        });
        print("Profile Loaded${response.body}");
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
        'https://yarnapi.onrender.com/api/users/follow/${widget.userId}';
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
        'https://yarnapi.onrender.com/api/users/unfollow/${widget.userId}';
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
                          child: Image.file(
                            File(_profileImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                child: Text(
                  userName ?? 'Unknown User',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
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
            ],
          ),
        ],
      ),
    );
  }
}
