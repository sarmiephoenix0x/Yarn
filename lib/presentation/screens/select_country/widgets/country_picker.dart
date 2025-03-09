import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

void countryPicker(
    BuildContext context, void Function(Country?) setSelectedCountry) {
  showCountryPicker(
    context: context,
    showPhoneCode: false,
    onSelect: (Country country) {
      print('Selected country: ${country.displayName}');
      // Store the selected country

      setSelectedCountry(country);
    },
    countryListTheme: CountryListThemeData(
      borderRadius: BorderRadius.circular(40),
      inputDecoration: InputDecoration(
        labelText: 'Search',
        hintText: 'Start typing to search',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      // backgroundColor: const Color(0xFF500450), // Custom selection color
    ),
  );
}
