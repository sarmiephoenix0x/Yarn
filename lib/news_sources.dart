import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yarn/main_app.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:async/async.dart';

class NewsSources extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  final String email;
  final String surname;
  final String firstName;
  final String phoneNumber;
  final String dob;
  final String state;
  final String country;
  final String occupation;
  final String? jobTitle;
  final String? company;
  final int? yearJoined;
  final String selectedGender;
  final String profileImage;

  const NewsSources(
      {super.key,
      required this.onToggleDarkMode,
      required this.isDarkMode,
      required this.email,
      required this.surname,
      required this.firstName,
      required this.phoneNumber,
      required this.dob,
      required this.state,
      required this.country,
      required this.occupation,
      this.jobTitle,
      this.company,
      this.yearJoined,
      required this.selectedGender,
      required this.profileImage});

  @override
  NewsSourcesState createState() => NewsSourcesState();
}

class NewsSourcesState extends State<NewsSources>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  final storage = const FlutterSecureStorage();
  late SharedPreferences prefs;
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Map<String, bool> _isFollowingMap = {};
  String userId = '';
  String? userName;
  List<dynamic> communities = [];
  List<dynamic> filteredCommunities = [];
  bool isError = false;
  bool isLoading2 = true;

  @override
  void initState() {
    super.initState();
    _initializePrefs();
    fetchCommunities();
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _registerUser() async {
    if (prefs == null) {
      await _initializePrefs();
    }
    final userDataString = prefs.getString('user');

    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      setState(() {
        userId = userData['userId'].toString();
      });
    }

    final String email = widget.email;
    final String surname = widget.surname;
    final String firstName = widget.firstName;
    final String phoneNumber = widget.phoneNumber;
    final String dob = widget.dob;
    final String state = widget.state;
    final String country = widget.country;
    final String occupation =
        widget.occupation; // Replace with actual occupation input
    final String? jobTitle = widget.jobTitle;
    final String? company = widget.company;
    final int? yearJoined = widget.yearJoined;

    final List<int> pageToFollowIds = [];
    final List<int> communityToJoinIds = [];

    setState(() {
      isLoading = true;
    });

    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final url =
        Uri.parse('https://yarnapi-fuu0.onrender.com/api/auth/sign-up-details');

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..fields['userId'] = userId
      ..fields['firstName'] = firstName
      ..fields['surname'] = surname
      ..fields['email'] = email
      ..fields['phone'] = phoneNumber
      ..fields['gender'] = widget.selectedGender
      ..fields['dateOfBirth'] = dob
      ..fields['state'] = state
      ..fields['country'] = country
      ..fields['occupation'] = occupation;

    if (jobTitle != null && jobTitle.isNotEmpty) {
      request.fields['jobTitle'] = jobTitle;
    }
    if (company != null && company.isNotEmpty) {
      request.fields['company'] = company;
    }
    if (yearJoined != null) {
      request.fields['yearJoined'] = yearJoined.toString();
    }
    if (pageToFollowIds.isNotEmpty) {
      request.fields['PageToFollowIds'] = pageToFollowIds.join(',');
    }
    if (communityToJoinIds.isNotEmpty) {
      request.fields['CommunityToJoinIds'] = communityToJoinIds.join(',');
    }

    // Check if widget.profileImage is a local file (not an HTTP URL) before uploading
    if (widget.profileImage != null &&
        widget.profileImage is File &&
        !widget.profileImage.startsWith('http')) {
      File imageFile = File(widget.profileImage);

      // Ensure the image file exists before adding it to the request
      if (await imageFile.exists()) {
        var stream =
            http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
        var length = await imageFile.length();
        request.files.add(http.MultipartFile(
          'profile_photo',
          stream,
          length,
          filename: path.basename(imageFile.path),
        ));
      } else {
        print('Image file not found. Skipping image upload.');
      }
    } else {
      print(
          'Skipping image upload as the profile image is from an HTTP source.');
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final userDataString = prefs.getString('user');

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        setState(() {
          userName = userData['username'].toString();
        });
      }

      _showCustomSnackBar(
        context,
        'Sign up complete! Welcome, $userName',
        isError: false,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainApp(
              key: UniqueKey(),
              onToggleDarkMode: widget.onToggleDarkMode,
              isDarkMode: widget.isDarkMode),
        ),
      );
    } else if (response.statusCode == 400) {
      setState(() {
        isLoading = false;
      });
      final responseData = jsonDecode(response.body);
      // final String error = responseData['error'];
      // final List<dynamic> data = responseData['data']['email'];
      final String message = responseData['message'];
      print(message);

      _showCustomSnackBar(
        context,
        message,
        isError: true,
      );
    } else {
      setState(() {
        isLoading = false;
      });
      _showCustomSnackBar(
        context,
        'An unexpected error occurred.',
        isError: true,
      );
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

  Future<void> fetchCommunities() async {
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    try {
      final response = await http.get(
        Uri.parse('https://yarnapi-fuu0.onrender.com/api/communities/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          if (data is List && data.isNotEmpty) {
            communities = data; // Assuming data is a list of communities
            filteredCommunities = communities; // Initialize with all communities
          } else {
            // Handle empty list case
            communities = [];
            filteredCommunities = [];
          }
          isError = false; // Reset error state
        });
      } else {
        setState(() {
          isError = true; // Set error state on non-200 response
        });
        // Handle error (e.g., show a snackbar or alert)
        print('Failed to load communities: ${response.body}');
      }
    } catch (e) {
      setState(() {
        isError = true; // Set error state on exception
      });
      print('Error fetching communities: $e');
    } finally {
      setState(() {
        isLoading2 = false; // Stop loading
      });
    }
  }

  void filterCommunities(String query) {
    final filtered = communities.where((community) {
      return community['name'].toLowerCase().contains(query.toLowerCase()) ||
          community['creator'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredCommunities = filtered; // Update filtered list based on search query
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  // Wrap SingleChildScrollView with Expanded
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
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
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const Spacer(),
                            Expanded(
                              flex: 10,
                              child: Text(
                                'Communities To Join',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: TextFormField(
                          controller: searchController,
                          focusNode: _searchFocusNode,
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Search',
                            labelStyle: const TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                              fontSize: 12.0,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                filterCommunities(searchController.text);
                              },
                            ),
                          ),
                          cursorColor: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      isLoading2
                          ? const Center(child: CircularProgressIndicator(color:Color(0xFF500450)))
                          : isError
                          ? const Center(child: Text('Failed to load communities. Please try again later.'))
                          : filteredCommunities.isEmpty
                          ? const Center(child: Text('No communities available.'))
                          : Expanded(
                        child: ListView.builder(
                          itemCount: filteredCommunities.length,
                          itemBuilder: (context, index) {
                            var communityData = filteredCommunities[index];
                            return community(
                              communityData['communityProfilePictureUrl'] ?? 'images/default.png',
                              communityData['name'],
                              communityData['creator'],
                              "${communityData['members'].length} followers", // Adjust as needed
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          width: 0.5, color: Colors.black.withOpacity(0.15))),
                  color: Colors.white,
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    width: double.infinity,
                    height: (60 / MediaQuery.of(context).size.height) *
                        MediaQuery.of(context).size.height,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _registerUser();
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.pressed)) {
                              return Colors.white;
                            }
                            return const Color(0xFF500450);
                          },
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.pressed)) {
                              return const Color(0xFF500450);
                            }
                            return Colors.white;
                          },
                        ),
                        elevation: WidgetStateProperty.all<double>(4.0),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(35)),
                          ),
                        ),
                      ),
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Next',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget community(String img, String name, String username, String followers) {
    final widgetKey = username;
    bool isFollowing = _isFollowingMap[widgetKey] ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: Row(
          children: [
            if (img.isEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(55),
                child: Container(
                  width: (50 / MediaQuery.of(context).size.width) *
                      MediaQuery.of(context).size.width,
                  height: (50 / MediaQuery.of(context).size.height) *
                      MediaQuery.of(context).size.height,
                  color: Colors.grey,
                  child: Image.asset(
                    img,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(55),
                child: Container(
                  width: (50 / MediaQuery.of(context).size.width) *
                      MediaQuery.of(context).size.width,
                  height: (50 / MediaQuery.of(context).size.height) *
                      MediaQuery.of(context).size.height,
                  color: Colors.grey,
                  child: Image.network(
                    img, // Use the communityProfilePictureUrl or a default image
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.grey); // Fallback if image fails
                    },
                  ),
                ),
              ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            Expanded(
              flex: 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Image.asset(
                        'images/verified.png',
                        height: 20,
                      ),
                    ],
                  ),
                  Text(
                    username,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Row(
                    children: [
                      Stack(
                        children: [
                          Positioned(
                            left: 10, // Adjust position for overlap
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(55),
                              child: Container(
                                width:
                                    (20 / MediaQuery.of(context).size.width) *
                                        MediaQuery.of(context).size.width,
                                height:
                                    (20 / MediaQuery.of(context).size.height) *
                                        MediaQuery.of(context).size.height,
                                color: Colors.grey,
                                child: Image.asset(
                                  'images/Follower2.png',
                                ),
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(55),
                            child: Container(
                              width: (20 / MediaQuery.of(context).size.width) *
                                  MediaQuery.of(context).size.width,
                              height:
                                  (20 / MediaQuery.of(context).size.height) *
                                      MediaQuery.of(context).size.height,
                              color: Colors.grey,
                              child: Image.asset(
                                'images/Follower1.png',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                      Text(
                        followers,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                setState(() {
                  _isFollowingMap[widgetKey] = !isFollowing;
                });
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
                    ? Text(
                        "Following",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      )
                    : Text(
                        "Follow",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
