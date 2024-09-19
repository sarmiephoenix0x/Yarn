import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yarn/settings.dart';

class LatestPage extends StatefulWidget {
  final int selectedIndex;
  const LatestPage({
    super.key,
    required this.selectedIndex,
  });

  @override
  State<LatestPage> createState() => _LatestPageState();
}

class _LatestPageState extends State<LatestPage> with TickerProviderStateMixin {
  int _selectedIndex = 1;
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<bool> _hasNotification = [false, false, false, false];
  String _profileImage = '';
  TabController? latestTabController;

  @override
  void initState() {
    super.initState();
    latestTabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    latestTabController?.dispose();
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
                      'Latest',
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

              SizedBox(height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.03),
              TabBar(
                tabAlignment: TabAlignment.start,
                controller: latestTabController,
                isScrollable: true,
                tabs: [
                  _buildTab('All'),
                  _buildTab('Sports'),
                  _buildTab('Politics'),
                  _buildTab('Business'),
                  _buildTab('Health'),
                  _buildTab('Travel'),
                  _buildTab('Science'),
                ],
                //tabNames.map((name) => _buildTab(name)).toList(),
                labelColor: Colors.black,
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
                indicatorColor: Colors.blue,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: TabBarView(
                  controller: latestTabController,
                  children: [
                    ListView(
                      children: [
                        latest(
                            "images/TrendingImg.png",
                            "Europe",
                            "Russian warship: Moskva sinks in Black Sea",
                            "images/ProfileImg.png",
                            "Anonymous",
                            "4h ago"),
                        latest(
                            "images/TrendingImg.png",
                            "Europe",
                            "Russian warship: Moskva sinks in Black Sea",
                            "images/ProfileImg.png",
                            "Anonymous",
                            "4h ago"),
                        latest(
                            "images/TrendingImg.png",
                            "Europe",
                            "Russian warship: Moskva sinks in Black Sea",
                            "images/ProfileImg.png",
                            "Anonymous",
                            "4h ago"),
                        latest(
                            "images/TrendingImg.png",
                            "Europe",
                            "Russian warship: Moskva sinks in Black Sea",
                            "images/ProfileImg.png",
                            "Anonymous",
                            "4h ago"),
                        latest(
                            "images/TrendingImg.png",
                            "Europe",
                            "Russian warship: Moskva sinks in Black Sea",
                            "images/ProfileImg.png",
                            "Anonymous",
                            "4h ago"),
                        latest(
                            "images/TrendingImg.png",
                            "Europe",
                            "Russian warship: Moskva sinks in Black Sea",
                            "images/ProfileImg.png",
                            "Anonymous",
                            "4h ago"),
                        latest(
                            "images/TrendingImg.png",
                            "Europe",
                            "Russian warship: Moskva sinks in Black Sea",
                            "images/ProfileImg.png",
                            "Anonymous",
                            "4h ago"),
                      ],
                    ),
                    ListView(
                      children: [],
                    ),
                    ListView(
                      children: [],
                    ),
                    ListView(
                      children: [],
                    ),
                    ListView(
                      children: [],
                    ),
                    ListView(
                      children: [],
                    ),
                    ListView(
                      children: [],
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

  Widget latest(String img, String continent, String description,
      String authorImg, String authorName, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Row(
        children: [
          if (_profileImage.isEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                width: (110 / MediaQuery
                    .of(context)
                    .size
                    .width) *
                    MediaQuery
                        .of(context)
                        .size
                        .width,
                height: (130 / MediaQuery
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
                width: (50 / MediaQuery
                    .of(context)
                    .size
                    .width) *
                    MediaQuery
                        .of(context)
                        .size
                        .width,
                height: (50 / MediaQuery
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
          SizedBox(width: MediaQuery
              .of(context)
              .size
              .width * 0.02),
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
                SizedBox(height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.02),
                Text(
                  description,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  maxLines: 3,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.01),
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
                              height:
                              (25 / MediaQuery
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
                              height:
                              (25 / MediaQuery
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
                        SizedBox(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.01),
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
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.03),
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