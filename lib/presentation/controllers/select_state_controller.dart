import 'package:country_state_city/country_state_city.dart'
    as csc; // Alias to avoid conflict
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/widgets/custom_snackbar.dart';

class SelectStateController extends ChangeNotifier {
  bool _isLoading = false;
  final storage = const FlutterSecureStorage();
  late SharedPreferences prefs;
  TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  int? _selectedRadioValue;
  List<csc.State> states = []; // Aliased to avoid conflict
  List<csc.State> _filteredStates = [];
  String _selectedState = '';
  String _selectedStateIsoCode = '';

  final String countryIsoCode;

  SelectStateController({required this.countryIsoCode}) {
    initialize();
  }

//public getters
  bool get isLoading => _isLoading;
  String get selectedState => _selectedState;
  List<csc.State> get filteredStates => _filteredStates;
  String get selectedStateIsoCode => _selectedStateIsoCode;
  int? get selectedRadioValue => _selectedRadioValue;

  TextEditingController get searchController => _searchController;
  FocusNode get searchFocusNode => _searchFocusNode;

  void setSelectedRadioValue(int? value) {
    _selectedRadioValue = value;
    notifyListeners();
  }

  void setSelectedState(String value) {
    _selectedState = value;
    notifyListeners();
  }

  void setSelectedStateIsoCode(String value) {
    _selectedStateIsoCode = value;
    notifyListeners();
  }

  void initialize() {
    _initializePrefs();
    fetchStates();
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> fetchStates() async {
    try {
      _isLoading = true;
      notifyListeners();
      final fetchedStates = await csc.getStatesOfCountry(countryIsoCode);

      states = fetchedStates;
      _filteredStates = states; // Initialize filteredStates with all states
      notifyListeners();
    } catch (e) {
      CustomSnackbar.show('Error fetching states', isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterStates(String query) {
    _filteredStates = states
        .where(
            (state) => state.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }
}
