import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SegmentDetailContentState {}

class SegmentDetailContentLoading extends SegmentDetailContentState {}

class SegmentDetailContentDefault extends SegmentDetailContentState {}

class SegmentDetailContentAudioOpen extends SegmentDetailContentState {}

class SegmentDetailContentPeopleOpen extends SegmentDetailContentState {}

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

  void openPeoplePanel() {
    emit(SegmentDetailContentPeopleOpen());
  }

  void openClockPanel() {
    emit(SegmentDetailContentClockOpen());
  }
}
