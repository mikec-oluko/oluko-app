import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class InternetConnectionState {}

class Loading extends InternetConnectionState {}

class InternetConnectionConnectedStatus extends InternetConnectionState {
  final ConnectivityResult connectivityResult;
  InternetConnectionConnectedStatus({this.connectivityResult});
}

class InternetConnectionDisconnectedStatus extends InternetConnectionState {}

class InternetConnectionException extends InternetConnectionState {
  InternetConnectionException({this.exception});
  final dynamic exception;
}

StreamSubscription _internetSubscription;
StreamSubscription _connectivitySubscription;

@override
void dispose() {
  if (_internetSubscription != null) {
    _internetSubscription.cancel();
    _internetSubscription = null;
  }
  if (_connectivitySubscription != null) {
    _connectivitySubscription.cancel();
    _connectivitySubscription = null;
  }
}

class InternetConnectionBloc extends Cubit<InternetConnectionState> {
  InternetConnectionBloc() : super(Loading());
  final InternetConnectionChecker _internetConnectionChecker = InternetConnectionChecker();
  final Connectivity _connectivityChecker = Connectivity();

  StreamSubscription getInternetConnectionStream() {
    final Connectivity _connectivity = Connectivity();
    return _internetSubscription ??= _internetConnectionChecker.onStatusChange.listen((InternetConnectionStatus connectionStatus) async {
      switch (connectionStatus) {
        case InternetConnectionStatus.connected:
          final ConnectivityResult connectivityResult = await _connectivity.checkConnectivity();
          emit(InternetConnectionConnectedStatus(connectivityResult: connectivityResult));
          break;
        case InternetConnectionStatus.disconnected:
          emit(InternetConnectionDisconnectedStatus());
          break;
        default:
          emit(Loading());
      }
    });
  }

  StreamSubscription getConnectivityType() {
    return _connectivitySubscription ??= _connectivityChecker.onConnectivityChanged.listen((ConnectivityResult connectivityResult) {
      switch (connectivityResult) {
        case ConnectivityResult.mobile:
          emit(InternetConnectionConnectedStatus(connectivityResult: connectivityResult));
          break;
        case ConnectivityResult.wifi:
          emit(InternetConnectionConnectedStatus(connectivityResult: connectivityResult));
          break;
        case ConnectivityResult.none:
          emit(InternetConnectionDisconnectedStatus());
          break;
        default:
          emit(Loading());
      }
    });
  }
}
