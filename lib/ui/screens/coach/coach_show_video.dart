import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CoachShowVideo extends StatefulWidget {
  final String videoUrl;
  final String titleForContent;
  const CoachShowVideo({this.videoUrl, this.titleForContent});

  @override
  _CoachShowVideoState createState() => _CoachShowVideoState();
}

class _CoachShowVideoState extends State<CoachShowVideo> {
  ChewieController _controller;
  bool isMentored = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.titleForContent,
          style: OlukoFonts.olukoTitleFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
        ),
        elevation: 0.0,
        backgroundColor: OlukoColors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: OlukoColors.black,
        child: Stack(
          children: [
            Align(alignment: Alignment.center, child: showVideoPlayer(widget.videoUrl)),
          ],
        ),
      ),
    );
  }

  Widget showVideoPlayer(String videoUrl) {
    List<Widget> widgets = [];
    if (_controller == null) {
      //widgets.add(Center(child: CircularProgressIndicator()));
    }
    widgets.add(OlukoVideoPlayer(
        videoUrl: videoUrl,
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) => this.setState(() {
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
