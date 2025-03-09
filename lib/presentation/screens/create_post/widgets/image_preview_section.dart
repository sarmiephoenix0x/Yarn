import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePreviewSection extends StatelessWidget {
  final List<XFile>? selectedImages;
  final List<XFile>? selectedVideos;
  final void Function(XFile) removeVideoMethod;

  const ImagePreviewSection({
    super.key,
    required this.selectedImages,
    required this.selectedVideos,
    required this.removeVideoMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Display images
        ...selectedImages!.map((image) {
          return Stack(
            children: [
              // Thumbnail of selected image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(image.path),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              // Remove button for each image
              Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: () => removeVideoMethod(image),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          );
        }).toList(),

        // Display videos as thumbnails
        ...selectedVideos!.map((video) {
          return Stack(
            children: [
              // Video thumbnail or icon (you can use a video thumbnail library or just show an icon)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.videocam, size: 50, color: Colors.red),
              ),
              // Remove button for each video
              Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: () => removeVideoMethod(video),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }
}
