import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static StreamSubscription<ConnectivityResult> getConnectivityStatusSubscription(Function callback) {
    return Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      callback(result);
    });
  }
}
