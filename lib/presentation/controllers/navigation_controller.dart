import 'package:flutter/material.dart';

class NavigationController extends ChangeNotifier {
  int _selectedIndex = 0;
  bool _syncingSchools = false;

  int get selectedIndex => _selectedIndex;
  bool get syncingSchools => _syncingSchools;

  void changeTab(int index) {
    if (!_syncingSchools || (index != 2)) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void setSyncingSchools(bool value) {
    _syncingSchools = value;
    notifyListeners();
  }
}
