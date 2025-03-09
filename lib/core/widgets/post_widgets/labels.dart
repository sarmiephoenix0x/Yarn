import 'package:flutter/material.dart' hide CarouselController;

class Labels extends StatelessWidget {
  final List<String> labels;

  const Labels({
    super.key,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Wrap(
        spacing: 8.0, // Space between chips
        runSpacing: 6.0, // Space between rows of chips
        children: labels.map((label) {
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: Colors.grey, // Use your preferred color
              borderRadius:
                  BorderRadius.circular(30), // Rounded pill-like shape
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ], // Shadow for depth
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Inter',
                color: Colors.black,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
