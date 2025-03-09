import 'package:flutter/material.dart';

class AuthLabel extends StatelessWidget {
  final String title;
  final String? fontFamily;
  final FontWeight? fontWeight;
  final bool isPaddingActive;

  const AuthLabel(
      {super.key,
      required this.title,
      this.fontFamily = 'Poppins',
      this.fontWeight,
      this.isPaddingActive = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: isPaddingActive == true ? 20.0 : 0),
      child: Text(
        title,
        textAlign: TextAlign.start,
        style: TextStyle(
          fontWeight: fontWeight,
          fontFamily: fontFamily,
          fontSize: 16.0,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
