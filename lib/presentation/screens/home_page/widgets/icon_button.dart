import 'package:flutter/material.dart' hide CarouselController;

class IconButtonWidget extends StatelessWidget {
  final String assetPath;
  final VoidCallback onPressed;

  const IconButtonWidget({
    super.key,
    required this.assetPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1), // Soft background
          ),
          child: Image.asset(
            assetPath,
            height: 35, // Icon size
          ),
        ),
      ),
    );
  }
}
