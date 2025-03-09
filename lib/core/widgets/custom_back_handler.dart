import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'custom_snackbar.dart';

class CustomBackHandler extends StatefulWidget {
  final Widget child;

  const CustomBackHandler({super.key, required this.child});

  @override
  State<CustomBackHandler> createState() => _CustomBackHandlerState();
}

class _CustomBackHandlerState extends State<CustomBackHandler> {
  DateTime? currentBackPressTime;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, dynamic result) {
        if (!didPop) {
          DateTime now = DateTime.now();
          if (currentBackPressTime == null ||
              now.difference(currentBackPressTime!) >
                  const Duration(seconds: 2)) {
            currentBackPressTime = now;
            CustomSnackbar.show(
              'Press back again to exit',
              isError: true,
            );
          } else {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }
        }
      },
      child: widget.child,
    );
  }
}
