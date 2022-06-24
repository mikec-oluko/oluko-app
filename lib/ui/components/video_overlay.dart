import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class VideoOverlay extends StatefulWidget {
  final String videoUrl;
  final Function() onPlay;
  final bool autoPlay;
  final bool isOlukoControls;
  VideoOverlay(
      {this.videoUrl,
      this.onPlay,
      Key key,
      this.autoPlay = false,
      this.isOlukoControls = false,
      })
      : super(key: key);

  @override
  _VideoOverlayState createState() => _VideoOverlayState();
}

class _VideoOverlayState extends State<VideoOverlay> {
  ChewieController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (OlukoNeumorphism.isNeumorphismDesign && widget.isOlukoControls) {
      return Scaffold(backgroundColor:OlukoColors.black, body: showVideoPlayer(widget.videoUrl));
    } else {
      return Scaffold(
          backgroundColor: OlukoColors.black.withOpacity(0.5),
          body: Stack(
            children: [
              Positioned(top: ScreenUtils.height(context) / 4, left: 0, right: 0, child: showVideoPlayer(widget.videoUrl)),
              Positioned(
                  bottom: ScreenUtils.height(context) / 6,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      'assets/courses/video_cross.png',
                      color: Colors.white,
                      height: 60,
                      width: 60,
                    ),
                  )),
            ],
          ));
    }
  }

  Widget showVideoPlayer(String videoUrl) {
    List<Widget> widgets = [];
    if (_controller == null) {
      widgets.add(const Center(child: CircularProgressIndicator()));
    }
    if (OlukoNeumorphism.isNeumorphismDesign && widget.isOlukoControls) {
      widgets.add(
        OlukoVideoPlayer(
          isOlukoControls: widget.isOlukoControls,
          videoUrl:videoUrl,
          autoPlay: widget.autoPlay,
          whenInitialized: (ChewieController chewieController) => setState(() {
            _controller = chewieController;
          }),
        ),
      );
      return Stack(
        children: widgets +
            [
              Visibility(
                child: Positioned(
                  top: 25,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => widget.onPlay(),
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
              )
            ],
      );
    } else {
      widgets.add(
        OlukoVideoPlayer(
          videoUrl: videoUrl,
          autoPlay: false,
          whenInitialized: (ChewieController chewieController) => setState(() {
            _controller = chewieController;
          }),
        ),
      );

      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).orientation == Orientation.portrait
              ? ScreenUtils.height(context) / 4
              : ScreenUtils.height(context) / 1.5,
          minHeight: MediaQuery.of(context).orientation == Orientation.portrait
              ? ScreenUtils.height(context) / 4
              : ScreenUtils.height(context) / 1.5,
        ),
        child: SizedBox(height: 400, child: Stack(children: widgets)),
      );
    }
  }
}
