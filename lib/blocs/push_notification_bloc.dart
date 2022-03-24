import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PushNotificationState {}

class NewPushNotification extends PushNotificationState {}

class PushNotificationBloc extends Cubit<PushNotificationState> {
  PushNotificationBloc() : super(null);

  void notifyNewPushNotification() {
    emit(NewPushNotification());
  }
}
