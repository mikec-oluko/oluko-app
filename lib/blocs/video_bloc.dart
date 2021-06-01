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
  Video video;
  VideoSuccess({this.video});
}

class Failure extends VideoState {
  final Exception exception;

  Failure({this.exception});
}

class VideoBloc extends Cubit<VideoState> {
  VideoBloc() : super(Loading());

  void getVideos(FirebaseUser user, Video videoParent, String path) async {
    if (!(state is VideosSuccess)) {
      emit(Loading());
    }
    try {
      List<Video> videos = [];
      if (user != null) {
        if (videoParent != null && path != "") {
          videos = await VideoRepository.getVideoResponses(
              videoParent.id, path);
        } else {
          videos = await VideoRepository.getVideosByUser(user.uid);
        }
      }
      emit(VideosSuccess(videos: videos));
    } catch (e) {
      print(e.toString());
      emit(Failure(exception: e));
    }
  }

  void createVideo(Video video) async {
    if (!(state is VideosSuccess)) {
      emit(Loading());
    }
    try {
      Video newVideo = await VideoRepository.createVideo(video);
      emit(VideoSuccess(video: newVideo));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }

  void createVideoResponse(
      String parentVideoId, Video video, String path) async {
    if (!(state is VideosSuccess)) {
      emit(Loading());
    }
    try {
      Video newVideo =
          VideoRepository.createVideoResponse(parentVideoId, video, path);
      emit(VideoSuccess(video: newVideo));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
