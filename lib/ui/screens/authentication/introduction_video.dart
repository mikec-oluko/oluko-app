import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/introduction_media_bloc.dart';
import 'package:oluko_app/repositories/introduction_media_repository.dart';
import 'package:oluko_app/routes.dart';
import 'package:video_player/video_player.dart';

class IntroductionVideo extends StatelessWidget {
  const IntroductionVideo({Key key}) : super(key: key);

  Future<ChewieController> getChewieWithVideo(BuildContext context) async {
    final mediaURL = await IntroductionMediaRepository().getIntroVideoURL();
    final VideoPlayerController videoPlayerController = VideoPlayerController.network(mediaURL);
    await videoPlayerController.initialize();
    final ChewieController chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      autoInitialize: true,
      showControls: false,
      fullScreenByDefault: true,
    );
    videoPlayerController.addListener(() {
      if (videoPlayerController != null && videoPlayerController.value.position == videoPlayerController.value.duration) {
        videoPlayerController.dispose();
        chewieController.dispose();
        Navigator.pushReplacementNamed(context, routeLabels[RouteEnum.signUp]);
      }
    });
    return chewieController;
  }

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<IntroductionMediaBloc>(context).getIntroVideo();
    return FutureBuilder<ChewieController>(
      future: getChewieWithVideo(context),
      builder: (
        BuildContext context,
        AsyncSnapshot<ChewieController> snapshot,
      ) {
        if (snapshot.hasData) {
          return Chewie(
            controller: snapshot.data,
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
