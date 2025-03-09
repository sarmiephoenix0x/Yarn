import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/logout_dialog.dart';
import '../../../core/widgets/privacy_list_widget.dart';
import '../../controllers/settings_controller.dart';
import '../privacy/privacy.dart';

class Settings extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final bool isDarkMode;

  const Settings(
      {super.key, required this.onToggleDarkMode, required this.isDarkMode});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingsController(
          onToggleDarkMode: widget.onToggleDarkMode,
          isDarkMode: widget.isDarkMode),
      child: Consumer<SettingsController>(
          builder: (context, settingsController, child) {
        return PopScope(
          canPop: true,
          child: Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        // Wrap SingleChildScrollView with Expanded
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 20),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Image.asset(
                                      'images/BackButton.png',
                                      height: 25,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.05),
                                  Expanded(
                                    flex: 10,
                                    child: Text(
                                      'Settings',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 20),
                                    child: InkWell(
                                      // Use InkWell for tap functionality
                                      onTap: () {},
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            'images/Bell.png',
                                            height: 35,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.05),
                                          Text(
                                            'Notifications',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 15.0,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  PrivacyListWidget(
                                    title: 'Privacy',
                                    img: 'images/Privacy.png',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              Privacy(key: UniqueKey()),
                                        ),
                                      );
                                    },
                                    isSwitch: false,
                                    mediaQueryVal: 0.065,
                                  ),
                                  PrivacyListWidget(
                                    title: 'Account',
                                    img: 'images/AccountSettings.png',
                                    onTap: () {},
                                    isSwitch: false,
                                  ),
                                  PrivacyListWidget(
                                    title: 'Language',
                                    img: 'images/Language.png',
                                    onTap: () {},
                                    isSwitch: false,
                                  ),
                                  PrivacyListWidget(
                                    title: 'Help',
                                    img: 'images/Help.png',
                                    onTap: () {},
                                    isSwitch: false,
                                  ),
                                  PrivacyListWidget(
                                    title: 'About',
                                    img: 'images/About.png',
                                    onTap: () {},
                                    isSwitch: false,
                                  ),
                                  PrivacyListWidget(
                                    title: 'Dark Mode',
                                    img: 'images/tabler_brightness-filled.png',
                                    onTap: () {},
                                    isSwitch: true,
                                    value: settingsController.darkModeMoved,
                                    onChanged:
                                        settingsController.toggleDarkMode,
                                    mediaQueryVal: 0.065,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 20),
                                    child: InkWell(
                                      onTap: () {
                                        showLogoutDialog(
                                            context, settingsController.logout);
                                      },
                                      child: Text(
                                        'Log out',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 15.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
