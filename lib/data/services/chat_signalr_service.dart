import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:signalr_core/signalr_core.dart';
import 'dart:async';

class ChatSignalR {
  final String serverUrl = "https://yarnapi-fuu0.onrender.com/chatHub";
  late HubConnection hubConnection;
  final storage = const FlutterSecureStorage();

  Future<void> initSignalR() async {
    final String? accessToken = await storage.read(key: 'yarnAccessToken');
    hubConnection = HubConnectionBuilder()
        .withUrl(
            serverUrl,
            HttpConnectionOptions(
              accessTokenFactory: () async => accessToken,
            ))
        .build();

    hubConnection.onclose((error) {
      print('Connection Closed: $error');
    });

    await hubConnection.start();
    print('SignalR connection established');
  }

  void onMessageReceived(Function(int messageId) onMessage) {
    hubConnection.on("MessageReceived", (messageId) {
      onMessage(messageId?[0]);
    });
  }
}
