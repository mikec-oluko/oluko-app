import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PushNotificationState {}

class NewPushNotification extends PushNotificationState {
  int type;
  NewPushNotification(this.type);
}

class PushNotificationBloc extends Cubit<PushNotificationState> {
  PushNotificationBloc() : super(null);

  void notifyNewPushNotification(int type) {
    emit(NewPushNotification(type));
  }
}
