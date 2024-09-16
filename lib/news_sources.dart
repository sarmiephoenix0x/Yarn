import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yarn/main_app.dart';

class NewsSources extends StatefulWidget {
  const NewsSources({super.key});

  @override
  NewsSourcesState createState() => NewsSourcesState();
}

class NewsSourcesState extends State<NewsSources>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  final storage = const FlutterSecureStorage();
  late SharedPreferences prefs;
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _profileImage = '';
  Map<String, bool> _isFollowingMap = {};

  @override
  void initState() {
    super.initState();
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _showCustomSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  // Wrap SingleChildScrollView with Expanded
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
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
                            const Expanded(
                              flex: 10,
                              child: Text(
                                'Choose your News Sources',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.03),
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
                              floatingLabelBehavior:
                              FloatingLabelBehavior.never,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {},
                              )),
                          cursorColor: Colors.black,
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            countries('images/ProfileImg.png', 'theyarnconcept',
                                "Yarn", "5k followers"),
                            countries('images/ProfileImg.png', 'theyarnconcept',
                                "Yarn2", "10k followers"),
                            countries('images/ProfileImg.png', 'theyarnconcept',
                                "Yarn3", "15k followers"),
                            countries('images/ProfileImg.png', 'theyarnconcept',
                                "Yarn4", "20k followers"),
                            countries('images/ProfileImg.png', 'theyarnconcept',
                                "Yarn5", "25k followers"),
                            countries('images/ProfileImg.png', 'theyarnconcept',
                                "Yarn6", "30k followers"),
                            countries('images/ProfileImg.png', 'theyarnconcept',
                                "Yarn7", "35k followers"),
                            countries('images/ProfileImg.png', 'theyarnconcept',
                                "Yarn8", "40k followers"),
                            countries('images/ProfileImg.png', 'theyarnconcept',
                                "Yarn9", "45k followers"),
                            countries('images/ProfileImg.png', 'theyarnconcept',
                                "Yarn10", "50k followers"),
                            countries('images/ProfileImg.png', 'theyarnconcept',
                                "Yarn11", "55k followers"),
                            countries('images/ProfileImg.png', 'theyarnconcept',
                                "Yarn12", "60k followers"),
                            countries('images/ProfileImg.png', 'theyarnconcept',
                                "Yarn13", "65k followers"),
                            countries('images/ProfileImg.png', 'theyarnconcept',
                                "Yarn14", "70k followers"),
                            SizedBox(
                                height:
                                MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.1),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          width: 0.5, color: Colors.black.withOpacity(0.15))),
                  color: Colors.white,
                ),
                child: SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: Container(
                    width: double.infinity,
                    height: (60 / MediaQuery
                        .of(context)
                        .size
                        .height) *
                        MediaQuery
                            .of(context)
                            .size
                            .height,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainApp(key: UniqueKey()),
                          ),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                            if (states.contains(WidgetState.pressed)) {
                              return Colors.white;
                            }
                            return const Color(0xFF1877F2);
                          },
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                            if (states.contains(WidgetState.pressed)) {
                              return const Color(0xFF1877F2);
                            }
                            return Colors.white;
                          },
                        ),
                        elevation: WidgetStateProperty.all<double>(4.0),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(35)),
                          ),
                        ),
                      ),
                      child: isLoading
                          ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Next',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget countries(String img, String name, String username, String followers) {
    final widgetKey = username;
    bool isFollowing = _isFollowingMap[widgetKey] ?? false;
    return Padding(
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
                    img,
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
                  child: Image.file(
                    File(_profileImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(width: MediaQuery
                .of(context)
                .size
                .width * 0.05),
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
                      Image.asset(
                        'images/verified.png',
                        height: 20,
                      ),
                    ],
                  ),
                  Text(
                    username,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.01),
                  Row(
                    children: [
                      Stack(
                        children: [
                          Positioned(
                            left: 10, // Adjust position for overlap
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(55),
                              child: Container(
                                width: (20 / MediaQuery
                                    .of(context)
                                    .size
                                    .width) *
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .width,
                                height: (20 / MediaQuery
                                    .of(context)
                                    .size
                                    .height) *
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .height,
                                color: Colors.grey,
                                child: Image.asset(
                                  'images/Follower2.png',
                                ),
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(55),
                            child: Container(
                              width: (20 / MediaQuery
                                  .of(context)
                                  .size
                                  .width) *
                                  MediaQuery
                                      .of(context)
                                      .size
                                      .width,
                              height: (20 / MediaQuery
                                  .of(context)
                                  .size
                                  .height) *
                                  MediaQuery
                                      .of(context)
                                      .size
                                      .height,
                              color: Colors.grey,
                              child: Image.asset(
                                'images/Follower1.png',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.01),
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
                      ? const Color(0xFF1877F2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isFollowing
                        ? Colors.transparent
                        : Colors.black.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  "Follow",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    color: isFollowing ? Colors.white : Colors.black,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
