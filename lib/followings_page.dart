import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:yarn/user_profile.dart';

class FollowingsPage extends StatefulWidget {
  final int senderId;

  const FollowingsPage({super.key, required this.senderId});

  @override
  _FollowingsPageState createState() => _FollowingsPageState();
}

class _FollowingsPageState extends State<FollowingsPage> {
  final storage = const FlutterSecureStorage();
  List<dynamic> followingsList = [];
  bool isLoading = true;
  Map<String, bool> isFollowingMap = {};
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchFollowings();
  }

  Future<void> _fetchFollowings() async {
    setState(() {
      isLoading = true;
    });
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final url =
        'https://yarnapi-fuu0.onrender.com/api/users/followings/${widget.senderId}';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'Success' &&
            responseData['data'] is List) {
          setState(() {
            followingsList =
                responseData['data']; // Update to use responseData['data']
            isLoading = false;
          });
        } else {
          // Handle unexpected response structure
          setState(() {
            errorMessage = 'Unexpected response format';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching followings: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF500450)))
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : followingsList.isEmpty
                  ? Center(
                      // Display this if the timeline posts list is empty
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people,
                              size: 100, color: Colors.grey),
                          const SizedBox(height: 20),
                          const Text(
                            'No followings found.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => _fetchFollowings(),
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
                      itemCount: followingsList.length,
                      itemBuilder: (context, index) {
                        final following = followingsList[index];
                        return user(
                          following['profilepictureurl'] != null
                              ? following['profilepictureurl'] +
                                  '/download?project=66e4476900275deffed4'
                              : '',
                          following['username'],
                          following['isFollowing'],
                          following['userId'],
                        );
                      },
                    ),
    );
  }

  Widget user(String img, String name, bool isFollowing, int userId) {
    isFollowing = isFollowingMap[userId.toString()] ?? false;
    Future<void> followUser() async {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      final url = 'https://yarnapi-fuu0.onrender.com/api/pages/$userId/follow';
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
            isFollowingMap[userId.toString()] = true;
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
          'https://yarnapi-fuu0.onrender.com/api/pages/$userId/unfollow';
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
            isFollowingMap[userId.toString()] = false;
          });
        } else {
          print('Error: ${response.statusCode}');
        }
      } catch (error) {
        print('Unfollow error: $error');
      }
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfile(
              key: UniqueKey(),
              userId: userId,
              senderId: widget.senderId,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(55),
                child: Container(
                  width: (50 / MediaQuery.of(context).size.width) *
                      MediaQuery.of(context).size.width,
                  height: (50 / MediaQuery.of(context).size.height) *
                      MediaQuery.of(context).size.height,
                  color: Colors.grey,
                  child: img.isNotEmpty
                      ? Image.network(
                          img,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'images/ProfileImg.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              Expanded(
                flex: 10,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    // Text(
                    //   followers,
                    //   overflow: TextOverflow.ellipsis,
                    //   style: const TextStyle(
                    //     fontFamily: 'Poppins',
                    //   ),
                    // ),
                  ],
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: isFollowing
                      ? const Text(
                          "Following",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "+ Follow",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            color: Color(0xFF500450),
                          ),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
