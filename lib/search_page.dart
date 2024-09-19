import 'dart:io';

import 'package:flutter/material.dart';

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
  Map<String, bool> _isFollowingMap = {};

  @override
  void initState() {
    super.initState();
    explorerTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    explorerTabController?.dispose();
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
                        borderSide: const BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {},
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close_outlined),
                        onPressed: () {},
                      )),
                  cursorColor: Colors.black,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              TabBar(
                controller: explorerTabController,
                tabs: [
                  _buildTab('News'),
                  _buildTab('Topics'),
                  _buildTab('Author'),
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
                indicatorColor: const Color(0xFF000099),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: TabBarView(
                  controller: explorerTabController,
                  children: [
                    ListView(
                      children: [
                        news(
                            "images/TrendingImg.png",
                            "Europe",
                            "Russian warship: Moskva sinks in Black Sea",
                            "images/ProfileImg.png",
                            "Anonymous",
                            "4h ago"),
                        news(
                            "images/TrendingImg.png",
                            "Europe",
                            "Russian warship: Moskva sinks in Black Sea",
                            "images/ProfileImg.png",
                            "Anonymous",
                            "4h ago"),
                        news(
                            "images/TrendingImg.png",
                            "Europe",
                            "Russian warship: Moskva sinks in Black Sea",
                            "images/ProfileImg.png",
                            "Anonymous",
                            "4h ago"),
                        news(
                            "images/TrendingImg.png",
                            "Europe",
                            "Russian warship: Moskva sinks in Black Sea",
                            "images/ProfileImg.png",
                            "Anonymous",
                            "4h ago"),
                        news(
                            "images/TrendingImg.png",
                            "Europe",
                            "Russian warship: Moskva sinks in Black Sea",
                            "images/ProfileImg.png",
                            "Anonymous",
                            "4h ago"),
                        news(
                            "images/TrendingImg.png",
                            "Europe",
                            "Russian warship: Moskva sinks in Black Sea",
                            "images/ProfileImg.png",
                            "Anonymous",
                            "4h ago"),
                        news(
                            "images/TrendingImg.png",
                            "Europe",
                            "Russian warship: Moskva sinks in Black Sea",
                            "images/ProfileImg.png",
                            "Anonymous",
                            "4h ago"),
                      ],
                    ),
                    ListView(
                      children: [
                        topics("images/TrendingImg.png", "Art",
                            "Russian warship: Moskva sinks in Black Sea"),
                      ],
                    ),
                    ListView(
                      children: [
                        author('images/ProfileImg.png', "Yarn", "5k followers"),
                      ],
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
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.black,
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
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16.0,
                        color: Colors.black,
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
                color: isSave ? const Color(0xFF000099) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSave
                      ? Colors.transparent
                      : const Color(0xFF000099).withOpacity(0.2),
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
                        color: const Color(0xFF000099),
                      ),
                    ),
            ),
          )
        ],
      ),
    );
  }

  Widget author(String img, String name, String followers) {
    final widgetKey = name;
    bool isFollowing = _isFollowingMap[widgetKey] ?? false;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AuthorProfilePage(key: UniqueKey(), selectedIndex: widget.selectedIndex,),
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
              if (_profileImage.isEmpty)
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
                    child: Image.file(
                      File(_profileImage),
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
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Row(
                      children: [
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
                        ? const Color(0xFF000099)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isFollowing
                          ? Colors.transparent
                          : const Color(0xFF000099).withOpacity(0.2),
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
                            color: const Color(0xFF000099),
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
}