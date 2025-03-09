import 'package:flutter/material.dart';

import 'dialogs/media_options.dart';

class BottomOptions extends StatelessWidget {
  final bool isLoading;
  final BuildContext context;
  final Future<void> Function(BuildContext) publishPostMethod;
  final Future<void> Function() pickImage;
  final Future<void> Function() pickVideo;

  const BottomOptions({
    super.key,
    required this.isLoading,
    required this.publishPostMethod,
    required this.pickImage,
    required this.pickVideo,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(Icons.add), // Plus or Pin icon
            onPressed: () {
              showMediaOptions(context, pickImage, pickVideo);
            },
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: () {
              if (isLoading) {
                null;
              } else {
                publishPostMethod(context);
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              backgroundColor: const Color(0xFF500450),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : const Text('Yarn',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
