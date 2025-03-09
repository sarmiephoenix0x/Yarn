import 'package:flutter/material.dart';
import 'package:country_state_city/country_state_city.dart' as csc;

class CityTile extends StatelessWidget {
  final csc.City city;
  final csc.City? selectedCity;
  final void Function(csc.City?) setSelectedCity;

  const CityTile({
    super.key,
    required this.city,
    required this.selectedCity,
    required this.setSelectedCity,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedCity == city;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: InkWell(
        onTap: () {
          setSelectedCity(city); // Set the selected city
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF500450) : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(Icons.location_city,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                city.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16.0,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
