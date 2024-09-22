import 'dart:io';

import 'package:flutter/material.dart';

class LikePage extends StatefulWidget {
  final int selectedIndex;

  const LikePage({
    super.key,
    required this.selectedIndex,
  });

  @override
  State<LikePage> createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> with TickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _profileImage = '';
  TabController? bookmarkTabController;
  TabController? profileTab;

  @override
  void initState() {
    super.initState();
    bookmarkTabController = TabController(length: 7, vsync: this);
    profileTab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    bookmarkTabController?.dispose();
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
                        "Bookmark",
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
                        icon: const Icon(Icons.filter_list_alt),
                        onPressed: () {},
                      )),
                  cursorColor: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              SizedBox(
                height: (420 / MediaQuery.of(context).size.height) *
                    MediaQuery.of(context).size.height,
                child: ListView(
                  children: [
                    bookmark(
                        "images/TrendingImg.png",
                        "Europe",
                        "Russian warship: Moskva sinks in Black Sea",
                        "images/ProfileImg.png",
                        "Anonymous",
                        "4h ago"),
                    bookmark(
                        "images/TrendingImg.png",
                        "Europe",
                        "Russian warship: Moskva sinks in Black Sea",
                        "images/ProfileImg.png",
                        "Anonymous",
                        "4h ago"),
                    bookmark(
                        "images/TrendingImg.png",
                        "Europe",
                        "Russian warship: Moskva sinks in Black Sea",
                        "images/ProfileImg.png",
                        "Anonymous",
                        "4h ago"),
                    bookmark(
                        "images/TrendingImg.png",
                        "Europe",
                        "Russian warship: Moskva sinks in Black Sea",
                        "images/ProfileImg.png",
                        "Anonymous",
                        "4h ago"),
                    bookmark(
                        "images/TrendingImg.png",
                        "Europe",
                        "Russian warship: Moskva sinks in Black Sea",
                        "images/ProfileImg.png",
                        "Anonymous",
                        "4h ago"),
                    bookmark(
                        "images/TrendingImg.png",
                        "Europe",
                        "Russian warship: Moskva sinks in Black Sea",
                        "images/ProfileImg.png",
                        "Anonymous",
                        "4h ago"),
                    bookmark(
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

  Widget bookmark(String img, String continent, String description,
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
