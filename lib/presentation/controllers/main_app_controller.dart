import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:signalr_core/signalr_core.dart';

class MainAppController extends ChangeNotifier {
  HubConnection? _hubConnection;

  MainAppController() {
    initialize();
  }

//public getters
  HubConnection? get hubConnection => _hubConnection;

  void initialize() {
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
}
