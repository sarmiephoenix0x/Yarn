import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yarn/sign_in_page.dart';

import 'fill_profile.dart';

class SelectState extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;
  const SelectState({super.key, required this.onToggleDarkMode, required this.isDarkMode});

  @override
  SelectStateState createState() => SelectStateState();
}

class SelectStateState extends State<SelectState>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  final storage = const FlutterSecureStorage();
  late SharedPreferences prefs;
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  int? _selectedRadioValue;

  @override
  void initState() {
    super.initState();
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
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
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  // Wrap SingleChildScrollView with Expanded
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
                                color:Theme.of(context).colorScheme.onSurface,
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
                                  color: Theme.of(context).colorScheme.onSurface,
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
                          controller: searchController,
                          focusNode: _searchFocusNode,
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
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {},
                              )),
                          cursorColor: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),

                      Expanded(
                        child: ListView(
                          children: [
                            countries('State1', 1),
                            countries('State2', 2),
                            countries('State3', 3),
                            countries('State4', 4),
                            countries('State5', 5),
                            countries('State6', 6),
                            countries('State7', 7),
                            countries('State8', 8),
                            countries('State9', 9),
                            countries('State10', 10),
                            countries('State11', 11),
                            countries('State12', 12),
                            countries('State13', 13),
                            countries('State14', 14),
                            SizedBox(
                                height:
                                MediaQuery.of(context).size.height * 0.1),
                          ],
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FillProfile(key: UniqueKey(),
                                onToggleDarkMode: widget.onToggleDarkMode,
                                isDarkMode: widget.isDarkMode),
                          ),
                        );
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
                      child: isLoading
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
  }

  Widget countries(String name, int value) {
    final isSelected = _selectedRadioValue == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRadioValue = value;
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF500450) : Colors.transparent,
          ),
          child: Row(
            children: [
              Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15.0,
                  color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
