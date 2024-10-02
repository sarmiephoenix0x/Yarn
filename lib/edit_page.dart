import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:dio/dio.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final Dio _dio = Dio();

  String? _selectedCountry;
  String? _selectedState;
  List<csc.State> _states = [];
  List<csc.Country> _countries = [];

  String? _firstName, _email, _surname, _gender, _dateOfBirth, _phone;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  // For automatic state and country detection
  Position? _position;
  String? _detectedCountry;
  String? _detectedState;
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _getLocation();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    List<csc.Country> countries = await csc.getAllCountries();
    setState(() {
      _countries = countries; // Assign the fetched countries to the state variable
    });
  }



  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return;
      }
    }

    _position = await Geolocator.getCurrentPosition();
    _getAddressFromLatLng(_position!);
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        setState(() async{
          _detectedCountry = placemarks.first.country;
          _detectedState = placemarks.first.administrativeArea;
          _selectedCountry = _detectedCountry;
          _states = await csc.getStatesOfCountry(_selectedCountry!); // Use csc for states
          _selectedState = _detectedState;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final String? accessToken = await storage.read(key: 'yarnAccessToken');
        Response response = await _dio.patch(
          'https://yarnapi.onrender.com/api/users/personal-info',
          data: {
            "firstName": _firstName,
            "surname": _surname,
            "email": _email,
            "state": _selectedState,
            "country": _selectedCountry,
            "gender": _gender,
            "dateOfBirth": _dateOfBirth,
            "phone": _phone,
          },
          options: Options(headers: {
            'Authorization': 'Bearer $accessToken',
          }),
        );
        print(response.data);
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _updateProfilePicture() async {
    if (_imagePath != null) {
      try {
        final String? accessToken = await storage.read(key: 'yarnAccessToken');
        FormData formData = FormData.fromMap({
          "file": await MultipartFile.fromFile(_imagePath!),
        });
        Response response = await _dio.patch(
          'https://yarnapi.onrender.com/api/users/update-profile-picture',
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              "Content-Type": "multipart/form-data",
            },
          ),
        );
        print(response.data);
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _selectImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      final decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());

      if (decodedImage.width > 800 || decodedImage.height > 800) {
        CroppedFile? croppedImage = await ImageCropper().cropImage(
          sourcePath: imageFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.black,
              toolbarWidgetColor: Colors.white,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              minimumAspectRatio: 1.0,
            ),
          ],
        );

        if (croppedImage != null) {
          setState(() {
            _imagePath = croppedImage.path; // Correct variable name
          });
        }
      } else {
        setState(() {
          _imagePath = pickedFile.path; // Correct variable name
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture section
              Center(
                child: Stack(
                  children: [
                    if (_imagePath == null || _imagePath!.isEmpty) // Check if image path is null or empty
                      ClipRRect(
                        borderRadius: BorderRadius.circular(55),
                        child: Container(
                          width: 111,
                          height: 111,
                          color: Colors.grey,
                          child: Image.asset('images/ProfileImg.png', fit: BoxFit.cover),
                        ),
                      )
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(55),
                        child: Container(
                          width: 111,
                          height: 111,
                          color: Colors.grey,
                          child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _selectImage,
                        child: Image.asset('images/EditProfileImg.png', height: 35),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.0),

              // Personal Information Fields
              TextField(
                decoration: InputDecoration(labelText: 'First Name'),
                onChanged: (value) => _firstName = value, // Correct variable name
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Surname'),
                onChanged: (value) => _surname = value, // Correct variable name
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (value) => _email = value, // Correct variable name
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Phone'),
                onChanged: (value) => _phone = value, // Correct variable name
              ),

              // Country Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Country'),
                value: _selectedCountry,
                items: _countries.map((csc.Country country) {
                  return DropdownMenuItem<String>(
                    value: country.name,
                    child: Text(country.name),
                  );
                }).toList(),
                onChanged: (value) async {
                  setState(() {
                    _selectedCountry = value;
                    _states = []; // Reset states when country changes
                    _selectedState = null; // Reset selected state
                  });
                  if (_selectedCountry != null) {
                    // Fetch states for the selected country
                    List<csc.State> states = await csc.getStatesOfCountry(_selectedCountry!);
                    setState(() {
                      _states = states;
                    });
                  }
                },
              ),
              SizedBox(height: 16),

              // State Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'State'),
                value: _selectedState,
                items:  _states.map((csc.State state) {
                  return DropdownMenuItem<String>(
                    value: state.name,
                    child: Text(state.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedState = value;
                  });
                },
              ),

              // Gender Dropdown
              DropdownButton<String>(
                value: _gender, // Correct variable name
                onChanged: (String? newValue) {
                  setState(() {
                    _gender = newValue; // Correct variable name
                  });
                },
                items: ['Male', 'Female', 'Other']
                    .map((value) => DropdownMenuItem(
                  value: value,
                  child: Text(value),
                ))
                    .toList(),
              ),

              // Date of Birth Field
              TextField(
                decoration: InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)'),
                onChanged: (value) => _dateOfBirth = value, // Correct variable name
              ),

              SizedBox(height: 16.0),

              // Submit Button
              ElevatedButton(
                onPressed: () async {
                  await _updateProfile();
                  await _updateProfilePicture();
                },
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
