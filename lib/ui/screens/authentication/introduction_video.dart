import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/introduction_media_bloc.dart';
import 'package:oluko_app/repositories/introduction_media_repository.dart';
import 'package:oluko_app/routes.dart';
import 'package:video_player/video_player.dart';

class IntroductionVideo extends StatefulWidget {
  IntroductionVideo({Key key, this.chewieController, this.videoPlayerController}) : super(key: key);

  VideoPlayerController videoPlayerController;
  ChewieController chewieController;

  @override
  _IntroductionVideoState createState() => _IntroductionVideoState();
}

class _IntroductionVideoState extends State<IntroductionVideo> {
  @override
  Widget build(BuildContext context) {
    BlocProvider.of<IntroductionMediaBloc>(context).getIntroVideo();
    return FutureBuilder<ChewieController>(
      future: getChewieWithVideo(context),
      builder: (
        BuildContext context,
        AsyncSnapshot<ChewieController> snapshot,
      ) {
        if (snapshot != null && snapshot.hasData != null) {
          return Chewie(
            controller: snapshot.data,
          );
        } else {
          widget.videoPlayerController.dispose();
          widget.chewieController.dispose();
          Navigator.pushReplacementNamed(context, routeLabels[RouteEnum.signUp]);
          return const SizedBox();
        }
      },
    );
  }

  Future<ChewieController> getChewieWithVideo(BuildContext context) async {
    final mediaURL = await IntroductionMediaRepository().getIntroVideoURL();
    widget.videoPlayerController = VideoPlayerController.network(mediaURL);
    await widget.videoPlayerController.initialize();
    widget.chewieController = ChewieController(
      videoPlayerController: widget.videoPlayerController,
      autoPlay: true,
      autoInitialize: true,
      showControls: false,
      fullScreenByDefault: true,
    );
    widget.videoPlayerController.addListener(() {
      if (widget.videoPlayerController != null &&
          widget.videoPlayerController.value.position == widget.videoPlayerController.value.duration) {
        widget.videoPlayerController.dispose();
        widget.chewieController.dispose();
        Navigator.pushReplacementNamed(context, routeLabels[RouteEnum.signUp]);
      }
    });
    return widget.chewieController;
  }
}
