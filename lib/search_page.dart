import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'author_profile.dart';

class SearchPage extends StatefulWidget {
  final int selectedIndex;

  const SearchPage({
    super.key,
    required this.selectedIndex,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _profileImage = '';
  TabController? explorerTabController;
  Map<String, bool> _isSaveMap = {};
  Map<String, bool> isFollowingMap = {};
  bool _isLoading = true; // Loading state
  List<dynamic> _pages = [];
  String _errorMessage = '';
  final storage = const FlutterSecureStorage();
  int? userId;
  List<dynamic> locationsList = [];
  List<Map<String, dynamic>> filteredLocationsList = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchLocations();
    _fetchPages();
    explorerTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    explorerTabController?.dispose();
  }

  Future<void> _fetchLocations() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http
          .get(Uri.parse('https://yarnapi-fuu0.onrender.com/api/locations'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          locationsList = List<Map<String, dynamic>>.from(data['data']);
          filteredLocationsList =
              List.from(locationsList); // Initialize filtered list
          isFollowingMap = {
            for (var loc in locationsList)
              loc['id'].toString(): loc['isFollowing'] ?? false
          };
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load locations';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'An error occurred. Please try again later.';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchPages() async {
    userId = await getUserIdFromPrefs();
    if (mounted) {
      setState(() {
        _isLoading = true; // Start loading
      });
    }

    try {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');

      final url = 'https://yarnapi-fuu0.onrender.com/api/pages';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      print("Author Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Check if the 'status' is "Success" and extract the 'data' array
        if (jsonResponse['status'] == 'Success') {
          final List<dynamic> pages = jsonResponse['data'];
          if (mounted) {
            setState(() {
              _pages = pages; // Set the pages list
              _isLoading = false; // Stop loading after success
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _errorMessage =
                  'Failed to load pages'; // Handle unexpected responses
              _isLoading = false; // Stop loading after failure
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to load pages';
            _isLoading = false; // Stop loading after failure
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred. Please try again later.';
          _isLoading = false; // Stop loading after error
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

  void _searchLocations(String query) {
    setState(() {
      if (query.isEmpty) {
        // Show all if the query is empty
        filteredLocationsList = List<Map<String, dynamic>>.from(locationsList);
      } else {
        filteredLocationsList = locationsList
            .where((location) {
              final locationName = location['name']?.toString().toLowerCase();
              final searchQuery = query.toLowerCase();
              return locationName != null && locationName.contains(searchQuery);
            })
            .toList()
            .cast<
                Map<String,
                    dynamic>>(); // Ensure the result is cast to List<Map<String, dynamic>>
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add Scaffold to each page
      body: ListView(
        children: [
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {},
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close_outlined),
                        onPressed: () {
                          searchController.clear();
                          _searchLocations('');
                        },
                      )),
                  cursorColor: Theme.of(context).colorScheme.onSurface,
                  onChanged: (value) {
                    _searchLocations(value);
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              TabBar(
                controller: explorerTabController,
                tabs: [
                  _buildTab('Locations'),
                  _buildTab('Topics'),
                  _buildTab('Author'),
                ],
                //tabNames.map((name) => _buildTab(name)).toList(),
                labelColor: Theme.of(context).colorScheme.onSurface,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
                labelPadding: EdgeInsets.zero,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: Theme.of(context).colorScheme.onSurface,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: TabBarView(
                  controller: explorerTabController,
                  children: [
                    isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF500450)),
                          )
                        : errorMessage.isNotEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error,
                                        size: 80, color: Colors.redAccent),
                                    const SizedBox(height: 20),
                                    Text(
                                      errorMessage,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () => _fetchLocations(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF500450),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                            : filteredLocationsList.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.people,
                                            size: 100, color: Colors.grey),
                                        const SizedBox(height: 20),
                                        const Text(
                                          'No locations found.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 18, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () => _fetchLocations(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF500450),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Retry',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : RefreshIndicator(
                                    onRefresh: _fetchLocations,
                                    child: ListView.builder(
                                      itemCount: filteredLocationsList.length,
                                      itemBuilder: (context, index) {
                                        final locationData =
                                            filteredLocationsList[index];
                                        return location(
                                          locationData['name'],
                                          isFollowingMap[locationData['id']
                                                  .toString()] ??
                                              false,
                                          locationData['id'],
                                        );
                                      },
                                    ),
                                  ),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.article_outlined,
                            size: 100, color: Colors.grey),
                        SizedBox(height: 20),
                        Text(
                          'No contents.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        // const SizedBox(height: 20),
                        // ElevatedButton(
                        //   onPressed: () => _fetchComments(),
                        //   // Retry fetching comments
                        //   child: const Text('Retry'),
                        // ),
                      ],
                    ),
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF500450)),
                          )
                        : _errorMessage.isNotEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error,
                                        size: 80, color: Colors.redAccent),
                                    const SizedBox(height: 20),
                                    Text(
                                      errorMessage,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () => _fetchPages(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF500450),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                            : _pages.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.article_outlined,
                                            size: 100, color: Colors.grey),
                                        const SizedBox(height: 20),
                                        const Text(
                                          'No authors available at the moment.',
                                          style: TextStyle(
                                              fontSize: 18, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () =>
                                              _fetchPages(), // Retry button
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF500450),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Retry',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : RefreshIndicator(
                                    onRefresh: _fetchPages,
                                    child: ListView.builder(
                                      itemCount: _pages.length,
                                      itemBuilder: (context, index) {
                                        final page = _pages[index];
                                        return author(
                                            page['pageProfilePictureUrl'] !=
                                                    null
                                                ? "${page['pageProfilePictureUrl']}/download?project=66e4476900275deffed4"
                                                : '',
                                            page['name'],
                                            page['description'],
                                            '${page['followers'].length} followers',
                                            false,
                                            page['pageId']);
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
    );
  }

  Widget news(String img, String continent, String description,
      String authorImg, String authorName, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Row(
        children: [
          if (_profileImage.isEmpty)
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
                  File(_profileImage),
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
                        if (_profileImage.isEmpty)
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
                                File(_profileImage),
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

  Widget topics(String img, String name, String description) {
    final widgetKey = name;
    bool isSave = _isSaveMap[widgetKey] ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Row(
        children: [
          if (_profileImage.isEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                width: (110 / MediaQuery.of(context).size.width) *
                    MediaQuery.of(context).size.width,
                height: (90 / MediaQuery.of(context).size.height) *
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
                width: (90 / MediaQuery.of(context).size.width) *
                    MediaQuery.of(context).size.width,
                height: (90 / MediaQuery.of(context).size.height) *
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
                  File(_profileImage),
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
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16.0,
                        color: Theme.of(context).colorScheme.onSurface,
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
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _isSaveMap[widgetKey] = !isSave;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSave ? const Color(0xFF500450) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSave
                      ? Colors.transparent
                      : const Color(0xFF500450).withOpacity(0.2),
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: isSave
                  ? const Text(
                      "Saved",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        color: const Color(0xFF500450),
                      ),
                    ),
            ),
          )
        ],
      ),
    );
  }

  Widget author(String img, String name, String description, String followers,
      bool isFollowing, int pageId) {
    isFollowing = isFollowingMap[pageId.toString()] ?? false;
    Future<void> followUser() async {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      final url = 'https://yarnapi-fuu0.onrender.com/api/pages/$pageId/follow';
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
            isFollowingMap[pageId.toString()] = true;
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
          'https://yarnapi-fuu0.onrender.com/api/pages/$pageId/unfollow';
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
            isFollowingMap[pageId.toString()] = false;
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
            builder: (context) => AuthorProfilePage(
              key: UniqueKey(),
              pageId: pageId,
              profileImage: img,
              pageName: name,
              pageDescription: description,
              senderId: userId!,
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
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Text(
                      followers,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                      ),
                    ),
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

  Widget _buildTab(String name) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(name),
      ),
    );
  }

  Widget location(String name, bool isFollowing, int locationId) {
    isFollowing = isFollowingMap[locationId.toString()] ?? false;
    Future<void> followLocation() async {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      final url =
          'https://yarnapi-fuu0.onrender.com/api/locations/$locationId/follow';
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
            isFollowingMap[locationId.toString()] = true;
          });
        } else {
          print('Error: ${response.statusCode}');
        }
      } catch (error) {
        print('Follow error: $error');
      }
    }

    Future<void> unfollowLocation() async {
      final String? accessToken = await storage.read(key: 'yarnAccessToken');
      final url =
          'https://yarnapi-fuu0.onrender.com/api/locations/$locationId/unfollow';
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
            isFollowingMap[locationId.toString()] = false;
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
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => UserProfile(
        //       key: UniqueKey(),
        //       userId: locationId,
        //       senderId: widget.senderId,
        //     ),
        //   ),
        // );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: Row(
            children: [
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
                    unfollowLocation();
                  } else {
                    followLocation();
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
