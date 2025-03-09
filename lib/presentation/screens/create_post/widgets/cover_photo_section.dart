import 'dart:io';

import 'package:flutter/material.dart';

class CoverPhotoSection extends StatelessWidget {
  final File? coverPhoto;
  final Future<void> Function() pickCoverPhotoMethod;

  const CoverPhotoSection({
    super.key,
    required this.coverPhoto,
    required this.pickCoverPhotoMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        onTap: pickCoverPhotoMethod,
        child: coverPhoto != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(coverPhoto!.path),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300],
                ),
                child:
                    const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
              ),
      ),
    );
  }
}
