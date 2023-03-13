import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class GlobalService with ChangeNotifier {
  static final GlobalService _instance = GlobalService._internal();

  factory GlobalService() => _instance;

  bool _videoProcessing;
  bool _showWelcomeVideoInHome;
  bool _comesFromCoach;
  bool _hasInternetConnection;
  bool _videoHlsIsActive;
  bool _showUserLocation;
  bool _showUserLocationOnRegister;
  ConnectivityResult _connectivityType;

  GlobalService._internal() {
    _videoProcessing = false;
    _comesFromCoach = false;
    _hasInternetConnection = true;
    _videoHlsIsActive = true;
    _showUserLocation = false;
    _showUserLocationOnRegister = true;
    _showWelcomeVideoInHome = true;
  }

  bool get videoProcessing => _videoProcessing;

  bool get showWelcomeVideoInHome => _showWelcomeVideoInHome;

  bool get showUserLocation => _showUserLocation;

  bool get showUserLocationOnRegister => _showUserLocationOnRegister;

  bool get appUseVideoHls => _videoHlsIsActive;

  set videoProcessing(bool value) => _videoProcessing = value;

  bool get comesFromCoach => _comesFromCoach;

  set comesFromCoach(bool value) => _comesFromCoach = value;

  set welcomeVideoInHome(bool value) {
    _showWelcomeVideoInHome = value;
    notifyListeners();
  }

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
