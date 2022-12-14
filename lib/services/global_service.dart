import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class GlobalService with ChangeNotifier {
  static final GlobalService _instance = GlobalService._internal();

  factory GlobalService() => _instance;

  bool _videoProcessing;
  bool _comesFromCoach;
  bool _hasInternetConnection;
  bool _videoHlsIsActive;
  bool _showUserLocation;
  ConnectivityResult _connectivityType;

  GlobalService._internal() {
    _videoProcessing = false;
    _comesFromCoach = false;
    _hasInternetConnection = true;
    _videoHlsIsActive = true;
    _showUserLocation = false;
  }

  bool get videoProcessing => _videoProcessing;

  bool get showUserLocation => _showUserLocation;

  bool get appUseVideoHls => _videoHlsIsActive;

  set videoProcessing(bool value) => _videoProcessing = value;

  bool get comesFromCoach => _comesFromCoach;

  set comesFromCoach(bool value) => _comesFromCoach = value;

  bool get hasInternetConnection => _hasInternetConnection;

  set setInternetConnection(bool value) {
    _hasInternetConnection = value;
    notifyListeners();
  }

  ConnectivityResult get getConnectivityType => _connectivityType;

  set setConnectivityType(ConnectivityResult connectivityResult) {
    _connectivityType = connectivityResult;
    notifyListeners();
  }
}
