import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yarn/search_page.dart';
import 'account_page.dart';
import 'explore_page.dart';
import 'home_page.dart';
import 'like_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:signalr_core/signalr_core.dart';

class MainApp extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;

  const MainApp({
    super.key,
    required this.onToggleDarkMode,
    required this.isDarkMode,
  });

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  DateTime? currentBackPressTime;
  HubConnection? _hubConnection;

  @override
  void initState() {
    super.initState();
    _startSignalRConnection();
    _getLocationPermission();
  }

  Future<void> _startSignalRConnection() async {
    _hubConnection = HubConnectionBuilder()
        .withUrl("https://yarnapi-fuu0.onrender.com/postHub")
        .build();

    _hubConnection?.onclose((error) {
      print("Connection closed: $error");
    });

    await _hubConnection?.start();
    print("SignalR connection started");
  }

  Future<void> _getLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
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
      duration: const Duration(seconds: 2),
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
      onPopInvokedWithResult: (didPop, dynamic result) {
        if (!didPop) {
          DateTime now = DateTime.now();
          if (currentBackPressTime == null ||
              now.difference(currentBackPressTime!) >
                  const Duration(seconds: 2)) {
            currentBackPressTime = now;
            _showCustomSnackBar(
              context,
              'Press back again to exit',
              isError: true,
            );
          } else {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: _selectedIndex, // Keep the state of the selected index
            children: [
              HomePage(
                selectedIndex: _selectedIndex,
                onToggleDarkMode: widget.onToggleDarkMode,
                isDarkMode: widget.isDarkMode,
                hubConnection: _hubConnection,
              ),
              SearchPage(
                selectedIndex: _selectedIndex,
              ),
              LikePage(
                selectedIndex: _selectedIndex,
              ),
              ExplorePage(
                selectedIndex: _selectedIndex,
              ),
              AccountPage(
                selectedIndex: _selectedIndex,
                onToggleDarkMode: widget.onToggleDarkMode,
                isDarkMode: widget.isDarkMode,
                hubConnection: _hubConnection,
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const ImageIcon(
                AssetImage('images/Home.png'),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: const ImageIcon(
                AssetImage('images/Search.png'),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: const ImageIcon(
                AssetImage('images/Like.png'),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: const ImageIcon(
                AssetImage('images/Explore.png'),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: const ImageIcon(
                AssetImage('images/Account.png'),
              ),
              label: '',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF500450),
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            if (index != _selectedIndex) {
              setState(() {
                _selectedIndex = index; // Update the selected index
              });
            }
          },
        ),
      ),
    );
  }
}
