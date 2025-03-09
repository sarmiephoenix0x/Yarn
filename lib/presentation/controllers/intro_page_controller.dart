import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter/services.dart';

class IntroPageController extends ChangeNotifier {
  List<String> _imagePaths = [
    "images/WelcomeImg.png",
    "images/WelcomeImg2.png",
    "images/WelcomeImg3.png",
  ];

  List<String> _imageHeaders = [
    "Welcome to Yarn – See Something, Say Something",
    "Share Information Safely & Stay Informed",
    "Support Local & Grow Together",
  ];

  List<String> _imageSubheadings = [
    "Join Yarn and be part of a community that shares valuable updates, news, and tips that can make a difference in your life and others around you.",
    "Easily share updates on traffic, security, health, or local events, all while staying anonymous. Stay updated with real-time alerts from your community.",
    "Discover local businesses, engage in important discussions, and contribute to the growth of your community. Yarn brings people together for a stronger, safer neighborhood.",
  ];

  int _current = 0;

  // Use the fully qualified CarouselController from the carousel_slider package
  final CarouselController _controller = CarouselController();
  DateTime? _currentBackPressTime;

  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;

  IntroPageController(
      {required this.onToggleDarkMode, required this.isDarkMode});

//public getters
  int get current => _current;
  CarouselController get controller => _controller;
  List<String> get imagePaths => _imagePaths;
  List<String> get imageHeaders => _imageHeaders;
  List<String> get imageSubheadings => _imageSubheadings;

  void setCurrent(int value) {
    _current = value;
    notifyListeners();
  }
}
