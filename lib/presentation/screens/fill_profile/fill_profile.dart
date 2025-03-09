import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../core/widgets/auth_label.dart';
import '../../../core/widgets/auth_text_field.dart';
import '../../../core/widgets/custom_dropdown.dart';
import '../../controllers/fill_profile_controller.dart';

class FillProfile extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  final String selectedState;
  final String countryIsoCode;
  final String selectedCity;
  final String username;
  final String password;

  const FillProfile({
    super.key,
    required this.onToggleDarkMode,
    required this.isDarkMode,
    required this.selectedState,
    required this.countryIsoCode,
    required this.selectedCity,
    required this.username,
    required this.password,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FillProfileState createState() => _FillProfileState();
}

class _FillProfileState extends State<FillProfile> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FillProfileController(
          onToggleDarkMode: widget.onToggleDarkMode,
          isDarkMode: widget.isDarkMode,
          selectedState: widget.selectedState,
          countryIsoCode: widget.countryIsoCode,
          selectedCity: widget.selectedCity,
          username: widget.username,
          password: widget.password),
      child: Consumer<FillProfileController>(
          builder: (context, fillProfileController, child) {
        return OrientationBuilder(
          builder: (context, orientation) {
            return Scaffold(
              body: SafeArea(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Center(
                        child: SizedBox(
                          height: orientation == Orientation.portrait
                              ? MediaQuery.of(context).size.height * 1.35
                              : MediaQuery.of(context).size.height * 2.15,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.05),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Image.asset(
                                        'images/BackButton.png',
                                        height: 25,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Fill your Profile',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.1),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.05),
                              Center(
                                child: Stack(
                                  children: [
                                    if (fillProfileController
                                        .profileImage.isEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(55),
                                        child: Container(
                                          width: (111 /
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width) *
                                              MediaQuery.of(context).size.width,
                                          height: (111 /
                                                  MediaQuery.of(context)
                                                      .size
                                                      .height) *
                                              MediaQuery.of(context)
                                                  .size
                                                  .height,
                                          color: Colors.grey,
                                          child: Image.asset(
                                            'images/ProfileImg.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    else
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(55),
                                        child: Container(
                                          width: (111 /
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width) *
                                              MediaQuery.of(context).size.width,
                                          height: (111 /
                                                  MediaQuery.of(context)
                                                      .size
                                                      .height) *
                                              MediaQuery.of(context)
                                                  .size
                                                  .height,
                                          color: Colors.grey,
                                          child: Image.file(
                                            File(fillProfileController
                                                .profileImage),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: InkWell(
                                        onTap: () {
                                          fillProfileController.selectImage();
                                        },
                                        child: Image.asset(
                                          height: 35,
                                          'images/EditProfileImg.png',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.05),
                              AuthLabel(
                                title: "First Name",
                              ),
                              AuthTextField(
                                controller:
                                    fillProfileController.firstNameController,
                                focusNode:
                                    fillProfileController.firstNameFocusNode,
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.02),
                              AuthLabel(
                                title: "Surname",
                              ),
                              AuthTextField(
                                controller:
                                    fillProfileController.surnameController,
                                focusNode:
                                    fillProfileController.surnameFocusNode,
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.02),
                              AuthLabel(
                                title: "Email",
                              ),
                              AuthTextField(
                                controller:
                                    fillProfileController.emailController,
                                focusNode: fillProfileController.emailFocusNode,
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.02),
                              AuthLabel(
                                title: "Phone Number",
                              ),
                              Form(
                                key: fillProfileController.formKey,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: IntlPhoneField(
                                        decoration: InputDecoration(
                                          labelText: 'Phone Number',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            borderSide: BorderSide(),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            borderSide: const BorderSide(
                                              color: Colors.black,
                                            ),
                                          ),
                                          counterText: '',
                                        ),
                                        initialCountryCode: 'NG',
                                        // Set initial country code
                                        onChanged: (phone) {
                                          fillProfileController.setPhoneNumber(
                                              phone.completeNumber);
                                        },
                                        onCountryChanged: (country) {
                                          print(
                                              'Country changed to: ${country.name}');
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.02),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AuthLabel(
                                      title: "Gender",
                                      isPaddingActive: false,
                                    ),
                                    CustomDropdown(
                                      value:
                                          fillProfileController.selectedGender,
                                      items: ['Male', 'Female', 'Other'],
                                      onChanged: (String? newValue) {
                                        fillProfileController
                                            .setSelectedGender(newValue!);
                                      },
                                      hint: 'Select Gender',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.02),
                              AuthLabel(
                                title: "Date of Birth",
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                    );
                                    if (picked != null) {
                                      // Format the date in dd/MM/yyyy format before updating the controller
                                      fillProfileController.setDobController(
                                          fillProfileController
                                              .formatDate(picked));
                                    }
                                  },
                                  child: AbsorbPointer(
                                    // Prevent TextFormField from opening keyboard
                                    child: AuthTextField(
                                      controller:
                                          fillProfileController.dobController,
                                      focusNode:
                                          fillProfileController.dobFocusNode,
                                      isPaddingActive: false,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                  width: 0.5,
                                  color: Colors.black.withOpacity(0.15))),
                          color: Colors.white,
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                            width: double.infinity,
                            height: (60 / MediaQuery.of(context).size.height) *
                                MediaQuery.of(context).size.height,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => NewsSources(
                                //       key: UniqueKey(),
                                //       onToggleDarkMode: widget.onToggleDarkMode,
                                //       isDarkMode: widget.isDarkMode,
                                //       email: emailController.text.trim(),
                                //       surname: surnameController.text.trim(),
                                //       firstName: firstNameController.text.trim(),
                                //       phoneNumber: phoneNumber,
                                //       dob: dobController.text.trim(),
                                //       state: widget.selectedState,
                                //       country: widget.countryIsoCode,
                                //       occupation: 'Student',
                                //       selectedGender: selectedGender,
                                //       _profileImage: _profileImage,
                                //     ),
                                //   ),
                                // );
                                fillProfileController.registerUser(context);
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
                                shape: WidgetStateProperty.all<
                                    RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35)),
                                  ),
                                ),
                              ),
                              child: fillProfileController.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Next',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
