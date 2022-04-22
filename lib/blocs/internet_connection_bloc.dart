import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class InternetConnectionState {}

class Loading extends InternetConnectionState {}

class InternetConnectionConnectedStatus extends InternetConnectionState {}

class InternetConnectionDisconnectedStatus extends InternetConnectionState {}

class InternetConnectionException extends InternetConnectionState {
  InternetConnectionException({this.exception});
  final dynamic exception;
}

StreamSubscription _internetSubscription;

@override
void dispose() {
  if (_internetSubscription != null) {
    _internetSubscription.cancel();
    _internetSubscription = null;
  }
}

class InternetConnectionBloc extends Cubit<InternetConnectionState> {
  InternetConnectionBloc() : super(Loading());

  StreamSubscription getInternetConnectionStream() {
    return _internetSubscription ??= InternetConnectionChecker().onStatusChange.listen((InternetConnectionStatus connectionStatus) {
      switch (connectionStatus) {
        case InternetConnectionStatus.connected:
          emit(InternetConnectionConnectedStatus());
          break;
        case InternetConnectionStatus.disconnected:
          emit(InternetConnectionDisconnectedStatus());
          break;
        default:
          emit(Loading());
      }
    });
  }
}
