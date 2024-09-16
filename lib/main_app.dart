import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yarn/settings.dart';

class MainApp extends StatefulWidget {
  const MainApp({
    super.key,
  });

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with TickerProviderStateMixin {
  int _selectedIndex = 0;
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
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            // Scrollable views for each bottom nav item
            ListView(
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
                          const Spacer(),
                          InkWell(
                            onTap: () {},
                            child: Image.asset(
                              'images/NotificationIcon.png',
                              height: 50,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.05),
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
                    SizedBox(height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.03),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Text(
                            "Trending",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.black,
                            ),
                          ),
                          Spacer(),
                          Text(
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
                    trending(
                        "images/TrendingImg.png",
                        "Europe",
                        "Russian warship: Moskva sinks in Black Sea",
                        "images/ProfileImg.png",
                        "Anonymous",
                        "4h ago"),
                    SizedBox(height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.03),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Text(
                            "Latest",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.black,
                            ),
                          ),
                          Spacer(),
                          Text(
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
                      height: (400 / MediaQuery
                          .of(context)
                          .size
                          .height) *
                          MediaQuery
                              .of(context)
                              .size
                              .height,
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
            ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) =>
                  ListTile(title: Text("Item ${index + 1}")),
            ),
            ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) =>
                  ListTile(title: Text("Item ${index + 1}")),
            ),
            Scaffold( // Wrap the fourth page content in a Scaffold
              body: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            const Spacer(),
                            const Text(
                              'Profile',
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
                                    builder: (context) => Settings(key: UniqueKey()),
                                  ),
                                );
                              },
                              child: Image.asset(
                                'images/Settings.png',
                                height: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.05),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            if (_profileImage.isEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(55),
                                child: Container(
                                  width:
                                  (80 / MediaQuery
                                      .of(context)
                                      .size
                                      .width) *
                                      MediaQuery
                                          .of(context)
                                          .size
                                          .width,
                                  height:
                                  (80 / MediaQuery
                                      .of(context)
                                      .size
                                      .height) *
                                      MediaQuery
                                          .of(context)
                                          .size
                                          .height,
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
                                  width:
                                  (80 / MediaQuery
                                      .of(context)
                                      .size
                                      .width) *
                                      MediaQuery
                                          .of(context)
                                          .size
                                          .width,
                                  height:
                                  (80 / MediaQuery
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
                                    .width * 0.02),
                            const Expanded(
                              flex: 5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
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
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
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
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
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
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.03),
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
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.03),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {},
                              child: Container(
                                width: (150 / MediaQuery
                                    .of(context)
                                    .size
                                    .width) *
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .width,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: const Text(
                                  "Edit profile",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () {},
                              child: Container(
                                width: (150 / MediaQuery
                                    .of(context)
                                    .size
                                    .width) *
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .width,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: const Text(
                                  "Share profile",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.03),
                      TabBar(
                        controller: profileTab,
                        tabs: [
                          _buildTab('Timeline'),
                          _buildTab('My Community'),
                        ],
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inconsolata',
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inconsolata',
                        ),
                        labelPadding: EdgeInsets.zero,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorColor: Colors.black,
                      ),
                      SizedBox(
                        height: (400 / MediaQuery
                            .of(context)
                            .size
                            .height) *
                            MediaQuery
                                .of(context)
                                .size
                                .height,
                        child: TabBarView(
                          controller: profileTab,
                          children: [
                            ListView(
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              floatingActionButton: _selectedIndex == 3
                  ? FloatingActionButton(
                onPressed: () {
                  // Add your onPressed logic here
                },
                backgroundColor: Colors.blue,
                shape: const CircleBorder(),
                child: const Icon(Icons.add),
              )
                  : null,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const ImageIcon(
              AssetImage('images/Home.png'),
              color: Colors.grey,
            ),
            label: '',
            // Add notification dot
            activeIcon: Stack(
              alignment: Alignment.center,
              children: [
                const ImageIcon(AssetImage('images/Home-Active.png')),
                if (_hasNotification[0])
                  Positioned(
                    bottom: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      width: 8,
                      height: 8,
                    ),
                  ),
              ],
            ),
          ),
          BottomNavigationBarItem(
            icon: const ImageIcon(
              AssetImage('images/Explore.png'),
              color: Colors.grey,
            ),
            label: '',
            activeIcon: Stack(
              alignment: Alignment.center,
              children: [
                const ImageIcon(AssetImage('images/Explore.png')),
                if (_hasNotification[1])
                  Positioned(
                    bottom: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      width: 8,
                      height: 8,
                    ),
                  ),
              ],
            ),
          ),
          BottomNavigationBarItem(
            icon: const ImageIcon(
              AssetImage('images/Like.png'),
              color: Colors.grey,
            ),
            label: '',
            activeIcon: Stack(
              alignment: Alignment.center,
              children: [
                const ImageIcon(AssetImage('images/Like.png')),
                if (_hasNotification[2])
                  Positioned(
                    bottom: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      width: 8,
                      height: 8,
                    ),
                  ),
              ],
            ),
          ),
          BottomNavigationBarItem(
            icon: const ImageIcon(
              AssetImage('images/Account.png'),
              color: Colors.grey,
            ),
            label: '',
            activeIcon: Stack(
              alignment: Alignment.center,
              children: [
                const ImageIcon(AssetImage('images/Account-active.png')),
                if (_hasNotification[3])
                  Positioned(
                    bottom: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      width: 8,
                      height: 8,
                    ),
                  ),
              ],
            ),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Customize the selected item color
        onTap: _onItemTapped,
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
