import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/introduction_media_bloc.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/repositories/introduction_media_repository.dart';
import 'package:oluko_app/routes.dart';
import 'package:video_player/video_player.dart';

class IntroductionVideo extends StatefulWidget {
  IntroductionVideo({Key key}) : super(key: key);

  @override
  _IntroductionVideoState createState() => _IntroductionVideoState();
}

Future<ChewieController> getChewieWithVideo(BuildContext context) async {
  final mediaURL = await BlocProvider.of<IntroductionMediaBloc>(context).getVideo(IntroductionMediaTypeEnum.introVideo);
  if (mediaURL == null || mediaURL.isEmpty) {
    Navigator.pushReplacementNamed(context, routeLabels[RouteEnum.loginNeumorphic]);
  }
  final VideoPlayerController videoPlayerController = VideoPlayerController.network(mediaURL);
  await videoPlayerController.initialize();
  final ChewieController chewieController = ChewieController(
    videoPlayerController: videoPlayerController,
    autoPlay: true,
    autoInitialize: true,
    showControls: false,
    fullScreenByDefault: true,
  );
  videoPlayerController.addListener(() async {
    if (videoPlayerController != null &&
        videoPlayerController.value != null &&
        videoPlayerController.value.position == videoPlayerController.value.duration) {
          await videoPlayerController.dispose();
      Navigator.pushReplacementNamed(context, routeLabels[RouteEnum.loginNeumorphic]);
    }
  });
  return chewieController;
}

class _IntroductionVideoState extends State<IntroductionVideo> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChewieController>(
      future: getChewieWithVideo(context),
      builder: (
        BuildContext context,
        AsyncSnapshot<ChewieController> snapshot,
      ) {
        if (snapshot != null && snapshot.hasData && (snapshot.hasError == null || !snapshot.hasError)) {
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
