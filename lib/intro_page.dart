import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:yarn/sign_up_page.dart';
import 'package:yarn/sign_in_page.dart';

class IntroPage extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;

  const IntroPage(
      {super.key, required this.onToggleDarkMode, required this.isDarkMode});

  @override
  // ignore: library_private_types_in_public_api
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  List<String> imagePaths = [
    "images/WelcomeImg.png",
    "images/WelcomeImg2.png",
    "images/WelcomeImg3.png",
  ];

  List<String> imageHeaders = [
    "Welcome to Yarn – See Something, Say Something",
    "Share Information Safely & Stay Informed",
    "Support Local & Grow Together",
  ];

  List<String> imageSubheadings = [
    "Join Yarn and be part of a community that shares valuable updates, news, and tips that can make a difference in your life and others around you.",
    "Easily share updates on traffic, security, health, or local events, all while staying anonymous. Stay updated with real-time alerts from your community.",
    "Discover local businesses, engage in important discussions, and contribute to the growth of your community. Yarn brings people together for a stronger, safer neighborhood.",
  ];

  int _current = 0;

  // Use the fully qualified CarouselController from the carousel_slider package
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Column(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        enlargeCenterPage: false,
                        height: MediaQuery.of(context).size.height,
                        // Set a fixed height for the carousel
                        viewportFraction: 1.0,
                        enableInfiniteScroll: false,
                        initialPage: 0,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _current = index;
                          });
                        },
                      ),
                      carouselController: _controller,
                      items: imagePaths.map((item) {
                        return SingleChildScrollView(
                          child: ListView(
                            // Use ListView for vertical scrolling
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            // Prevent ListView from scrolling horizontally
                            children: [
                              if (_current == 2)
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                ),
                              Image.asset(
                                item,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                              if (_current == 2)
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Text(
                                  imageHeaders[_current],
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontFamily: 'Inconsolata',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Text(
                                    imageSubheadings[_current],
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontFamily: 'Inconsolata',
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              imagePaths.length,
                              (index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Image.asset(
                                  _current == index
                                      ? "images/ActiveElipses.png"
                                      : "images/InactiveElipses.png",
                                  width:
                                      (10 / MediaQuery.of(context).size.width) *
                                          MediaQuery.of(context).size.width,
                                  height: (10 /
                                          MediaQuery.of(context).size.height) *
                                      MediaQuery.of(context).size.height,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (_current != 0)
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _controller.previousPage();
                                });
                              },
                              child: const Text(
                                'Back',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.03),
                          if (_current == 2)
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SignInPage(key: UniqueKey(),
                                            onToggleDarkMode: widget.onToggleDarkMode,
                                            isDarkMode: widget.isDarkMode),
                                  ),
                                );
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.resolveWith<Color>(
                                  (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.pressed)) {
                                      return Colors.white;
                                    }
                                    return const Color(0xFF500450);
                                  },
                                ),
                                foregroundColor:
                                    WidgetStateProperty.resolveWith<Color>(
                                  (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.pressed)) {
                                      return const Color(0xFF500450);
                                    }
                                    return Colors.white;
                                  },
                                ),
                                elevation: WidgetStateProperty.all<double>(4.0),
                                shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Get Started',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (_current != 2)
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _controller.nextPage();
                                });
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.resolveWith<Color>(
                                  (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.pressed)) {
                                      return Colors.white;
                                    }
                                    return const Color(0xFF500450);
                                  },
                                ),
                                foregroundColor:
                                    WidgetStateProperty.resolveWith<Color>(
                                  (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.pressed)) {
                                      return const Color(0xFF500450);
                                    }
                                    return Colors.white;
                                  },
                                ),
                                elevation: WidgetStateProperty.all<double>(4.0),
                                shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Next',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
