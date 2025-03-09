import 'dart:convert';

import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../core/widgets/custom_snackbar.dart';

class CreatePageController extends ChangeNotifier {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _pageProfilePicture;
  final ImagePicker _picker = ImagePicker();
  final storage = const FlutterSecureStorage();
  bool _isLoading = false;

//public getters
  bool get isLoading => _isLoading;
  XFile? get pageProfilePicture => _pageProfilePicture;

  TextEditingController get nameController => _nameController;
  TextEditingController get descriptionController => _descriptionController;

  // Function to pick profile picture
  Future<void> pickPageProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    _pageProfilePicture = image;
    notifyListeners();
  }

  Future<void> createPage(BuildContext context) async {
    final String name = _nameController.text.trim();
    final String description = _descriptionController.text.trim();

    if (name.isEmpty || description.isEmpty) {
      CustomSnackbar.show(
        'Please fill in both name and description.',
        isError: true,
      );
      return;
    }

    _isLoading = true; // Start loading
    notifyListeners();

    // Prepare the request
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    final uri = Uri.parse('https://yarnapi-fuu0.onrender.com/api/pages/');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..fields['name'] = name
      ..fields['description'] = description;

    // Add page profile picture if available
    if (_pageProfilePicture != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'pageProfilePicture',
        _pageProfilePicture!.path,
      ));
    }

    // Send the request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    _isLoading = false; // Stop loading after the response
    notifyListeners();

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('Page created successfully: ${responseData['message']}');
      Navigator.pop(context); // Navigate back or clear the fields
    } else {
      final errorData = json.decode(response.body);
      CustomSnackbar.show(
        'Error creating page: ${errorData['message']}',
        isError: true,
      );
    }
  }
}
