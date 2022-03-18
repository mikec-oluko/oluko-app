import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CoachShowVideo extends StatefulWidget {
  final String videoUrl;
  final double aspectRatio;
  final String titleForContent;
  const CoachShowVideo({this.videoUrl, this.titleForContent, this.aspectRatio});

  @override
  _CoachShowVideoState createState() => _CoachShowVideoState();
}

class _CoachShowVideoState extends State<CoachShowVideo> {
  ChewieController _controller;
  bool isMentored = true;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OlukoAppBar(
        showTitle: true,
        showBackButton: true,
        title: widget.titleForContent,
        onPressed: () {
          if (_controller != null) {
            _controller.pause();
          }
        },
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: OlukoNeumorphismColors.appBackgroundColor,
        child: Stack(
          children: [
            Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                  child: showVideoPlayer(widget.videoUrl, widget.aspectRatio),
                )),
          ],
        ),
      ),
    );
  }

  Widget showVideoPlayer(String videoUrl, double aspectRatio) {
    List<Widget> widgets = [];
    if (_controller == null) {
      widgets.add(const Center(child: CircularProgressIndicator()));
    }
    widgets.add(OlukoNeumorphism.isNeumorphismDesign
        ? ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: OlukoVideoPlayer(
                videoUrl: videoUrl,
                aspectRatio: aspectRatio,
                autoPlay: false,
                whenInitialized: (ChewieController chewieController) => setState(() {
                      _controller = chewieController;
                    })),
          )
        : OlukoVideoPlayer(
            videoUrl: videoUrl,
            autoPlay: false,
            whenInitialized: (ChewieController chewieController) => setState(() {
                  _controller = chewieController;
                })));

    return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).orientation == Orientation.portrait
                ? ScreenUtils.height(context) / 4
                : ScreenUtils.height(context) / 1.5,
            minHeight: MediaQuery.of(context).orientation == Orientation.portrait
                ? ScreenUtils.height(context) / 4
                : ScreenUtils.height(context) / 1.5),
        child: Container(height: 400, child: Stack(children: widgets)));
  }
}
