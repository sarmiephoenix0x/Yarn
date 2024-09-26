import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:yarn/trending_page.dart';

import 'details_page.dart';
import 'latest_page.dart';
import 'notification_page.dart';
import 'package:yarn/select_country.dart';

class HomePage extends StatefulWidget {
  final int selectedIndex;
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;

  const HomePage({
    super.key,
    required this.selectedIndex,
    required this.onToggleDarkMode,
    required this.isDarkMode
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
  bool isLiked = false;
  int _current = 0;
  final CarouselController _controller = CarouselController();
  Map<String, bool> _isFollowingMap = {};

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
    return ListView(
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
                          builder: (context) =>
                              NotificationPage(
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
            SizedBox(height: MediaQuery
                .of(context)
                .size
                .height * 0.05),
            post(
                _profileImage,
                _profileImage,
                "Lagos State | Agege LGA",
                "Ukrainian President Volodymyr Zelensky has accused European countries that continue to buy Russian oil of earning their money in other people's blood.\nIn an interview with the BBC, President Zelensky singled out Germany and Hungary, accusing them of blocking efforts to embargo energy sales, from which Russia stands to make up to £250bn (\$326bn) this year.\nThere has been a growing frustration among Ukraine's leadership with Berlin, which has backed some sanctions against Russia but so far resisted calls to back tougher action on oil sales.",
                [
                  "images/TrendingImg.png",
                  "images/TrendingImg.png",
                  "images/TrendingImg.png",
                ],
                "Author",
                "@username",
                "4h ago",
                true,
                false),
            post(
                _profileImage,
                _profileImage,
                "Lagos State | Agege LGA",
                "Ukrainian President Volodymyr Zelensky has accused European countries that continue to buy Russian oil of earning their money in other people's blood.\nIn an interview with the BBC, President Zelensky singled out Germany and Hungary, accusing them of blocking efforts to embargo energy sales, from which Russia stands to make up to £250bn (\$326bn) this year.\nThere has been a growing frustration among Ukraine's leadership with Berlin, which has backed some sanctions against Russia but so far resisted calls to back tougher action on oil sales.",
                [],
                "Author2",
                "@username",
                "4h ago",
                false,
                false),
            post(
                _profileImage,
                _profileImage,
                "Lagos State | Agege LGA",
                "Ukrainian President Volodymyr Zelensky has accused European countries that continue to buy Russian oil of earning their money in other people's blood.\nIn an interview with the BBC, President Zelensky singled out Germany and Hungary, accusing them of blocking efforts to embargo energy sales, from which Russia stands to make up to £250bn (\$326bn) this year.\nThere has been a growing frustration among Ukraine's leadership with Berlin, which has backed some sanctions against Russia but so far resisted calls to back tougher action on oil sales.",
                [],
                "Author2",
                "@username",
                "4h ago",
                false,
                true),
          ],
        ),
      ],
    );
  }

  Widget post(String authorImg,
      String accountOwnerImg,
      String location,
      String description,
      List<String> postImg,
      String authorName,
      String authorUsername,
      String time,
      bool verified,
      bool anonymous) {
    Color originalIconColor = IconTheme
        .of(context)
        .color ?? Colors.black;
    final widgetKey = authorName;
    bool isFollowing = _isFollowingMap[widgetKey] ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: InkWell(
        onTap: () {
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) =>
          //         SelectCountry(key: UniqueKey(),
          //             onToggleDarkMode: widget.onToggleDarkMode,
          //             isDarkMode: widget.isDarkMode),
          //   ),
          // );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DetailsPage(
                      key: UniqueKey(),
                      newsId: 1,
                      postImg: postImg,
                      authorImg: authorImg,
                      description: description,
                      authorName: authorName,
                      verified: verified,
                      anonymous: anonymous,
                      time: time,
                      isFollowing: isFollowing),
            ),
          );
        },
        child: SizedBox(
          width: MediaQuery
              .of(context)
              .size
              .width,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    if (anonymous == false)
                      if (authorImg.isEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(55),
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
                            color: Colors.grey,
                            child: Image.network(
                              authorImg,
                              // Use the communityProfilePictureUrl or a default image
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                    color:
                                    Colors.grey); // Fallback if image fails
                              },
                            ),
                          ),
                        ),
                    SizedBox(width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.03),
                    Expanded(
                      flex: 10,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (anonymous == false) ...[
                            Row(
                              children: [
                                Text(
                                  authorName,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (verified == true)
                                  Image.asset(
                                    'images/verified.png',
                                    height: 20,
                                  ),
                              ],
                            ),
                            Text(
                              authorUsername,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.grey,
                              ),
                            ),
                          ] else
                            ...[
                              Text(
                                'Anonymous',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          if (postImg.isEmpty) ...[
                            SizedBox(
                                width:
                                MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.03),
                            Text(
                              location,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: Color(0xFF4E4B66),
                              ),
                            ),
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
                                        .width *
                                        0.01),
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
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (anonymous == false)
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
                                  : Theme
                                  .of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: isFollowing
                              ? Text(
                            "Following",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              color:
                              Theme
                                  .of(context)
                                  .colorScheme
                                  .onSurface,
                            ),
                          )
                              : Text(
                            "Follow",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              color:
                              Theme
                                  .of(context)
                                  .colorScheme
                                  .onSurface,
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              ),
              if (postImg.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                      top: 30.0, bottom: 10.0, left: 20.0, right: 20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: false,
                        enlargeCenterPage: false,
                        aspectRatio: 14 / 9,
                        viewportFraction: 1.0,
                        enableInfiniteScroll: true,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _current = index;
                          });
                        },
                      ),
                      carouselController: _controller,
                      items: postImg.map((item) {
                        return Image.asset(
                          item,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              if (postImg.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : originalIconColor),
                          onPressed: () {
                            setState(() {
                              isLiked = !isLiked;
                            });
                          },
                        ),
                        Text(
                          '20.2K',
                          style: TextStyle(
                            fontFamily: 'Inconsolata',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme
                                .of(context)
                                .colorScheme
                                .onSurface,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.06),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: () {},
                        ),
                        Text(
                          '1K',
                          style: TextStyle(
                            fontFamily: 'Inconsolata',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme
                                .of(context)
                                .colorScheme
                                .onSurface,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        postImg.length,
                            (index) =>
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0),
                              child: Image.asset(
                                _current == index
                                    ? "images/ActiveElipses.png"
                                    : "images/InactiveElipses.png",
                                width: (10 / MediaQuery
                                    .of(context)
                                    .size
                                    .width) *
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .width,
                                height: (10 / MediaQuery
                                    .of(context)
                                    .size
                                    .height) *
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .height,
                              ),
                            ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {},
                    ),
                  ]),
                ),
              SizedBox(height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.04),
              if (postImg.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Text(
                        location,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Color(0xFF4E4B66),
                        ),
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
                              fontSize: 15.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  description,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  maxLines: 3,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18.0,
                    color: Theme
                        .of(context)
                        .colorScheme
                        .onSurface,
                  ),
                ),
              ),
              if (postImg.isEmpty) ...[
                SizedBox(height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.04),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : originalIconColor),
                          onPressed: () {
                            setState(() {
                              isLiked = !isLiked;
                            });
                          },
                        ),
                        Text(
                          '20.2K',
                          style: TextStyle(
                            fontFamily: 'Inconsolata',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme
                                .of(context)
                                .colorScheme
                                .onSurface,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.06),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: () {},
                        ),
                        Text(
                          '1K',
                          style: TextStyle(
                            fontFamily: 'Inconsolata',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme
                                .of(context)
                                .colorScheme
                                .onSurface,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        postImg.length,
                            (index) =>
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0),
                              child: Image.asset(
                                _current == index
                                    ? "images/ActiveElipses.png"
                                    : "images/InactiveElipses.png",
                                width: (10 / MediaQuery
                                    .of(context)
                                    .size
                                    .width) *
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .width,
                                height: (10 / MediaQuery
                                    .of(context)
                                    .size
                                    .height) *
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .height,
                              ),
                            ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () {},
                    ),
                  ]),
                ),
              ],
              SizedBox(height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.03),
              SizedBox(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      if (_profileImage.isEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(55),
                          child: Container(
                            width: (30 / MediaQuery
                                .of(context)
                                .size
                                .width) *
                                MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                            height: (30 / MediaQuery
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
                            child: Image.network(
                              authorImg,
                              // Use the communityProfilePictureUrl or a default image
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                    color:
                                    Colors.grey); // Fallback if image fails
                              },
                            ),
                          ),
                        ),
                      SizedBox(width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.01),
                      // Comment TextField
                      Expanded(
                        // Use Expanded to allow TextField to fill available space
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Add comment...',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .onSurface,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide:
                              BorderSide.none, // Remove default border
                            ),
                            filled: false,
                            fillColor: Colors.grey[200],
                            // Light grey background
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.04),
              Divider(color: Theme
                  .of(context)
                  .colorScheme
                  .onSurface),
            ],
          ),
        ),
      ),
    );
  }
}
