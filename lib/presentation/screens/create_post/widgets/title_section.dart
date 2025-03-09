import 'package:flutter/material.dart';

class TitleSection extends StatelessWidget {
  final TextEditingController titleController;

  const TitleSection({
    super.key,
    required this.titleController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter yarn title...',
            hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
