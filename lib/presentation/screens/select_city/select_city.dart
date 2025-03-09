import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/select_city_controller.dart';
import '../fill_profile/fill_profile.dart';
import 'widgets/city_tile.dart';

class SelectCity extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  final String countryIsoCode;
  final String stateIsoCode;
  final String selectedState;
  final String username;
  final String password;

  const SelectCity({
    super.key,
    required this.onToggleDarkMode,
    required this.isDarkMode,
    required this.stateIsoCode,
    required this.countryIsoCode,
    required this.selectedState,
    required this.username,
    required this.password,
  });

  @override
  SelectCityState createState() => SelectCityState();
}

class SelectCityState extends State<SelectCity> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SelectCityController(
          countryIsoCode: widget.countryIsoCode,
          stateIsoCode: widget.stateIsoCode),
      child: Consumer<SelectCityController>(
          builder: (context, selectCityController, child) {
        return Scaffold(
          body: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Image.asset(
                            'images/BackButton.png',
                            height: 25,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Expanded(
                          flex: 10,
                          child: Text(
                            'Select your City',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextFormField(
                      controller: selectCityController.searchController,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Search',
                        labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                          fontSize: 12.0,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        prefixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {},
                        ),
                      ),
                      cursorColor: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  selectCityController.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 20),
                            itemCount:
                                selectCityController.filteredCities.length,
                            itemBuilder: (context, index) {
                              return CityTile(
                                city:
                                    selectCityController.filteredCities[index],
                                selectedCity: selectCityController.selectedCity,
                                setSelectedCity:
                                    selectCityController.setSelectedCity,
                              ); // Use the city tile widget
                            },
                          ),
                        ),
                ],
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          width: 0.5, color: Colors.black.withOpacity(0.15)),
                    ),
                    color: Colors.white,
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      width: double.infinity,
                      height: (60 / MediaQuery.of(context).size.height) *
                          MediaQuery.of(context).size.height,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectCityController.selectedCity != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FillProfile(
                                  key: UniqueKey(),
                                  onToggleDarkMode: widget.onToggleDarkMode,
                                  isDarkMode: widget.isDarkMode,
                                  selectedState: widget.selectedState,
                                  countryIsoCode: widget.countryIsoCode,
                                  selectedCity:
                                      selectCityController.selectedCity!.name,
                                  username: widget.username,
                                  password: widget.password,
                                ),
                              ),
                            );
                          } else {
                            // Show a message to select a city if none is selected
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please select a city before proceeding.'),
                              ),
                            );
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Colors.white;
                              }
                              return const Color(0xFF500450);
                            },
                          ),
                          foregroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return const Color(0xFF500450);
                              }
                              return Colors.white;
                            },
                          ),
                          elevation: MaterialStateProperty.all<double>(4.0),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(35)),
                            ),
                          ),
                        ),
                        child: selectCityController.isLoading
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
        );
      }),
    );
  }
}
