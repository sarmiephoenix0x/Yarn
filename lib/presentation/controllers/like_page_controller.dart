import 'package:flutter/material.dart';

class LikePageController extends ChangeNotifier {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _profileImage = '';
  TabController? bookmarkTabController;
  TabController? profileTab;

  TickerProvider vsync;

  LikePageController({required this.vsync}) {
    initialize();
  }

//public getters
  String get profileImage => _profileImage;

  TextEditingController get searchController => _searchController;
  FocusNode get searchFocusNode => _searchFocusNode;

  void initialize() {
    bookmarkTabController = TabController(length: 7, vsync: vsync);
    profileTab = TabController(length: 2, vsync: vsync);
  }
}
