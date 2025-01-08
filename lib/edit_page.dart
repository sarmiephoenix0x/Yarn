import 'dart:async';
import 'dart:io';

import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class EditProfilePage extends StatefulWidget {
  final String profileImgUrl;
  const EditProfilePage({
    super.key,
    required this.profileImgUrl,
  });

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final Dio _dio = Dio();

  String? _selectedCountryIsoCode;
  String? _selectedCountry;
  String? _selectedStateIsoCode;
  String? _selectedState;
  String? _selectedCity;
  List<csc.City> _cities = [];
  List<csc.State> _states = [];
  List<csc.Country> _countries = [];

  String? _username,
      _firstName,
      _email,
      _surname,
      _gender,
      _dateOfBirth,
      _phone;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  bool _isLoadingCountry = true; // Loading indicator for country
  bool _isLoadingState = true; // Loading indicator for state
  bool _isLoadingCity = true;

  // For automatic state and country detection
  Position? _position;
  String? _detectedCountry;
  String? _detectedState;
  String? _detectedCity;
  final storage = const FlutterSecureStorage();
  final FocusNode _dobFocusNode = FocusNode();
  final TextEditingController dobController = TextEditingController();
  bool _isLoading = false;
  bool _isProfileImageUpdateOnly = false;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.profileImgUrl;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getLocation(context);
    });
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    if (mounted) {
      setState(() {
        _isLoadingCountry = true; // Start loading
      });
    }

    // Fetch all countries including ISO codes
    List<csc.Country> countries = await csc.getAllCountries();

    if (mounted) {
      setState(() {
        _countries = countries; // Assign countries with ISO codes
        _isLoadingCountry = false; // Stop loading
      });
    }
  }

  Future<void> _getLocation(BuildContext context) async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Show a dialog to inform the user about the need for location services
      _showLocationDialog(context, "Location Required",
          "This app requires location access to provide accurate information and a better experience. Please enable location services in your settings.");
      return;
    }

    // Check and request location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Request permission if it's denied
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Show a dialog if permission is not granted
        _showLocationDialog(context, "Location Permission Needed",
            "This app requires location permissions to function correctly. Please allow access in your settings.");
        return;
      }
    }

    // Retrieve the current position
    Position _position = await Geolocator.getCurrentPosition();

    // Fetch address from coordinates if _position is not null
    if (_position != null) {
      await _getAddressFromLatLng(_position);
    }
  }

// Function to show a professional dialog
  void _showLocationDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openAppSettings(); // Open app settings
              },
              child: Text("Settings", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // Detected country, state, and city
        _detectedCountry = place.country;
        _detectedState = place.administrativeArea;
        _detectedCity = place.locality;

        print(
            'Detected country: $_detectedCountry, state: $_detectedState, city: $_detectedCity');

        if (_detectedCountry != null) {
          // Ensure countries list is populated
          if (_countries.isNotEmpty) {
            csc.Country? detectedCountry = _countries.firstWhere(
                (country) => country.name == _detectedCountry,
                orElse: () => csc.Country(
                    name: '',
                    isoCode: '',
                    phoneCode: '',
                    flag: '',
                    currency: '',
                    latitude: '',
                    longitude: ''));

            if (detectedCountry.name.isNotEmpty) {
              _selectedCountryIsoCode = detectedCountry.isoCode;
              _selectedCountry = detectedCountry.name;

              if (_selectedCountryIsoCode != null) {
                print('Fetching states for: $_selectedCountry');
                await _fetchStates(_selectedCountryIsoCode!);
                print('Done fetching states');
              } else {
                print('No valid ISO code for the detected country.');
              }
            } else {
              print('Detected country not found in the list.');
            }
          } else {
            print('Countries list is empty.');
          }
        }

        if (_detectedState != null) {
          // Ensure states list is populated
          if (_states.isNotEmpty) {
            csc.State? detectedState = _states.firstWhere(
                (state) =>
                    state.name.toLowerCase() == _detectedState!.toLowerCase(),
                orElse: () => csc.State(
                    name: '',
                    isoCode: '',
                    countryCode: '',
                    latitude: '',
                    longitude: ''));

            if (detectedState.name.isNotEmpty) {
              _selectedStateIsoCode = detectedState.isoCode;
              _selectedState = detectedState.name;

              if (_selectedStateIsoCode != null &&
                  _selectedCountryIsoCode != null) {
                print(
                    'Fetching cities for state: $_selectedState and country: $_selectedCountry');
                await _fetchCities(
                    _selectedStateIsoCode!, _selectedCountryIsoCode!);
              } else {
                print('State or Country ISO code is null.');
              }
            } else {
              print('Detected state not found in the list.');
            }
          } else {
            print('States list is empty.');
          }
        } else {
          print('No state detected.');
        }
      } else {
        print('No placemarks found.');
      }
    } catch (e) {
      print('Error in _getAddressFromLatLng: $e');
    }
  }

  Future<void> _fetchStates(String countryIsoCode) async {
    setState(() {
      _isLoadingState = true; // Start loading states
    });

    // Fetch states for the selected country
    List<csc.State> states = await csc.getStatesOfCountry(countryIsoCode);

    // Debug: Print the fetched states
    print('Fetched states: ${states.map((state) => state.name).toList()}');

    if (_detectedState != null) {
      csc.State? detectedState = states.firstWhere(
          (state) =>
              state.name.trim().toLowerCase() ==
                  _detectedState!.trim().toLowerCase() ||
              state.name.trim().toLowerCase() ==
                  '${_detectedState!.trim()} State'.toLowerCase(),
          orElse: () => csc.State(
              name: '',
              isoCode: '',
              countryCode: '',
              latitude: '',
              longitude: ''));

      if (detectedState.name.isNotEmpty) {
        setState(() {
          _states = states;
          _selectedStateIsoCode = detectedState.isoCode;
          _selectedState = detectedState.name;
          _isLoadingState = false;
        });
        await _fetchCities(_selectedStateIsoCode!, _selectedCountryIsoCode!);
      } else {
        print('Detected state not found in the list.');
      }
    } else {
      print('No states found for country $countryIsoCode');
      setState(() {
        _states = []; // Clear the list if no states are found
        _isLoadingState = false;
      });
    }
  }

  Future<void> _fetchCities(String stateIsoCode, String countryIsoCode) async {
    if (stateIsoCode.isEmpty || countryIsoCode.isEmpty) {
      print(
          'Invalid state or country ISO code. State: $stateIsoCode, Country: $countryIsoCode');
      return; // Ensure valid state and country codes
    }

    print(
        'Fetching cities for countryIsoCode: $countryIsoCode and stateIsoCode: $stateIsoCode');

    setState(() {
      _isLoadingCity = true; // Start loading cities
    });

    try {
      // Fetch the cities based on the selected state and country
      List<csc.City> cities =
          await csc.getStateCities(countryIsoCode, stateIsoCode);
      print(cities);
      setState(() {
        _cities = cities;
        _selectedCity = _detectedCity;

        // Automatically set the city based on geolocation
        if (_detectedCity != null) {
          var detectedCity = _cities.firstWhere(
              (city) => city.name.toLowerCase() == _detectedCity!.toLowerCase(),
              orElse: () => csc.City(name: '', stateCode: '', countryCode: ''));

          if (detectedCity.name.isNotEmpty) {
            _selectedCity = detectedCity.name; // Set the detected city if found
          } else {
            print('Detected city not found.');
          }
        }

        _isLoadingCity = false; // Stop loading
      });
    } catch (e) {
      setState(() {
        _isLoadingCity = false; // Stop loading on error
      });
      print('Error fetching cities: $e');
    }
  }

  Future<void> _updateProfile() async {
    try {
      setState(() {
        _isLoading = true; // Start loading
      });
      // _showCustomSnackBar(context, '$_username$_firstName$_surname$_email$_selectedCity$_selectedState$_selectedCountry$_gender${dobController.text.trim()}$_phone',
      //     isError: true);
      print(
          '$_username$_firstName$_surname$_email$_selectedCity$_selectedState$_selectedCountry$_gender${dobController.text.trim()}$_phone');
      final String? accessToken = await storage.read(key: 'yarnAccessToken');

      Response response = await _dio.patch(
        'https://yarnapi-fuu0.onrender.com/api/users/personal-info',
        // data: {
        //   "firstName": _firstName,
        //   "surname": _surname,
        //   "username": "Phil",
        //   "email": _email,
        //   "city": "Lokoja",
        //   "state": "Kogi",
        //   "country": "Nigeria",
        //   "gender": _gender,
        //   "dateOfBirth": dobController.text.trim(),
        //   "phone": _phone,
        // },
        data: {
          "username": _username,
          "firstName": _firstName,
          "surname": _surname,
          "email": _email,
          "city": _selectedCity,
          "state": _selectedState,
          "country": _selectedCountry,
          "gender": _gender,
          "dateOfBirth": dobController.text.trim(),
          "phone": _phone,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
        }),
      );

      // Log the server response body
      print('Server Response: ${response.data}'); // Log the response body
      // _showCustomSnackBar(context, 'Server Response: ${response.data}',
      //     isError: true);

      // Handle response status codes
      if (response.statusCode == 200) {
        _showCustomSnackBar(context, 'Profile updated successfully!',
            isError: false);
      } else if (response.statusCode == 400) {
        // Extracting validation errors from response
        final Map<String, dynamic> errors = response.data['errors'] ?? {};
        // Show error messages for each invalid field
        errors.forEach((key, value) {
          _showCustomSnackBar(context, '$key: $value', isError: true);
        });
      } else {
        _showCustomSnackBar(
            context, 'Failed to update profile! Unexpected error.',
            isError: true);
      }
    } on DioError catch (e) {
      // Check if there's a response from the server
      if (e.response != null) {
        // Log and show the server response error
        print('Error Response: ${e.response?.data}');
      } else {
        // Log and show a general error message
        print('Error: ${e.message}');
        _showCustomSnackBar(context, 'Failed to update profile! ${e.message}',
            isError: true);
      }
    } catch (e) {
      // Handle any other errors
      _showCustomSnackBar(context, 'Failed to update profile!', isError: true);
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfilePicture() async {
    if (_imagePath != null) {
      try {
        setState(() {
          _isLoading = true; // Start loading
        });
        final String? accessToken = await storage.read(key: 'yarnAccessToken');
        FormData formData = FormData.fromMap({
          "file": await MultipartFile.fromFile(_imagePath!),
        });
        Response response = await _dio.patch(
          'https://yarnapi-fuu0.onrender.com/api/users/update-profile-picture',
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              "Content-Type": "multipart/form-data",
            },
          ),
        );
        setState(() {
          _isLoading = false; // Start loading
        });
        _showCustomSnackBar(context, 'Profile picture updated successfully!');
      } catch (e) {
        setState(() {
          _isLoading = false; // Start loading
        });
        _showCustomSnackBar(context, 'Failed to update profile picture!',
            isError: true);
        print(e);
      }
    }
  }

  Future<void> _selectImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      final decodedImage =
          await decodeImageFromList(imageFile.readAsBytesSync());

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

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  void dispose() {
    _dobFocusNode.dispose(); // Dispose focus node
    dobController.dispose(); // Dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture section
              Center(
                child: Stack(
                  children: [
                    if (_imagePath == null ||
                        _imagePath!
                            .isEmpty) // Check if image path is null or empty
                      ClipRRect(
                        borderRadius: BorderRadius.circular(55),
                        child: Container(
                          width: 111,
                          height: 111,
                          color: Colors.grey,
                          child: Image.asset('images/ProfileImg.png',
                              fit: BoxFit.cover),
                        ),
                      )
                    else if (_imagePath!.startsWith('http'))
                      ClipRRect(
                        borderRadius: BorderRadius.circular(55),
                        child: Container(
                          width: 111,
                          height: 111,
                          color: Colors.grey,
                          child: Image.network(
                            _imagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons
                                  .error); // Show an error icon if image fails to load
                            },
                          ),
                        ),
                      )
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(55),
                        child: Container(
                          width: 111,
                          height: 111,
                          color: Colors.grey,
                          child:
                              Image.file(File(_imagePath!), fit: BoxFit.cover),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _selectImage,
                        child: Image.asset('images/EditProfileImg.png',
                            height: 35),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                  height: (16.0 / MediaQuery.of(context).size.height) *
                      MediaQuery.of(context).size.height),

              // Personal Information Fields
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                onChanged: (value) => _username = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username cannot be empty';
                  }
                  return null; // Return null if valid
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'First Name'),
                onChanged: (value) => _firstName = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'First name cannot be empty';
                  }
                  return null; // Return null if valid
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Surname'),
                onChanged: (value) => _surname = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Surname cannot be empty';
                  }
                  return null; // Return null if valid
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (value) => _email = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email cannot be empty';
                  }
                  // Add regex for email validation if needed
                  return null; // Return null if valid
                },
              ),
              SizedBox(
                  height: (16.0 / MediaQuery.of(context).size.height) *
                      MediaQuery.of(context).size.height),
              IntlPhoneField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  counterText: '',
                ),
                initialCountryCode: 'NG',
                onChanged: (phone) {
                  setState(() {
                    _phone = phone.completeNumber;
                  });
                },
                validator: (value) {
                  if (value == null || value.completeNumber.isEmpty) {
                    return 'Phone number cannot be empty';
                  }
                  return null; // Return null if valid
                },
              ),
              // Add bottom divider
              Container(
                height: 1,
                color: Theme.of(context).dividerColor,
                margin: const EdgeInsets.only(top: 8.0),
              ),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Country'),
                value: _isLoadingCountry ? null : _selectedCountryIsoCode,
                items: _isLoadingCountry
                    ? null
                    : _countries.map((csc.Country country) {
                        return DropdownMenuItem<String>(
                          value: country.isoCode,
                          child: Text(country.name),
                        );
                      }).toList(),
                onChanged: (value) async {
                  setState(() {
                    _selectedCountryIsoCode = value;
                    _states = [];
                    _selectedState = null;
                  });
                  if (_selectedCountryIsoCode != null) {
                    await _fetchStates(_selectedCountryIsoCode!);
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a country';
                  }
                  return null; // Return null if valid
                },
                hint: _isLoadingCountry ? const Text('Loading...') : null,
              ),
              SizedBox(
                  height: (16.0 / MediaQuery.of(context).size.height) *
                      MediaQuery.of(context).size.height),
              PopupMenuButton<String>(
                onSelected: (String value) async {
                  // Find the selected state based on the ISO code
                  csc.State? selectedState = _states.firstWhere(
                      (state) => state.isoCode == value,
                      orElse: () => csc.State(
                          name: '',
                          isoCode: '',
                          latitude: '',
                          longitude: '',
                          countryCode: ''));

                  if (selectedState != null) {
                    setState(() {
                      _selectedStateIsoCode =
                          value; // Update selected state ISO code
                      _selectedState =
                          selectedState.name; // Update selected state name
                      _cities = [];
                      _selectedCity = null; // Reset city
                    });

                    // Fetch cities after state is selected
                    if (_selectedStateIsoCode != null) {
                      await _fetchCities(
                          _selectedStateIsoCode!, _selectedCountryIsoCode!);
                    }
                  }
                },
                itemBuilder: (BuildContext context) {
                  return _isLoadingState
                      ? [
                          const PopupMenuItem<String>(
                            enabled: false, // Disable selection while loading
                            child: Center(
                                child:
                                    CircularProgressIndicator()), // Show loading spinner
                          )
                        ]
                      : _states.map((csc.State state) {
                          return PopupMenuItem<String>(
                            value: state.isoCode,
                            child: Text(
                              state.name == _selectedState
                                  ? '${state.name} (Detected)' // Show detected alias
                                  : state.name, // Normal state name
                            ),
                          );
                        }).toList();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15.0, horizontal: 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                    border: Border(
                        bottom:
                            BorderSide(color: Theme.of(context).dividerColor)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isLoadingState
                            ? 'Loading...'
                            : (_selectedState ?? 'Select a state'),
                        style: const TextStyle(
                          fontSize: 16.0, // Font size
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),

              // City Dropdown
              SizedBox(
                  height: (16.0 / MediaQuery.of(context).size.height) *
                      MediaQuery.of(context).size.height),
              PopupMenuButton<String>(
                onSelected: (String value) {
                  setState(() {
                    _selectedCity = value; // Update selected city
                  });
                },
                itemBuilder: (BuildContext context) {
                  return _isLoadingCity
                      ? [
                          const PopupMenuItem<String>(
                            enabled: false, // Disable selection while loading
                            child: Center(
                                child:
                                    CircularProgressIndicator()), // Show loading spinner
                          )
                        ]
                      : _cities.map((csc.City city) {
                          return PopupMenuItem<String>(
                            value: city.name,
                            child: Text(
                              city.name == _selectedCity
                                  ? '${city.name} (Detected)' // Show detected alias
                                  : city.name, // Normal city name
                            ),
                          );
                        }).toList();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15.0, horizontal: 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                    border: Border(
                        bottom:
                            BorderSide(color: Theme.of(context).dividerColor)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isLoadingCity
                            ? 'Loading...'
                            : (_selectedCity ?? 'Select a city'),
                        style: const TextStyle(
                          fontSize: 16.0, // Font size
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              SizedBox(
                  height: (16.0 / MediaQuery.of(context).size.height) *
                      MediaQuery.of(context).size.height),
              // Gender Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Gender'),
                value: _gender,
                hint: const Text('Select Gender'),
                onChanged: (String? newValue) {
                  setState(() {
                    _gender = newValue;
                  });
                },
                items: ['Male', 'Female', 'Other'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a gender';
                  }
                  return null; // Return null if valid
                },
              ),

              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      dobController.text = _formatDate(picked);
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: dobController,
                    decoration: const InputDecoration(
                        labelText: 'Date of Birth (DD/MM/YYYY)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Date of birth cannot be empty';
                      }
                      // You can add date format validation if needed
                      return null; // Return null if valid
                    },
                  ),
                ),
              ),

              SizedBox(
                  height: (16.0 / MediaQuery.of(context).size.height) *
                      MediaQuery.of(context).size.height),

              Container(
                width: double.infinity,
                height: (60 / MediaQuery.of(context).size.height) *
                    MediaQuery.of(context).size.height,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_imagePath != null && _imagePath!.isNotEmpty) {
                      // If user selects an image, update only the profile image
                      setState(() {
                        _isProfileImageUpdateOnly = true;
                      });
                    } else {
                      setState(() {
                        _isProfileImageUpdateOnly = false;
                      });
                    }

                    // If user is updating only the profile image, skip form validation
                    if (_isProfileImageUpdateOnly) {
                      await _updateProfilePicture(); // Update profile picture only
                      if (_formKey.currentState!.validate()) {
                        await _updateProfile();
                      }
                    } else {
                      // Validate the form and update the whole profile if valid
                      if (_formKey.currentState!.validate()) {
                        await _updateProfile(); // Update full profile
                        if (_imagePath != null && _imagePath!.isNotEmpty) {
                          await _updateProfilePicture(); // Also update profile picture if changed
                        }
                      }
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.pressed)) {
                          return Colors.white;
                        }
                        return const Color(0xFF500450);
                      },
                    ),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.pressed)) {
                          return const Color(0xFF500450);
                        }
                        return Colors.white;
                      },
                    ),
                    elevation: WidgetStateProperty.all<double>(4.0),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(35)),
                      ),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Update Profile',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
