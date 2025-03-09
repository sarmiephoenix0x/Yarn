import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectCountryController extends ChangeNotifier {
  bool _isLoading = false;
  final storage = const FlutterSecureStorage();
  late SharedPreferences prefs;
  TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Country? _selectedCountry;

  SelectCityController() {
    initialize();
  }

//public getters
  bool get isLoading => _isLoading;
  Country? get selectedCountry => _selectedCountry;

  TextEditingController get searchController => _searchController;

  void setSelectedCountry(Country? value) {
    _selectedCountry = value;
    notifyListeners();
  }

  void initialize() {
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }
}
