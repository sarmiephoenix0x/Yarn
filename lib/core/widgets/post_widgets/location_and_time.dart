import 'package:flutter/material.dart';

class LocationAndTime extends StatelessWidget {
  final String location;
  final String time;

  const LocationAndTime({
    super.key,
    required this.location,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          location,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 10),
        Row(
          children: [
            Image.asset("images/TimeStampImg.png", height: 20),
            SizedBox(width: 5),
            Text(
              time,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
