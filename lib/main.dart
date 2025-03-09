import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'presentation/controllers/analytics_controller.dart';
import 'presentation/controllers/community_controller.dart';
import 'presentation/controllers/create_community_controller.dart';
import 'presentation/controllers/create_page_controller.dart';
import 'presentation/controllers/main_app_controller.dart';
import 'presentation/controllers/navigation_controller.dart';
import 'presentation/controllers/notification_controller.dart';
import 'presentation/controllers/notification_page_controller.dart';
import 'presentation/controllers/privacy_controller.dart';
import 'presentation/controllers/select_country_controller.dart';
import 'presentation/controllers/successful_psw_reset_page_controller.dart';
import 'presentation/controllers/theme_controller.dart';
import 'presentation/screens/intro_page/intro_page.dart';
import 'presentation/screens/main_app/main_app.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Initialize the local notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");

  // Dynamically set the channel ID and channel name
  String channelId = "dynamic_channel_${DateTime.now().millisecondsSinceEpoch}";
  String channelName = "Dynamic Notification Channel ${DateTime.now()}";

  // Create the notification channel dynamically
  await _createNotificationChannel(channelId, channelName);

  // Show the notification in the background
  _showNotification(message, channelId, channelName);
}

Future<void> _createNotificationChannel(
    String channelId, String channelName) async {
  AndroidNotificationChannel androidNotificationChannel =
      AndroidNotificationChannel(
    channelId,
    channelName,
    description: 'Notifications for $channelName',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidNotificationChannel);
}

Future<void> _showNotification(
    RemoteMessage message, String channelId, String channelName) async {
  AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    channelId,
    channelName,
    importance: Importance.max,
    priority: Priority.high,
  );

  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidNotificationDetails);

  // Use the message title and body for the notification
  await flutterLocalNotificationsPlugin.show(
    message.hashCode, // Unique notification ID
    message.notification?.title ?? 'No Title',
    message.notification?.body ?? 'No Body',
    platformChannelSpecifics,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await checkBatteryOptimization();
  await Firebase.initializeApp();

  // Initialize local notifications plugin
  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('app_icon');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: androidInitializationSettings);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('Received a foreground message: ${message.notification?.title}');
    String channelId =
        "dynamic_channel_${DateTime.now().millisecondsSinceEpoch}";
    String channelName = "Dynamic Channel";

    // Dynamically create the notification channel
    await _createNotificationChannel(channelId, channelName);

    // Show the notification
    await _showNotification(message, channelId, channelName);
  });

  runApp(const MyApp());
}

Future<void> checkBatteryOptimization() async {
  try {
    final isIgnoring =
        await FlutterForegroundTask.isIgnoringBatteryOptimizations;
    if (!isIgnoring) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }
  } catch (e) {
    print('Error checking/requesting battery optimizations: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;
  bool isLoading = false; // Loading state
  bool isDarkMode = false; // Dark mode state
  String? fcmToken;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    setState(() {
      isLoading = true; // Start loading
    });

    const storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'yarnAccessToken');
    isLoggedIn = accessToken != null;

    // Check network connectivity
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      print('No network connection');
      setState(() {
        isLoading = false; // Stop loading
      });
      return;
    }

    try {
      // Request permission and get token
      await _requestPermission();
      await _getToken();
    } catch (e) {
      print("Error during initialization: $e");
      // Optionally show an error message
      _showErrorMessage(
          "An error occurred during initialization. Please try again.");
    } finally {
      // Ensure loading state is updated
      setState(() {
        isLoading = false; // Stop loading
      });
    }

    // Retrieve and store the FCM token
    fcmToken = await getStoredFCMToken();

    final prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool('isDarkMode') ?? false;
  }

  Future<void> _requestPermission() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging
          .requestPermission(
            alert: true,
            badge: true,
            provisional: false,
            sound: true,
          )
          .timeout(const Duration(seconds: 10)); // Set timeout duration

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined permission');
        _showErrorMessage("Permission to receive notifications was denied.");
      }
    } catch (e) {
      if (e is TimeoutException) {
        print("Permission request timed out");
        _showErrorMessage(
            "Failed to request notification permissions. Please try again later.");
      } else {
        print("Error requesting permission: $e");
        _showErrorMessage(
            "An error occurred while requesting notification permissions.");
      }
    }
  }

  Future<void> _getToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging
          .getToken()
          .timeout(const Duration(seconds: 10)); // Set timeout duration
      print("FCM Token: $token");

      if (token != null) {
        // Save the token locally for later use
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcmToken', token);
      }
    } catch (e) {
      if (e is TimeoutException) {
        print("Token fetch timed out");
        _showErrorMessage("Failed to fetch FCM token. Please try again later.");
      } else {
        print("Error fetching token: $e");
        _showErrorMessage("An error occurred while fetching the FCM token.");
      }
    }
  }

  void _showErrorMessage(String message) {
    // You can use a dialog or a snackbar to show the error message
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String?> getStoredFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcmToken');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF500450))), // Loading indicator
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnalyticsController()),
        ChangeNotifierProvider(create: (_) => CommunityController()),
        ChangeNotifierProvider(create: (_) => CreateCommunityController()),
        ChangeNotifierProvider(create: (_) => CreatePageController()),
        ChangeNotifierProvider(create: (_) => MainAppController()),
        ChangeNotifierProvider(create: (_) => NotificationPageController()),
        ChangeNotifierProvider(create: (_) => PrivacyController()),
        ChangeNotifierProvider(create: (_) => SelectCountryController()),
        ChangeNotifierProvider(
            create: (_) => SuccessfulPswResetPageController()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => NavigationController()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return MaterialApp(
            navigatorObservers: [routeObserver],
            themeMode:
                themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: isLoggedIn
                ? MainApp(
                    onToggleDarkMode: themeController.toggleDarkMode,
                    isDarkMode: themeController.isDarkMode)
                : IntroPage(
                    onToggleDarkMode: themeController.toggleDarkMode,
                    isDarkMode: themeController.isDarkMode,
                    fcmToken: fcmToken, // Pass the token here
                  ),
          );
        },
      ),
    );
  }
}
