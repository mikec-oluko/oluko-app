import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/draw_point.dart';
import 'package:oluko_app/models/video_tracking.dart';
import 'package:oluko_app/repositories/video_tracking_repository.dart';

abstract class VideoTrackingState {}

class Loading extends VideoTrackingState {}

class VideoTrackingSuccess extends VideoTrackingState {
  final VideoTracking videoTracking;

  VideoTrackingSuccess({this.videoTracking});
}

class Failure extends VideoTrackingState {
  final Exception exception;

  Failure({this.exception});
}

class VideoTrackingBloc extends Cubit<VideoTrackingState> {
  VideoTrackingBloc() : super(Loading());

  void createVideoTracking(
      List<DrawPoint> canvasPointsRecording, DocumentReference reference) async {
    if (!(state is VideoTrackingSuccess)) {
      emit(Loading());
    }
    try {
      await VideoTrackingRepository.createVideoTracking(canvasPointsRecording, reference);
      emit(VideoTrackingSuccess());
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void getVideoTracking(DocumentReference reference) async {
    if (!(state is VideoTrackingSuccess)) {
      emit(Loading());
    }
    try {
      VideoTracking videoTracking =
          await VideoTrackingRepository.getVideoTracking(reference);
      emit(VideoTrackingSuccess(videoTracking: videoTracking));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
