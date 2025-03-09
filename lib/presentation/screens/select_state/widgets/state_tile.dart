import 'package:flutter/material.dart';
import 'package:country_state_city/country_state_city.dart' as csc;

class StateTile extends StatelessWidget {
  final csc.State state;
  final int value;
  final int? selectedRadioValue;
  final void Function(int) setSelectedRadioValue;
  final void Function(String) setSelectedState;
  final void Function(String) setSelectedStateIsoCode;

  const StateTile({
    super.key,
    required this.state,
    required this.value,
    required this.selectedRadioValue,
    required this.setSelectedRadioValue,
    required this.setSelectedState,
    required this.setSelectedStateIsoCode,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedRadioValue == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: InkWell(
        onTap: () {
          setSelectedRadioValue(value);
          setSelectedState(state.name);
          setSelectedStateIsoCode(state.isoCode);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF500450) : Colors.transparent,
          ),
          child: Row(
            children: [
              Text(
                state.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15.0,
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
