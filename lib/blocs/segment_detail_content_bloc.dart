import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/submodels/audio.dart';

abstract class SegmentDetailContentState {}

class SegmentDetailContentLoading extends SegmentDetailContentState {}

class SegmentDetailContentDefault extends SegmentDetailContentState {}

class SegmentDetailContentAudioOpen extends SegmentDetailContentState {
  List<Audio> audios;
  Challenge challenge;
  SegmentDetailContentAudioOpen({this.audios, this.challenge});
}

class SegmentDetailContentPeopleOpen extends SegmentDetailContentState {
  List<dynamic> users;
  List<dynamic> favorites;
  SegmentDetailContentPeopleOpen({this.users, this.favorites});
}

class SegmentDetailContentClockOpen extends SegmentDetailContentState {
  String segmentId;
  SegmentDetailContentClockOpen({this.segmentId});
}

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

  void openAudioPanel(List<Audio> audios, Challenge challenge) {
    emit(SegmentDetailContentAudioOpen(audios: audios, challenge: challenge));
  }

  void openPeoplePanel(List<dynamic> users, List<dynamic> favorites) {
    emit(SegmentDetailContentPeopleOpen(users: users, favorites: favorites));
  }

  void openClockPanel(String segmentId) {
    emit(SegmentDetailContentClockOpen(segmentId: segmentId));
  }
}
