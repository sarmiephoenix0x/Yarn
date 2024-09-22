import 'dart:io';

import 'package:flutter/material.dart';

class AuthorProfilePage extends StatefulWidget {
  final int selectedIndex;

  const AuthorProfilePage({
    super.key,
    required this.selectedIndex,
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
  String _profileImage = '';
  TabController? latestTabController;
  TabController? profileTab;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
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
                        color:Theme.of(context).colorScheme.onSurface,
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
                            File(_profileImage),
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
                            "2156",
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
                            "567",
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
                            "23",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          Text(
                            "News",
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
              const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Sarmie Phioenix",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
              const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                        setState(() {
                          isFollowing = !isFollowing;
                        });
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
                                  color: Theme.of(context).colorScheme.onSurface,
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
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
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
                child: ListView(
                  children: [
                    timeline(
                        "images/TrendingImg.png",
                        "Europe",
                        "Russian warship: Moskva sinks in Black Sea",
                        "images/ProfileImg.png",
                        "Anonymous",
                        "4h ago"),
                    timeline(
                        "images/TrendingImg.png",
                        "Europe",
                        "Russian warship: Moskva sinks in Black Sea",
                        "images/ProfileImg.png",
                        "Anonymous",
                        "4h ago"),
                    timeline(
                        "images/TrendingImg.png",
                        "Europe",
                        "Russian warship: Moskva sinks in Black Sea",
                        "images/ProfileImg.png",
                        "Anonymous",
                        "4h ago"),
                    timeline(
                        "images/TrendingImg.png",
                        "Europe",
                        "Russian warship: Moskva sinks in Black Sea",
                        "images/ProfileImg.png",
                        "Anonymous",
                        "4h ago"),
                    timeline(
                        "images/TrendingImg.png",
                        "Europe",
                        "Russian warship: Moskva sinks in Black Sea",
                        "images/ProfileImg.png",
                        "Anonymous",
                        "4h ago"),
                    timeline(
                        "images/TrendingImg.png",
                        "Europe",
                        "Russian warship: Moskva sinks in Black Sea",
                        "images/ProfileImg.png",
                        "Anonymous",
                        "4h ago"),
                    timeline(
                        "images/TrendingImg.png",
                        "Europe",
                        "Russian warship: Moskva sinks in Black Sea",
                        "images/ProfileImg.png",
                        "Anonymous",
                        "4h ago"),
                  ],
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

  Widget _buildTab(String name) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(name),
      ),
    );
  }
}
