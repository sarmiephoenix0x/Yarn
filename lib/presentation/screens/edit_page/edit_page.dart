import 'dart:io';

import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import '../../controllers/edit_page_controller.dart';

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
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EditPageController(
          editContext: context, profileImgUrl: widget.profileImgUrl),
      child: Consumer<EditPageController>(
        builder: (context, editPageController, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Edit Profile'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: editPageController.formKey,
                child: Column(
                  children: [
                    // Profile Picture section
                    Center(
                      child: Stack(
                        children: [
                          if (editPageController.imagePath == null ||
                              editPageController.imagePath!
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
                          else if (editPageController.imagePath!
                              .startsWith('http'))
                            ClipRRect(
                              borderRadius: BorderRadius.circular(55),
                              child: Container(
                                width: 111,
                                height: 111,
                                color: Colors.grey,
                                child: Image.network(
                                  editPageController.imagePath!,
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
                                child: Image.file(
                                    File(editPageController.imagePath!),
                                    fit: BoxFit.cover),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: editPageController.selectImage,
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
                      onChanged: (value) =>
                          editPageController.setUsername(value),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username cannot be empty';
                        }
                        return null; // Return null if valid
                      },
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'First Name'),
                      onChanged: (value) =>
                          editPageController.setFirstName(value),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'First name cannot be empty';
                        }
                        return null; // Return null if valid
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Surname'),
                      onChanged: (value) =>
                          editPageController.setSurname(value),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Surname cannot be empty';
                        }
                        return null; // Return null if valid
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Email'),
                      onChanged: (value) => editPageController.setEmail(value),
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
                        editPageController.setPhone(phone.completeNumber);
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
                      value: editPageController.isLoadingCountry
                          ? null
                          : editPageController.selectedCountryIsoCode,
                      items: editPageController.isLoadingCountry
                          ? null
                          : editPageController.countries
                              .map((csc.Country country) {
                              return DropdownMenuItem<String>(
                                value: country.isoCode,
                                child: Text(country.name),
                              );
                            }).toList(),
                      onChanged: (value) async {
                        editPageController.setSelectedCountryIsoCode(value!);
                        editPageController.setStates([]);
                        editPageController.setSelectedState(null);

                        if (editPageController.selectedCountryIsoCode != null) {
                          await editPageController.fetchStates(
                              editPageController.selectedCountryIsoCode!);
                        }
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a country';
                        }
                        return null; // Return null if valid
                      },
                      hint: editPageController.isLoadingCountry
                          ? const Text('Loading...')
                          : null,
                    ),
                    SizedBox(
                        height: (16.0 / MediaQuery.of(context).size.height) *
                            MediaQuery.of(context).size.height),
                    PopupMenuButton<String>(
                      onSelected: (String value) async {
                        // Find the selected state based on the ISO code
                        csc.State? selectedState = editPageController.states
                            .firstWhere((state) => state.isoCode == value,
                                orElse: () => csc.State(
                                    name: '',
                                    isoCode: '',
                                    latitude: '',
                                    longitude: '',
                                    countryCode: ''));

                        if (selectedState != null) {
                          setState(() {
                            editPageController.setSelectedStateIsoCode(
                                value); // Update selected state ISO code
                            editPageController.setSelectedState(selectedState
                                .name); // Update selected state name
                            editPageController.setCities([]);
                            editPageController
                                .setSelectedCity(null); // Reset city
                          });

                          // Fetch cities after state is selected
                          if (editPageController.selectedStateIsoCode != null) {
                            await editPageController.fetchCities(
                                editPageController.selectedStateIsoCode!,
                                editPageController.selectedCountryIsoCode!);
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return editPageController.isLoadingState
                            ? [
                                const PopupMenuItem<String>(
                                  enabled:
                                      false, // Disable selection while loading
                                  child: Center(
                                      child:
                                          CircularProgressIndicator()), // Show loading spinner
                                )
                              ]
                            : editPageController.states.map((csc.State state) {
                                return PopupMenuItem<String>(
                                  value: state.isoCode,
                                  child: Text(
                                    state.name ==
                                            editPageController.selectedState
                                        ? '${state.name} (Detected)' // Show detected alias
                                        : state.name, // Normal state name
                                  ),
                                );
                              }).toList();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0),
                          border: Border(
                              bottom: BorderSide(
                                  color: Theme.of(context).dividerColor)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              editPageController.isLoadingState
                                  ? 'Loading...'
                                  : (editPageController.selectedState ??
                                      'Select a state'),
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
                        editPageController
                            .setSelectedCity(value); // Update selected city
                      },
                      itemBuilder: (BuildContext context) {
                        return editPageController.isLoadingCity
                            ? [
                                const PopupMenuItem<String>(
                                  enabled:
                                      false, // Disable selection while loading
                                  child: Center(
                                      child:
                                          CircularProgressIndicator()), // Show loading spinner
                                )
                              ]
                            : editPageController.cities.map((csc.City city) {
                                return PopupMenuItem<String>(
                                  value: city.name,
                                  child: Text(
                                    city.name == editPageController.selectedCity
                                        ? '${city.name} (Detected)' // Show detected alias
                                        : city.name, // Normal city name
                                  ),
                                );
                              }).toList();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0),
                          border: Border(
                              bottom: BorderSide(
                                  color: Theme.of(context).dividerColor)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              editPageController.isLoadingCity
                                  ? 'Loading...'
                                  : (editPageController.selectedCity ??
                                      'Select a city'),
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
                      value: editPageController.gender,
                      hint: const Text('Select Gender'),
                      onChanged: (String? newValue) {
                        editPageController.setGender(newValue!);
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
                          editPageController.setDobController(
                              editPageController.formatDate(picked));
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: editPageController.dobController,
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
                          if (editPageController.imagePath != null &&
                              editPageController.imagePath!.isNotEmpty) {
                            // If user selects an image, update only the profile image

                            editPageController
                                .setIsProfileImageUpdateOnly(true);
                          } else {
                            editPageController
                                .setIsProfileImageUpdateOnly(false);
                          }

                          // If user is updating only the profile image, skip form validation
                          if (editPageController.isProfileImageUpdateOnly) {
                            await editPageController
                                .updateProfilePicture(); // Update profile picture only
                            if (editPageController.formKey.currentState!
                                .validate()) {
                              await editPageController.updateProfile();
                            }
                          } else {
                            // Validate the form and update the whole profile if valid
                            if (editPageController.formKey.currentState!
                                .validate()) {
                              await editPageController
                                  .updateProfile(); // Update full profile
                              if (editPageController.imagePath != null &&
                                  editPageController.imagePath!.isNotEmpty) {
                                await editPageController
                                    .updateProfilePicture(); // Also update profile picture if changed
                              }
                            }
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.pressed)) {
                                return Colors.white;
                              }
                              return const Color(0xFF500450);
                            },
                          ),
                          foregroundColor:
                              WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.pressed)) {
                                return const Color(0xFF500450);
                              }
                              return Colors.white;
                            },
                          ),
                          elevation: WidgetStateProperty.all<double>(4.0),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(35)),
                            ),
                          ),
                        ),
                        child: editPageController.isLoading
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
        },
      ),
    );
  }
}
