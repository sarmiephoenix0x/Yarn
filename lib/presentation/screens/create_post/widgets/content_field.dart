import 'package:flutter/material.dart';

class ContentField extends StatelessWidget {
  final TextEditingController textController;

  const ContentField({
    super.key,
    required this.textController,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      maxLines: null,
      decoration: InputDecoration(
        hintText: 'What do you want to yarn about?...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.all(12),
      ),
    );
  }
}
