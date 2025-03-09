import 'package:flutter/material.dart';

class LabelInput extends StatelessWidget {
  final List<String> labels;
  final TextEditingController labelController;
  final void Function(String) removeLabel;
  final void Function() clearLabelController;

  const LabelInput({
    super.key,
    required this.labels,
    required this.labelController,
    required this.removeLabel,
    required this.clearLabelController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Labels',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            // Text field for label input
            Expanded(
              child: TextField(
                controller: labelController,
                decoration: InputDecoration(
                  hintText: 'Enter label',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Add button
            ElevatedButton(
              onPressed: () {
                if (labelController.text.trim().isNotEmpty) {
                  labels.add(labelController.text.trim());
                  clearLabelController();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF500450),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Display labels as chips
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: labels.map((label) {
            return Chip(
              label: Text(label),
              deleteIcon: Icon(Icons.close),
              onDeleted: () {
                removeLabel(label);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
