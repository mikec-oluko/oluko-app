import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/submodels/user_submodel.dart';

abstract class SegmentDetailContentState {}

class SegmentDetailContentLoading extends SegmentDetailContentState {}

class SegmentDetailContentDefault extends SegmentDetailContentState {}

class SegmentDetailContentAudioOpen extends SegmentDetailContentState {}

class SegmentDetailContentPeopleOpen extends SegmentDetailContentState {
  List<dynamic> users;
  List<dynamic> favorites;
  SegmentDetailContentPeopleOpen({this.users, this.favorites});
}

class SegmentDetailContentClockOpen extends SegmentDetailContentState {}

class SegmentDetailContentSuccess extends SegmentDetailContentState {}

class SegmentDetailContentFailure extends SegmentDetailContentState {
  dynamic exception;
  SegmentDetailContentFailure({this.exception});
}

class SegmentDetailContentBloc extends Cubit<SegmentDetailContentState> {
  SegmentDetailContentBloc() : super(SegmentDetailContentDefault());

  void emitDefaultState() {
    emit(SegmentDetailContentDefault());
  }

  void openAudioPanel() {
    emit(SegmentDetailContentAudioOpen());
  }

  void openPeoplePanel(List<dynamic> users, List<dynamic> favorites) {
    emit(SegmentDetailContentPeopleOpen(users: users, favorites: favorites));
  }

  void openClockPanel() {
    emit(SegmentDetailContentClockOpen());
  }
}
