import 'package:flutter/material.dart';
import 'package:country_state_city/country_state_city.dart' as csc;

class LocationSection extends StatelessWidget {
  final String? selectedCity;
  final bool isLoadingCity;
  final List<csc.City> cities;
  final void Function(String) setSelectedCity;

  const LocationSection({
    super.key,
    this.selectedCity,
    required this.isLoadingCity,
    required this.cities,
    required this.setSelectedCity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      child: PopupMenuButton<String>(
        onSelected: (String value) {
          setSelectedCity(value);
        },
        itemBuilder: (BuildContext context) {
          return isLoadingCity
              ? [
                  const PopupMenuItem<String>(
                    enabled: false, // Disable selection while loading
                    child: Center(
                        child:
                            CircularProgressIndicator()), // Show loading spinner
                  )
                ]
              : cities.map((csc.City city) {
                  return PopupMenuItem<String>(
                    value: city.name,
                    child: Text(
                      city.name == selectedCity
                          ? '${city.name} (Detected)' // Show detected alias
                          : city.name, // Normal city name
                    ),
                  );
                }).toList();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isLoadingCity
                    ? 'Loading location...'
                    : (selectedCity ?? 'Select a city'),
                style: const TextStyle(
                  fontSize: 16.0, // Font size
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
