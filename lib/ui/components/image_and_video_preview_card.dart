import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/utils/app_modal.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class ImageAndVideoPreviewCard extends StatefulWidget {
  final Image imageCover;
  final bool isVideo;
  final String videoUrl;

  ImageAndVideoPreviewCard({
    this.imageCover,
    this.videoUrl,
    this.isVideo = false,
  });

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ImageAndVideoPreviewCard> {
  ChewieController _controller;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: OlukoColors.black,
      child: Stack(children: [
        widget.imageCover,
        widget.isVideo == true
            ? Align(
                alignment: Alignment.center,
                child: TextButton(
                    onPressed: () {
                      AppModal.dialogContent(
                          closeButton: true,
                          context: context,
                          content: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: showVideoPlayer(widget.videoUrl),
                            )
                          ]);
                    },
                    child: Image.asset(
                      'assets/assessment/play.png',
                      scale: 5,
                    )))
            : Container(),
      ]),
    );
  }

  Widget showVideoPlayer(String videoUrl) {
    List<Widget> widgets = [];
    if (_controller == null) {
      widgets.add(Center(child: CircularProgressIndicator()));
    }
    widgets.add(OlukoVideoPlayer(
        videoUrl: videoUrl,
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) =>
            this.setState(() {
              _controller = chewieController;
            })));

    return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? ScreenUtils.height(context) / 4
                    : ScreenUtils.height(context) / 1.5,
            minHeight:
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? ScreenUtils.height(context) / 4
                    : ScreenUtils.height(context) / 1.5),
        child: Container(height: 400, child: Stack(children: widgets)));
  }
}
