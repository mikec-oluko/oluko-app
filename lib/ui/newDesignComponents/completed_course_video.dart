import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/introduction_media_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/repositories/introduction_media_repository.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:video_player/video_player.dart';

import '../../helpers/video_player_helper.dart';

class CompletedCourseVideo extends StatefulWidget {
  const CompletedCourseVideo({Key key, this.mediaURL, this.file, this.isDownloaded}) : super(key: key);
  final String mediaURL;
  final File file;
  final bool isDownloaded;

  @override
  _CompletedCourseVideoState createState() => _CompletedCourseVideoState();
}

class _CompletedCourseVideoState extends State<CompletedCourseVideo> {
  VideoPlayerController _videoPlayerController;

  @override
  void dispose() {
    pauseAndDisposeVideoController();
    super.dispose();
  }

  Future<ChewieController> getChewieWithVideo(BuildContext context) async {
    if (widget.isDownloaded) {
      _videoPlayerController = VideoPlayerController.file(widget.file);
    } else {
      VideoPlayerController.network(widget.mediaURL);
    }

    await _videoPlayerController.initialize();
    final ChewieController chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      autoInitialize: true,
      showControls: false,
      fullScreenByDefault: true,
    );
    _videoPlayerController.addListener(() async {
      if (_videoPlayerController != null &&
          _videoPlayerController.value != null &&
          _videoPlayerController.value.position == _videoPlayerController.value.duration) {
        await pauseAndDisposeVideoController();
        if (Navigator.canPop(context)) {
          Navigator.popUntil(context, ModalRoute.withName(routeLabels[RouteEnum.root]));
          Navigator.pushReplacementNamed(context, routeLabels[RouteEnum.root]);
        }
      }
    });

    return chewieController;
  }

  Future<void> pauseAndDisposeVideoController() async {
    if (_videoPlayerController != null) {
      _videoPlayerController.pause();
      await _videoPlayerController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_videoPlayerController != null) {
          pauseAndDisposeVideoController();
        }
        return true;
      },
      child: FutureBuilder<ChewieController>(
        future: getChewieWithVideo(context),
        builder: (
          BuildContext context,
          AsyncSnapshot<ChewieController> snapshot,
        ) {
          if (snapshot != null && snapshot.hasData && (snapshot.hasError == null || !snapshot.hasError)) {
            return Stack(children: [
              Chewie(
                controller: snapshot.data,
              ),
              Positioned(
                top: OlukoNeumorphism.buttonBackPaddingFromTop,
                right: 10,
                child: GestureDetector(
                  onTap: () async {
                    if (_videoPlayerController != null && Navigator.canPop(context)) {
                      pauseAndDisposeVideoController();
                      Navigator.popUntil(context, ModalRoute.withName(routeLabels[RouteEnum.root]));
                      Navigator.pushReplacementNamed(context, routeLabels[RouteEnum.root]);
                    }
                  },
                  child: SizedBox(
                    height: 46,
                    width: 46,
                    child: OlukoBlurredButton(
                      childContent: Image.asset(
                        'assets/courses/white_cross.png',
                        scale: 3.5,
                      ),
                    ),
                  ),
                ),
              ),
            ]);
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
