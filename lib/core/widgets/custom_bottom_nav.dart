import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/controllers/navigation_controller.dart';

class CustomBottomNav extends StatelessWidget {
  final List<bool> hasNotification;
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;

  const CustomBottomNav(
      {super.key,
      required this.hasNotification,
      required this.onToggleDarkMode,
      required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final navController = Provider.of<NavigationController>(context);

    return BottomNavigationBar(
      items: [
        _buildNavItem('images/Home.png', '', hasNotification[0]),
        _buildNavItem('images/Search.png', '', hasNotification[1]),
        _buildNavItem('images/Like.png', '', hasNotification[2]),
        _buildNavItem('images/Explore.png', '', hasNotification[3]),
        _buildNavItem('images/Account.png', '', hasNotification[4]),
      ],
      currentIndex: navController.selectedIndex,
      selectedItemColor: const Color(0xFF500450),
      unselectedItemColor: Colors.grey,
      onTap: (index) => navController.changeTab(index),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      String assetPath, String label, bool hasNotification) {
    return BottomNavigationBarItem(
      icon: ImageIcon(
        AssetImage(assetPath),
        color: Colors.grey,
      ),
      label: label,
      activeIcon: Stack(
        alignment: Alignment.center,
        children: [
          ImageIcon(AssetImage(assetPath)),
          if (hasNotification)
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
    );
  }
}
