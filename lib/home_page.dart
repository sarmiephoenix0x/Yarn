import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yarn/trending_page.dart';

import 'details_page.dart';
import 'latest_page.dart';
import 'notification_page.dart';

class HomePage extends StatefulWidget {
  final int selectedIndex;

  const HomePage({
    super.key,
    required this.selectedIndex,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
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

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: [
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'images/AppLogo.png',
                      height: 50,
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationPage(
                              key: UniqueKey(),
                              selectedIndex: widget.selectedIndex,
                            ),
                          ),
                        );
                      },
                      child: Image.asset(
                        'images/NotificationIcon.png',
                        height: 50,
                      ),
                    ),
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
                        borderSide: const BorderSide(
                          color: Colors.black,
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
                  cursorColor: Colors.black,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    const Text(
                      "Trending",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrendingPage(
                              key: UniqueKey(),
                              selectedIndex: widget.selectedIndex,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "See all",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15.0,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              trending(
                  _profileImage,
                  "Europe",
                  "Russian warship: Moskva sinks in Black Sea",
                  "images/ProfileImg.png",
                  "Anonymous",
                  "4h ago"),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    const Text(
                      "Latest",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LatestPage(
                              key: UniqueKey(),
                              selectedIndex: widget.selectedIndex,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "See all",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15.0,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
                indicatorColor: const Color(0xFF000099),
              ),
              SizedBox(
                height: (400 / MediaQuery.of(context).size.height) *
                    MediaQuery.of(context).size.height,
                child: TabBarView(
                  controller: latestTabController,
                  children: [
                    ListView(
                      children: [
                        latest(
                            _profileImage,
                            "Europe",
                            "Russian warship: Moskva sinks in Black Sea",
                            "images/ProfileImg.png",
                            "Anonymous",
                            "4h ago"),
                        latest(
                            _profileImage,
                            "Europe",
                            "Russian warship: Moskva sinks in Black Sea",
                            "images/ProfileImg.png",
                            "Anonymous",
                            "4h ago"),
                        latest(
                            _profileImage,
                            "Europe",
                            "Russian warship: Moskva sinks in Black Sea",
                            "images/ProfileImg.png",
                            "Anonymous",
                            "4h ago"),
                        latest(
                            _profileImage,
                            "Europe",
                            "Russian warship: Moskva sinks in Black Sea",
                            "images/ProfileImg.png",
                            "Anonymous",
                            "4h ago"),
                        latest(
                            _profileImage,
                            "Europe",
                            "Russian warship: Moskva sinks in Black Sea",
                            "images/ProfileImg.png",
                            "Anonymous",
                            "4h ago"),
                        latest(
                            _profileImage,
                            "Europe",
                            "Russian warship: Moskva sinks in Black Sea",
                            "images/ProfileImg.png",
                            "Anonymous",
                            "4h ago"),
                        latest(
                            _profileImage,
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
    );
  }

  Widget trending(String img, String continent, String description,
      String authorImg, String authorName, String time) {
    return InkWell(
        onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsPage(
            key: UniqueKey(), newsId: 1,
          ),
        ),
      );
    },
    child:Padding(
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
                  "images/TrendingImg.png",
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
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              color: Colors.black,
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
                  "images/TrendingImg.png",
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

  Widget _buildTab(String name) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(name),
      ),
    );
  }
}
