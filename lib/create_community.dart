import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;


class CreateCommunity extends StatefulWidget {
  const CreateCommunity({super.key});

  @override
  CreateCommunityState createState() => CreateCommunityState();
}

class CreateCommunityState extends State<CreateCommunity> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _communityProfilePicture;
  final ImagePicker _picker = ImagePicker();
  final storage = const FlutterSecureStorage();
  bool _isLoading = false;

  Future<void> _pickProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _communityProfilePicture = image;
    });
  }

  Future<void> _createCommunity() async {
    final String name = _nameController.text.trim();
    final String description = _descriptionController.text.trim();

    if (name.isEmpty || description.isEmpty) {
      _showCustomSnackBar(
        context,
        'Please fill in both name and description.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });

    // Prepare the request
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final uri = Uri.parse('https://yarnapi.onrender.com/api/communities/');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..fields['name'] = name
      ..fields['description'] = description;

    // Add page profile picture if available
    if (_communityProfilePicture != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'communityProfilePicture',
        _communityProfilePicture!.path,
      ));
    }

    // Send the request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    setState(() {
      _isLoading = false; // Stop loading after the response
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('Community created successfully: ${responseData['message']}');
      Navigator.pop(context); // Navigate back or clear the fields
    } else {
      final errorData = json.decode(response.body);
      _showCustomSnackBar(
        context,
        'Error creating page: ${errorData['message']}',
        isError: true,
      );
    }
  }

  void _showCustomSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Community')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Community Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(hintText: 'Community Description'),
            ),
            // Profile Picture Section
            GestureDetector(
              onTap: _pickProfilePicture,
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _communityProfilePicture != null
                    ? Image.file(File(_communityProfilePicture!.path), fit: BoxFit.cover)
                    : const Center(child: Text('Tap to select profile picture')),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _createCommunity,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : const Text('Create Community'),
            ),
          ],
        ),
      ),
    );
  }
}
