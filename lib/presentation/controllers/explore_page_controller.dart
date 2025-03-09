import 'package:flutter/material.dart' hide CarouselController;

class ExplorePageController extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _profileImage = '';
  TabController? latestTabController;
  TabController? profileTab;
  Map<String, bool> _isSaveMap = {};

  TickerProvider vsync;

  ExplorePageController({required this.vsync}) {
    initialize();
  }

//public getters
  String get profileImage => _profileImage;
  Map<String, bool> get isSaveMap => _isSaveMap;

  void setIsSaveMap(bool value, String key) {
    _isSaveMap[key] = value;
    notifyListeners();
  }

  void initialize() {
    latestTabController = TabController(length: 7, vsync: vsync);
    profileTab = TabController(length: 2, vsync: vsync);
  }
}
