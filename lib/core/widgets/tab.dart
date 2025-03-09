import 'package:flutter/material.dart' hide CarouselController;

class TabWidget extends StatelessWidget {
  final String name;

  const TabWidget({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(name),
      ),
    );
  }
}
