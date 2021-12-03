import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/user_response.dart';

abstract class InsideClassContentState {}

class InsideClassContentLoading extends InsideClassContentState {}

class InsideClassContentDefault extends InsideClassContentState {}

class InsideClassContentAudioOpen extends InsideClassContentState {}

class InsideClassContentPeopleOpen extends InsideClassContentState {
  List<dynamic> users;
  List<dynamic> favorites;
  InsideClassContentPeopleOpen({this.users, this.favorites});
}

class InsideClassContentClockOpen extends InsideClassContentState {}

class InsideClassContentSuccess extends InsideClassContentState {}

class InsideClassContentFailure extends InsideClassContentState {
  dynamic exception;
  InsideClassContentFailure({this.exception});
}

class InsideClassContentBloc extends Cubit<InsideClassContentState> {
  InsideClassContentBloc() : super(InsideClassContentDefault());

  void emitDefaultState() {
    emit(InsideClassContentDefault());
  }

  void openAudioPanel() {
    emit(InsideClassContentAudioOpen());
  }

  void openPeoplePanel(List<dynamic> users, List<dynamic> favorites) {
    emit(InsideClassContentPeopleOpen(users: users, favorites: favorites));
  }

  void openClockPanel() {
    emit(InsideClassContentClockOpen());
  }
}
