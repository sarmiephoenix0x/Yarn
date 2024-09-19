import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart'; // for picking images

class CreateNews extends StatefulWidget {
  const CreateNews({super.key});

  @override
  CreateNewsState createState() => CreateNewsState();
}

class CreateNewsState extends State<CreateNews> {
  QuillController _controller = QuillController.basic();
  XFile? _coverPhoto;
  final ImagePicker _picker = ImagePicker();

  // Function to pick a cover photo
  Future<void> _pickCoverPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _coverPhoto = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
        actions: [
          // Publish button
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              // Handle post submission
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Cover Photo Section
            GestureDetector(
              onTap: _pickCoverPhoto,
              child: _coverPhoto != null
                  ? Image.file(
                File(_coverPhoto!.path),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: Icon(
                  Icons.add_a_photo,
                  size: 50,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Text Editor
            Expanded(
              child: Column(
                children: [
                  // Toolbar for text formatting
                  QuillSimpleToolbar(
                    controller: _controller,
                    configurations: const QuillSimpleToolbarConfigurations(),
                  ),
                  const SizedBox(height: 10),
                  // Quill Editor
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: QuillEditor.basic(
                        controller: _controller,
                        configurations: const QuillEditorConfigurations(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Icons before Publish Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.photo_library),
                  onPressed: () {
                    // Handle photo attachment
                  },
                ),
                IconButton(
                  icon: Icon(Icons.format_size),
                  onPressed: () {
                    // Handle text capitalization (optional functionality)
                  },
                ),
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    // Handle more options
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
