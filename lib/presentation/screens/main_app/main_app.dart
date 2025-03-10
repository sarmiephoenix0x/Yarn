import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/custom_back_handler.dart';
import '../../../core/widgets/custom_bottom_nav.dart';
import '../../controllers/home_page_controller.dart';
import '../../controllers/account_page_controller.dart';
import '../../controllers/main_app_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/notification_controller.dart';
import '../account_page/account_page.dart';
import '../explore_page/explore_page.dart';
import '../home_page/home_page.dart';
import '../like_page/like_page.dart';
import '../search_page/search_page.dart';

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
  @override
  Widget build(BuildContext context) {
    final notificationController = Provider.of<NotificationController>(context);
    final navController = Provider.of<NavigationController>(context);
    final mainAppController = Provider.of<MainAppController>(context);
    return CustomBackHandler(
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: navController
                .selectedIndex, // Keep the state of the selected index
            children: [
              ChangeNotifierProvider(
                create: (context) => AccountPageController(
                  onToggleDarkMode: widget.onToggleDarkMode,
                  isDarkMode: widget.isDarkMode,
                  hubConnection: mainAppController.hubConnection,
                  vsync: this, // Pass vsync correctly
                ),
                child: HomePage(
                  selectedIndex: navController.selectedIndex,
                  onToggleDarkMode: widget.onToggleDarkMode,
                  isDarkMode: widget.isDarkMode,
                  hubConnection: mainAppController.hubConnection,
                ),
              ),
              SearchPage(
                selectedIndex: navController.selectedIndex,
              ),
              LikePage(
                selectedIndex: navController.selectedIndex,
              ),
              ExplorePage(
                selectedIndex: navController.selectedIndex,
              ),
              ChangeNotifierProvider(
                create: (context) => AccountPageController(
                  onToggleDarkMode: widget.onToggleDarkMode,
                  isDarkMode: widget.isDarkMode,
                  hubConnection: mainAppController.hubConnection,
                  vsync: this, // Pass vsync correctly
                ),
                child: AccountPage(
                  selectedIndex: navController.selectedIndex,
                  onToggleDarkMode: widget.onToggleDarkMode,
                  isDarkMode: widget.isDarkMode,
                  hubConnection: mainAppController.hubConnection,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNav(
            hasNotification: notificationController.hasNotificationList,
            onToggleDarkMode: widget.onToggleDarkMode,
            isDarkMode: widget.isDarkMode),
      ),
    );
  }
}
