import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yarn/select_state.dart';

class SelectCountry extends StatefulWidget {
  const SelectCountry({super.key});

  @override
  SelectCountryState createState() => SelectCountryState();
}

class SelectCountryState extends State<SelectCountry>
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
                              ),
                            ),
                            const Spacer(),
                            const Expanded(
                              flex: 10,
                              child: Text(
                                'Select your Country',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: Colors.black,
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
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {},
                              )),
                          cursorColor: Colors.black,
                        ),
                      ),

                      Expanded(
                        child: ListView(
                          children: [
                            countries(
                                'images/AfghanistanFlag.png', 'Afghanistan', 1),
                            countries('images/AlbanianFlag.png', 'Albania', 2),
                            countries('images/AlgerianFlag.png', 'Algeria', 3),
                            countries('images/AndorraFlag.png', 'Andorra', 4),
                            countries('images/AngolaFlag.png', 'Angola', 5),
                            countries(
                                'images/ArgentineFlag.png', 'Argentina', 6),
                            countries('images/ArmenianFlag.png', 'Armenia', 7),
                            countries(
                                'images/AustralianFlag.png', 'Australia', 8),
                            countries(
                                'images/AzerbaijanFlag.png', 'Azerbaijan', 9),
                            countries('images/IcelandFlag.png', 'Iceland', 10),
                            countries('images/IndianFlag.png', 'India', 11),
                            countries('images/IranFlag.png', 'Iran', 12),
                            countries('images/IrelandFllag.png', 'Ireland', 13),
                            countries('images/NigerianFlag.png', 'Nigeria', 14),
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
                            builder: (context) => SelectState(key: UniqueKey()),
                          ),
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.pressed)) {
                              return Colors.white;
                            }
                            return const Color(0xFF1877F2);
                          },
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.pressed)) {
                              return const Color(0xFF1877F2);
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

  Widget countries(String img, String name, int value) {
    final isSelected = _selectedRadioValue == value; // Check if this item is selected
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: InkWell( // Use InkWell for tap functionality
        onTap: () {
          setState(() {
            _selectedRadioValue = value;
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1877F2) : Colors.transparent, // Change color based on selection
            // Add other decorations like border if needed
          ),
          child: Row(
            children: [
              Image.asset(
                img,
                height: 50,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
              Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15.0,
                  color: isSelected ? Colors.white : Colors.black, // Change text color based on selection
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
