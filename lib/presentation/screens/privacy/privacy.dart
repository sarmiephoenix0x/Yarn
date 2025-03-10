import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/privacy_controller.dart';
import '../../../core/widgets/privacy_list_widget.dart';

class Privacy extends StatefulWidget {
  const Privacy({super.key});

  @override
  PrivacyState createState() => PrivacyState();
}

class PrivacyState extends State<Privacy> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final privacyController = Provider.of<PrivacyController>(context);
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
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.05),
                              Expanded(
                                flex: 10,
                                child: Text(
                                  'Privacy',
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
                        Expanded(
                          child: ListView(
                            children: [
                              PrivacyListWidget(
                                title: 'Private profile',
                                img: 'images/Privacy.png',
                                onTap: () {},
                                isSwitch: true,
                                value: privacyController.privateProfileMoved,
                                onChanged: (value) => {},
                                mediaQueryVal: 0.065,
                              ),
                              PrivacyListWidget(
                                title: 'Muted',
                                img: 'images/Muted.png',
                                onTap: () {},
                                isSwitch: false,
                              ),
                              PrivacyListWidget(
                                title: 'Hidden Words',
                                img: 'images/Hidden word.png',
                                onTap: () {},
                                isSwitch: false,
                              ),
                              PrivacyListWidget(
                                title: 'Profiles you follow',
                                img: 'images/Users.png',
                                onTap: () {},
                                isSwitch: false,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 20),
                                child: InkWell(
                                  // Use InkWell for tap functionality
                                  onTap: () {},
                                  child: Row(
                                    children: [
                                      Text(
                                        'Other privacy settings',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 15.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
                                      const Spacer(),
                                      Image.asset(
                                        'images/Exit.png',
                                        height: 35,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 20),
                                child: Text(
                                  'Some settings, like restricting, apply to both threads and Instagram and can be managed on instagram.',
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  maxLines: 3,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 15.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 20),
                                child: InkWell(
                                  // Use InkWell for tap functionality
                                  onTap: () {},
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'images/Blocked.png',
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
                                        'Blocked',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 15.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
                                      const Spacer(),
                                      Image.asset(
                                        'images/Exit.png',
                                        height: 35,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ],
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
  }
}
