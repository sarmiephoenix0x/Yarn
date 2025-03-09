import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:flutter/material.dart';

class SelectCityController extends ChangeNotifier {
  bool _isLoading = false;
  List<csc.City> _cities = [];
  List<csc.City> _filteredCities = [];
  TextEditingController _searchController = TextEditingController();
  csc.City? _selectedCity;

  final String countryIsoCode;
  final String stateIsoCode;

  SelectCityController(
      {required this.countryIsoCode, required this.stateIsoCode}) {
    initialize();
  }

//public getters
  bool get isLoading => _isLoading;
  csc.City? get selectedCity => _selectedCity;
  List<csc.City> get filteredCities => _filteredCities;

  TextEditingController get searchController => _searchController;

  void setSelectedCity(csc.City? value) {
    _selectedCity = value;
    notifyListeners();
  }

  void initialize() {
    fetchCities();
    _searchController.addListener(_filterCities);
  }

  Future<void> fetchCities() async {
    _isLoading = true;
    notifyListeners();
    try {
      final fetchedCities =
          await csc.getStateCities(countryIsoCode, stateIsoCode);

      _cities = fetchedCities;
      _filteredCities = fetchedCities; // Initialize the filtered list
      notifyListeners();
    } catch (e) {
      // Handle error here, for example, show a snackbar
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _filterCities() {
    String query = searchController.text.toLowerCase();

    _filteredCities = _cities.where((city) {
      return city.name.toLowerCase().contains(query);
    }).toList();
    notifyListeners();
  }
}
