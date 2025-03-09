import 'package:flutter/material.dart';

class PrivacyListWidget extends StatelessWidget {
  final String title;
  final String img;
  final void Function() onTap;
  final bool isSwitch;
  final bool? value;
  final void Function(bool)? onChanged;
  final double mediaQueryVal;

  const PrivacyListWidget(
      {super.key,
      required this.title,
      required this.img,
      required this.isSwitch,
      required this.onTap,
      this.value,
      this.onChanged,
      this.mediaQueryVal = 0.05});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
      child: InkWell(
        // Use InkWell for tap functionality
        onTap: onTap,
        child: Row(
          children: [
            Image.asset(
              img,
              height: 35,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            SizedBox(width: MediaQuery.of(context).size.width * mediaQueryVal),
            Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15.0,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (isSwitch) ...[
              const Spacer(),
              Switch(
                value: value!,
                onChanged: onChanged, // Toggle the dark mode
              ),
            ]
          ],
        ),
      ),
    );
  }
}
