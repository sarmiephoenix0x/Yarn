import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yarn/settings.dart';

class TrendingPage extends StatefulWidget {
  final int selectedIndex;
  const TrendingPage({
    super.key,
    required this.selectedIndex,
  });

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> with TickerProviderStateMixin {
  int _selectedIndex = 1;
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<bool> _hasNotification = [false, false, false, false];
  String _profileImage = '';
  TabController? latestTabController;
  TabController? profileTab;

  @override
  void initState() {
    super.initState();
    latestTabController = TabController(length: 7, vsync: this);
    profileTab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
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
    return Scaffold( // Add Scaffold to each page
      body: ListView(
        children: [
          Column(
            children: [
              SizedBox(height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.03),
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
                      ),
                    ),
                    const Spacer(),
                     const Text(
                        'Trending',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: Colors.black,
                        ),
                      ),
                    const Spacer(),
                    const Icon(Icons.more_vert),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.05),
              trending(
                  "images/TrendingImg.png",
                  "Europe",
                  "Russian warship: Moskva sinks in Black Sea",
                  "images/ProfileImg.png",
                  "Anonymous",
                  "4h ago"),
              trending(
                  "images/TrendingImg.png",
                  "Europe",
                  "Russian warship: Moskva sinks in Black Sea",
                  "images/ProfileImg.png",
                  "Anonymous",
                  "4h ago"),
              trending(
                  "images/TrendingImg.png",
                  "Europe",
                  "Russian warship: Moskva sinks in Black Sea",
                  "images/ProfileImg.png",
                  "Anonymous",
                  "4h ago"),
              trending(
                  "images/TrendingImg.png",
                  "Europe",
                  "Russian warship: Moskva sinks in Black Sea",
                  "images/ProfileImg.png",
                  "Anonymous",
                  "4h ago"),
              trending(
                  "images/TrendingImg.png",
                  "Europe",
                  "Russian warship: Moskva sinks in Black Sea",
                  "images/ProfileImg.png",
                  "Anonymous",
                  "4h ago"),
              trending(
                  "images/TrendingImg.png",
                  "Europe",
                  "Russian warship: Moskva sinks in Black Sea",
                  "images/ProfileImg.png",
                  "Anonymous",
                  "4h ago"),
              trending(
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

  Widget trending(String img, String continent, String description,
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
                height: (230 / MediaQuery
                    .of(context)
                    .size
                    .height) *
                    MediaQuery
                        .of(context)
                        .size
                        .height,
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
                height: (230 / MediaQuery
                    .of(context)
                    .size
                    .height) *
                    MediaQuery
                        .of(context)
                        .size
                        .height,
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
          SizedBox(height: MediaQuery
              .of(context)
              .size
              .height * 0.02),
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
          SizedBox(height: MediaQuery
              .of(context)
              .size
              .height * 0.04),
          Text(
            description,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            maxLines: 3,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              color: Colors.black,
            ),
          ),
          SizedBox(height: MediaQuery
              .of(context)
              .size
              .height * 0.03),
          Row(
            children: [
              Row(
                children: [
                  if (_profileImage.isEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(55),
                      child: Container(
                        width: (25 / MediaQuery
                            .of(context)
                            .size
                            .width) *
                            MediaQuery
                                .of(context)
                                .size
                                .width,
                        height: (25 / MediaQuery
                            .of(context)
                            .size
                            .height) *
                            MediaQuery
                                .of(context)
                                .size
                                .height,
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
                        width: (25 / MediaQuery
                            .of(context)
                            .size
                            .width) *
                            MediaQuery
                                .of(context)
                                .size
                                .width,
                        height: (25 / MediaQuery
                            .of(context)
                            .size
                            .height) *
                            MediaQuery
                                .of(context)
                                .size
                                .height,
                        color: Colors.grey,
                        child: Image.file(
                          File(_profileImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  SizedBox(width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.03),
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
                  SizedBox(width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.03),
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
}