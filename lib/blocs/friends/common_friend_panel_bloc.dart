import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

abstract class CommonFriendPanelState {}

class CommonFriendPanelLoading extends CommonFriendPanelState {}

class CommonFriendPanelOpen extends CommonFriendPanelState {
  CommonFriendPanelOpen();
}

class CommonFriendPanelClose extends CommonFriendPanelState {
  CommonFriendPanelClose();
}

class CommonFriendPanelDefaultState extends CommonFriendPanelState {
  CommonFriendPanelDefaultState();
}

class CommonFriendPanelFailure extends CommonFriendPanelState {
  final dynamic exception;

  CommonFriendPanelFailure({this.exception});
}

class CommonFriendPanelBloc extends Cubit<CommonFriendPanelState> {
  CommonFriendPanelBloc() : super(CommonFriendPanelLoading());

  void openFriendPanel() {
    emit(CommonFriendPanelOpen());
  }
}
