import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/widgets/custom_snackbar.dart';
import '../screens/intro_page/intro_page.dart';
import 'chat_provider_controller.dart';

class SettingsController extends ChangeNotifier {
  bool _isLoading = false;
  final storage = const FlutterSecureStorage();
  late SharedPreferences prefs;
  TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  int? _selectedRadioValue;
  bool _darkModeMoved = false;

  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;

  SettingsController(
      {required this.onToggleDarkMode, required this.isDarkMode}) {
    initialize();
  }

//public getters
  bool get isLoading => _isLoading;
  int? get selectedRadioValue => _selectedRadioValue;
  bool get darkModeMoved => _darkModeMoved;

  TextEditingController get searchController => _searchController;
  FocusNode get searchFocusNode => _searchFocusNode;

  void initialize() {
    _loadDarkModePreference();
    _initializePrefs();
  }

  void _loadDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _darkModeMoved = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  void toggleDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _darkModeMoved = value;
    notifyListeners();
    await prefs.setBool('isDarkMode', value);
    onToggleDarkMode(value);
  }

  Future<void> logout(BuildContext context) async {
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    if (accessToken == null) {
      CustomSnackbar.show(
        'You are not logged in.',
        isError: true,
      );

      return;
    }

    // Clear saved chats before logging out
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.clearChats(); // Clear chats from the provider

    await storage.delete(key: 'yarnAccessToken');
    await prefs.remove('user');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => IntroPage(
            onToggleDarkMode: onToggleDarkMode, isDarkMode: isDarkMode),
      ),
    );

    _isLoading = false;
    notifyListeners();
  }
}
