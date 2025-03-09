import 'package:flutter/material.dart';

class Gap extends StatelessWidget {
  final double size;
  final bool isHorizontal;
  final bool useMediaQuery;

  const Gap(
    this.size, {
    super.key,
    this.isHorizontal = false,
    this.useMediaQuery = true, // ✅ Default: Use MediaQuery for responsiveness
  });

  @override
  Widget build(BuildContext context) {
    double convertedSize = useMediaQuery ? _convertToMediaQuery(context) : size;

    return SizedBox(
      width: isHorizontal ? convertedSize : 0,
      height: isHorizontal ? 0 : convertedSize,
    );
  }

  // ✅ Convert fixed size to MediaQuery-based value (Fully dynamic for width & height)
  double _convertToMediaQuery(BuildContext context) {
    double screenSize = isHorizontal
        ? MediaQuery.of(context).size.width // ✅ Use width for horizontal gaps
        : MediaQuery.of(context).size.height; // ✅ Use height for vertical gaps
    return size *
        (screenSize /
            (isHorizontal
                ? MediaQuery.of(context).size.width
                : MediaQuery.of(context).size.height));
  }

  // ✅ Convert MediaQuery value back to fixed size (Correct for both directions)
  static double toFixedSize(BuildContext context, double mediaQueryValue,
      {bool isHorizontal = false}) {
    double screenSize = isHorizontal
        ? MediaQuery.of(context)
            .size
            .width // ✅ Use width when converting horizontal gaps
        : MediaQuery.of(context)
            .size
            .height; // ✅ Use height when converting vertical gaps
    return mediaQueryValue /
        (screenSize /
            (isHorizontal
                ? MediaQuery.of(context).size.width
                : MediaQuery.of(context).size.height));
  }
}
