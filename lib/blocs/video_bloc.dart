import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/video.dart';
import 'package:oluko_app/repositories/video_repository.dart';

abstract class VideoState {}

class Loading extends VideoState {}

class VideosSuccess extends VideoState {
  final List<Video> videos;

  VideosSuccess({this.videos});
}

class VideoSuccess extends VideoState {
  VideoSuccess();
}

class Failure extends VideoState {
  final Exception exception;

  Failure({this.exception});
}

class VideoBloc extends Cubit<VideoState> {
  VideoBloc() : super(Loading());

  void getVideos(FirebaseUser user) async {
    if (!(state is VideosSuccess)) {
      emit(Loading());
    }
    try {
      List<Video> videos = [];
      if (user == null) {
        videos = await VideoRepository.getVideos();
      } else {
        videos = await VideoRepository.getVideosByUser(user);
      }
      emit(VideosSuccess(videos: videos));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void createVideo(Video video) async {
    if (!(state is VideosSuccess)) {
      emit(Loading());
    }
    try {
      await VideoRepository.createVideo(video);
      emit(VideoSuccess());
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void createVideoResponse(String parentVideoId, Video video, String path) async {
    if (!(state is VideosSuccess)) {
      emit(Loading());
    }
    try {
      await VideoRepository.createVideoResponse(parentVideoId, video, path);
      emit(VideoSuccess());
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
