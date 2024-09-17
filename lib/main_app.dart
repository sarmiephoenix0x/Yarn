import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yarn/settings.dart';

import 'account_page.dart';
import 'explore_page.dart';
import 'home_page.dart';
import 'like_page.dart';

class MainApp extends StatefulWidget {
  const MainApp({
    super.key,
  });

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with TickerProviderStateMixin {
  int _selectedIndex = 1;
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<bool> _hasNotification = [false, false, false, false];
  String _profileImage = '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _buildPageContent(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const ImageIcon(
              AssetImage('images/Home.png'),
              color: Colors.grey,
            ),
            label: '',
            // Add notification dot
            activeIcon: Stack(
              alignment: Alignment.center,
              children: [
                const ImageIcon(AssetImage('images/Home-Active.png')),
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
            icon: const ImageIcon(
              AssetImage('images/Explore.png'),
              color: Colors.grey,
            ),
            label: '',
            activeIcon: Stack(
              alignment: Alignment.center,
              children: [
                const ImageIcon(AssetImage('images/Explore.png')),
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
            icon: const ImageIcon(
              AssetImage('images/Like.png'),
              color: Colors.grey,
            ),
            label: '',
            activeIcon: Stack(
              alignment: Alignment.center,
              children: [
                const ImageIcon(AssetImage('images/Like.png')),
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
            icon: const ImageIcon(
              AssetImage('images/Account.png'),
              color: Colors.grey,
            ),
            label: '',
            activeIcon: Stack(
              alignment: Alignment.center,
              children: [
                const ImageIcon(AssetImage('images/Account-active.png')),
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
        onTap: (index) {
          if (index != _selectedIndex) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
      ),
    );
  }
  Widget _buildPageContent(int index) {
    switch (index) {
      case 0:
        return HomePage(selectedIndex: _selectedIndex,);
      case 1:
        return ExplorePage(selectedIndex: _selectedIndex,);
      case 2:
        return LikePage(selectedIndex: _selectedIndex,);
      case 3:
        return AccountPage(selectedIndex: _selectedIndex,);
      default:
        return const Center(child: Text("Error: Invalid page index"));
    }
  }

}
