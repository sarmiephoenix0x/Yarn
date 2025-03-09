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

import '../../core/widgets/custom_snackbar.dart';
import '../../core/widgets/location_dialog.dart';

class EditPageController extends ChangeNotifier {
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
  final TextEditingController _dobController = TextEditingController();
  bool _isLoading = false;
  bool _isProfileImageUpdateOnly = false;

  final BuildContext editContext;
  final String profileImgUrl;

  EditPageController({required this.editContext, required this.profileImgUrl}) {
    initialize();
  }

//public getters
  bool get isLoading => _isLoading;
  bool get isLoadingState => _isLoadingState;
  GlobalKey<FormState> get formKey => _formKey;
  String? get imagePath => _imagePath;
  String? get username => _username;
  String? get firstName => _firstName;
  String? get surname => _surname;
  String? get email => _email;
  String? get phone => _phone;
  bool get isLoadingCountry => _isLoadingCountry;
  List<csc.Country> get countries => _countries;
  String? get selectedCountryIsoCode => _selectedCountryIsoCode;
  List<csc.State> get states => _states;
  String? get selectedState => _selectedState;
  List<csc.City> get cities => _cities;
  String? get selectedCity => _selectedCity;
  String? get selectedStateIsoCode => _selectedStateIsoCode;
  bool get isLoadingCity => _isLoadingCity;
  String? get gender => _gender;
  bool get isProfileImageUpdateOnly => _isProfileImageUpdateOnly;

  TextEditingController get dobController => _dobController;

  void setUsername(String value) {
    _username = value;
    notifyListeners();
  }

  void setFirstName(String value) {
    _firstName = value;
    notifyListeners();
  }

  void setSurname(String value) {
    _surname = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setPhone(String value) {
    _phone = value;
    notifyListeners();
  }

  void setGender(String value) {
    _gender = value;
    notifyListeners();
  }

  void setDobController(String value) {
    _dobController.text = value;
    notifyListeners();
  }

  void setSelectedCountryIsoCode(String value) {
    _selectedCountryIsoCode = value;
    notifyListeners();
  }

  void setStates(List<csc.State> value) {
    _states = value;
    notifyListeners();
  }

  void setSelectedState(String? value) {
    _selectedState = value;
    notifyListeners();
  }

  void setSelectedStateIsoCode(String value) {
    _selectedStateIsoCode = value;
    notifyListeners();
  }

  void setCities(List<csc.City> value) {
    _cities = value;
    notifyListeners();
  }

  void setSelectedCity(String? value) {
    _selectedCity = value;
    notifyListeners();
  }

  void setIsProfileImageUpdateOnly(bool value) {
    _isProfileImageUpdateOnly = value;
    notifyListeners();
  }

  void initialize() {
    _imagePath = profileImgUrl;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getLocation(editContext);
    });
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    _isLoadingCountry = true; // Start loading
    notifyListeners();

    // Fetch all countries including ISO codes
    List<csc.Country> countries = await csc.getAllCountries();

    _countries = countries; // Assign countries with ISO codes
    _isLoadingCountry = false; // Stop loading
    notifyListeners();
  }

  Future<void> _getLocation(BuildContext context) async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Show a dialog to inform the user about the need for location services
      showLocationDialog(context, "Location Required",
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
        showLocationDialog(context, "Location Permission Needed",
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
                await fetchStates(_selectedCountryIsoCode!);
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
                await fetchCities(
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

  Future<void> fetchStates(String countryIsoCode) async {
    _isLoadingState = true; // Start loading states
    notifyListeners();

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
        _states = states;
        _selectedStateIsoCode = detectedState.isoCode;
        _selectedState = detectedState.name;
        _isLoadingState = false;
        notifyListeners();
        await fetchCities(_selectedStateIsoCode!, _selectedCountryIsoCode!);
      } else {
        print('Detected state not found in the list.');
      }
    } else {
      print('No states found for country $countryIsoCode');

      _states = []; // Clear the list if no states are found
      _isLoadingState = false;
      notifyListeners();
    }
  }

  Future<void> fetchCities(String stateIsoCode, String countryIsoCode) async {
    if (stateIsoCode.isEmpty || countryIsoCode.isEmpty) {
      print(
          'Invalid state or country ISO code. State: $stateIsoCode, Country: $countryIsoCode');
      return; // Ensure valid state and country codes
    }

    print(
        'Fetching cities for countryIsoCode: $countryIsoCode and stateIsoCode: $stateIsoCode');

    _isLoadingCity = true; // Start loading cities
    notifyListeners();

    try {
      // Fetch the cities based on the selected state and country
      List<csc.City> cities =
          await csc.getStateCities(countryIsoCode, stateIsoCode);
      print(cities);

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
      notifyListeners();
    } catch (e) {
      _isLoadingCity = false; // Stop loading on error
      notifyListeners();
      print('Error fetching cities: $e');
    }
  }

  Future<void> updateProfile() async {
    try {
      _isLoading = true; // Start loading
      notifyListeners();
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
        CustomSnackbar.show('Profile updated successfully!', isError: false);
      } else if (response.statusCode == 400) {
        // Extracting validation errors from response
        final Map<String, dynamic> errors = response.data['errors'] ?? {};
        // Show error messages for each invalid field
        errors.forEach((key, value) {
          CustomSnackbar.show('$key: $value', isError: true);
        });
      } else {
        CustomSnackbar.show('Failed to update profile! Unexpected error.',
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
        CustomSnackbar.show('Failed to update profile! ${e.message}',
            isError: true);
      }
    } catch (e) {
      // Handle any other errors
      CustomSnackbar.show('Failed to update profile!', isError: true);
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfilePicture() async {
    if (_imagePath != null) {
      try {
        _isLoading = true; // Start loading
        notifyListeners();
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

        _isLoading = false; // Start loading
        notifyListeners();
        CustomSnackbar.show('Profile picture updated successfully!');
      } catch (e) {
        _isLoading = false; // Start loading
        notifyListeners();
        CustomSnackbar.show('Failed to update profile picture!', isError: true);
        print(e);
      }
    }
  }

  Future<void> selectImage() async {
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
          _imagePath = croppedImage.path; // Correct variable name
          notifyListeners();
        }
      } else {
        _imagePath = pickedFile.path; // Correct variable name
        notifyListeners();
      }
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
