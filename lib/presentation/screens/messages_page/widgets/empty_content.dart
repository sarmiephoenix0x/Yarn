import 'package:flutter/material.dart';

class EmptyContent extends StatelessWidget {
  final BuildContext context;

  const EmptyContent({
    super.key,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.article_outlined, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No recent chats.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
