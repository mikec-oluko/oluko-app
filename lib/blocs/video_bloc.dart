import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/models/video.dart';
import 'package:oluko_app/repositories/video_repository.dart';

abstract class VideoState {
  final List<Video> videoList;
  const VideoState({this.videoList});
}

class Loading extends VideoState {}

class VideosSuccess extends VideoState {
  final List<Video> videos;

  const VideosSuccess({this.videos}) : super(videoList: videos);
}

/*class VideoSuccess extends VideoState {
  final List<Video> videos;
  const VideoSuccess({this.videos}) : super(videoList: videos);
}*/

class Failure extends VideoState {
  final Exception exception;

  Failure({this.exception});
}

class VideoBloc extends Cubit<VideoState> {
  VideoBloc() : super(Loading());

  List<Video> _videoList = [];

  void getVideos(User user, Video videoParent, String path) async {
    if (!(state is VideosSuccess)) {
      emit(Loading());
    }
    try {
      if (user != null) {
        if (videoParent != null && path != "") {
          _videoList =
              await VideoRepository.getVideoResponses(videoParent.id, path);
        } else {
          _videoList = await VideoRepository.getVideosByUser(user.uid);
        }
      }
      emit(VideosSuccess(videos: _videoList));
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
      _videoList.insert(0, newVideo);
      emit(VideosSuccess(videos: _videoList));
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
      _videoList.insert(0, newVideo);
      emit(VideosSuccess(videos: _videoList));
    } catch (e) {
      emit(Failure(exception: e));
    }
  }
}
