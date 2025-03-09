import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/custom_snackbar.dart';
import '../../controllers/select_state_controller.dart';
import '../select_city/select_city.dart';
import 'widgets/state_tile.dart';

class SelectState extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  final String countryIsoCode;
  final String username;
  final String password;

  const SelectState({
    super.key,
    required this.onToggleDarkMode,
    required this.isDarkMode,
    required this.countryIsoCode,
    required this.username,
    required this.password,
  });

  @override
  SelectStateState createState() => SelectStateState();
}

class SelectStateState extends State<SelectState>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SelectStateController(
        countryIsoCode: widget.countryIsoCode,
      ),
      child: Consumer<SelectStateController>(
          builder: (context, selectStateController, child) {
        return Scaffold(
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1),
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
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                              Expanded(
                                flex: 10,
                                child: Text(
                                  'Select your State',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: TextFormField(
                            controller: selectStateController.searchController,
                            focusNode: selectStateController.searchFocusNode,
                            onChanged: (value) {
                              selectStateController.filterStates(
                                  value); // Filter states based on search input
                            },
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
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              prefixIcon: IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {},
                              ),
                            ),
                            cursorColor:
                                Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        selectStateController.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  itemCount: selectStateController
                                      .filteredStates
                                      .length, // Use filteredStates
                                  itemBuilder: (context, index) {
                                    return StateTile(
                                      state: selectStateController
                                          .filteredStates[index],
                                      value: index,
                                      selectedRadioValue: selectStateController
                                          .selectedRadioValue,
                                      setSelectedRadioValue:
                                          selectStateController
                                              .setSelectedRadioValue,
                                      setSelectedState: selectStateController
                                          .setSelectedState,
                                      setSelectedStateIsoCode:
                                          selectStateController
                                              .setSelectedStateIsoCode,
                                    );
                                  },
                                ),
                              ),
                      ],
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
                            width: 0.5, color: Colors.black.withOpacity(0.15))),
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
                          if (selectStateController
                              .selectedStateIsoCode.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SelectCity(
                                  onToggleDarkMode: widget.onToggleDarkMode,
                                  isDarkMode: widget.isDarkMode,
                                  stateIsoCode: selectStateController
                                      .selectedStateIsoCode,
                                  countryIsoCode: widget.countryIsoCode,
                                  selectedState:
                                      selectStateController.selectedState,
                                  username: widget.username,
                                  password: widget.password,
                                ),
                              ),
                            );
                          } else {
                            CustomSnackbar.show('Please select a state');
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
                        child: selectStateController.isLoading
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
