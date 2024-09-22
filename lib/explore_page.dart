import 'dart:io';

import 'package:flutter/material.dart';

class ExplorePage extends StatefulWidget {
  final int selectedIndex;

  const ExplorePage({
    super.key,
    required this.selectedIndex,
  });

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with TickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _profileImage = '';
  TabController? latestTabController;
  TabController? profileTab;
  Map<String, bool> _isSaveMap = {};

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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: Text(
                        "Explore",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w900,
                          fontSize: 30.0,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Text(
                      "Topic",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Spacer(),
                    const Text(
                      "See all",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              topics("images/TrendingImg.png", "Health",
                  "Russian warship: Moskva sinks in Black Sea"),
              topics("images/TrendingImg.png", "Technology",
                  "German warship: Moskva sinks in Black Sea"),
              topics("images/TrendingImg.png", "Art",
                  "Japanese warship: Moskva sinks in Black Sea"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Text(
                      "Popular Topic",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      "See all",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              popular(
                  "images/TrendingImg.png",
                  "Europe",
                  "Russian warship: Moskva sinks in Black Sea",
                  "images/ProfileImg.png",
                  "Anonymous",
                  "4h ago"),
              popular(
                  "images/TrendingImg.png",
                  "Europe",
                  "Russian warship: Moskva sinks in Black Sea",
                  "images/ProfileImg.png",
                  "Anonymous",
                  "4h ago"),
              popular(
                  "images/TrendingImg.png",
                  "Europe",
                  "Russian warship: Moskva sinks in Black Sea",
                  "images/ProfileImg.png",
                  "Anonymous",
                  "4h ago"),
            ],
          ),
        ],
      ),
    );
  }

  Widget popular(String img, String continent, String description,
      String authorImg, String authorName, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Column(
        children: [
          if (_profileImage.isEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                width: double.infinity,
                height: (230 / MediaQuery.of(context).size.height) *
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
                width: double.infinity,
                height: (230 / MediaQuery.of(context).size.height) *
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
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Row(
            children: [
              Text(
                continent,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15.0,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          Text(
            description,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            maxLines: 3,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
                        height: (25 / MediaQuery.of(context).size.height) *
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
                        height: (25 / MediaQuery.of(context).size.height) *
                            MediaQuery.of(context).size.height,
                        color: Colors.grey,
                        child: Image.file(
                          File(_profileImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                  Text(
                    authorName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
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
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03),
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

  Widget _buildTab(String name) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(name),
      ),
    );
  }
}
