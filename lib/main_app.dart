import 'package:flutter/material.dart';

class MainApp extends StatefulWidget {
  const MainApp({
    super.key,
  });

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  final List<bool> _hasNotification = [false, true, false, false]; // Example notification state

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Social App"), // Your app name
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Scrollable views for each bottom nav item
          ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) => ListTile(title: Text("Item ${index + 1}")),
          ),
          ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) => ListTile(title: Text("Item ${index + 1}")),
          ),
          ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) => ListTile(title: Text("Item ${index + 1}")),
          ),
          ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) => ListTile(title: Text("Item ${index + 1}")),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'Home',
            // Add notification dot
            activeIcon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.home),
                if (_hasNotification[0])
                  Positioned(
                    bottom: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      width: 8,
                      height: 8,
                    ),
                  ),
              ],
            ),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.search),
            label: 'Search',
            activeIcon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.search),
                if (_hasNotification[1])
                  Positioned(
                    bottom: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      width: 8,
                      height: 8,
                    ),
                  ),
              ],
            ),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications),
            label: 'Notifications',
            activeIcon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.notifications),
                if (_hasNotification[2])
                  Positioned(
                    bottom: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      width: 8,
                      height: 8,
                    ),
                  ),
              ],
            ),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'Profile',
            activeIcon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.person),
                if (_hasNotification[3])
                  Positioned(
                    bottom: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      width: 8,
                      height: 8,
                    ),
                  ),
              ],
            ),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Customize the selected item color
        onTap: _onItemTapped,
      ),
    );
  }
}