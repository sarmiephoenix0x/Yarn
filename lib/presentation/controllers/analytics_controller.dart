import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsController extends ChangeNotifier {
  bool _isLoading = false;
  final storage = const FlutterSecureStorage();
  late SharedPreferences prefs;
  bool _tipsVisible = true;

  AnalyticsController() {
    initializePrefs();
  }

//public getters
  bool get isLoading => _isLoading;
  bool get tipsVisible => _tipsVisible;

  void setTipsVisible(bool value) {
    _tipsVisible = value;
    notifyListeners();
  }

  Future<void> initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }
}
