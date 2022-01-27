import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/video_overlay.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class OlukoVideoPreview extends StatefulWidget {
  final String video;
  final String image;
  final bool showBackButton;
  final bool showShareButton;
  final bool showHeartButton;
  final Function() onBackPressed;
  final Function() onPlay;
  //final Function() onSharePressed;
  //final Function() onHeartPressed;
  final List<Widget> bottomWidgets;
  final bool videoVisibilty;
  final Widget audioWidget;
  OlukoVideoPreview(
      {this.video,
      this.image,
      this.showBackButton = false,
      this.showHeartButton = false,
      this.showShareButton = false,
      this.bottomWidgets,
      this.onBackPressed,
      Key key,
      this.onPlay,
      this.videoVisibilty = false,
      this.audioWidget})
      : super(key: key);

  @override
  _OlukoVideoPreviewState createState() => _OlukoVideoPreviewState();
}

class _OlukoVideoPreviewState extends State<OlukoVideoPreview> {
  ChewieController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.bottomWidgets != null
        ? Stack(
            alignment: Alignment.bottomLeft,
            children: [videoWithButtons()] +
                [
                  Visibility(
                      visible: !widget.videoVisibilty,
                      child: Column(
                        children: widget.bottomWidgets,
                      ))
                ])
        : videoWithButtons();
  }

  Widget videoWithButtons() {
    return Stack(children: [
      if (widget.videoVisibilty)
        videoSection()
      else
        ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.transparent],
            ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
          },
          blendMode: BlendMode.dstIn,
          child: videoSection(),
        ),
      topButtons(),
    ]);
  }

  Widget topButtons() {
    return Padding(
        padding: const EdgeInsets.only(top: 25, left: 15, right: 15),
        child: Row(
          children: [
            if (OlukoNeumorphism.isNeumorphismDesign)
              widget.showBackButton
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: GestureDetector(
                        onTap: () => widget.onBackPressed != null ? widget.onBackPressed() : Navigator.pop(context),
                        child: Container(
                            color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDarker,
                            width: 52,
                            height: 52,
                            child: Image.asset(
                              'assets/courses/left_back_arrow.png',
                              scale: 3.5,
                            )),
                      )) /*IconButton(
                    icon: Icon(Icons.chevron_left, size: 35, color: Colors.white),
                    onPressed: () => widget.onBackPressed != null ? widget.onBackPressed() : Navigator.pop(context)) */
                  : const SizedBox()
            else if (widget.showBackButton)
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 35, color: Colors.white),
                onPressed: () => widget.onBackPressed != null ? widget.onBackPressed() : Navigator.pop(context),
              )
            else
              const SizedBox(),
            const Expanded(child: SizedBox()),
            if (widget.audioWidget != null && !widget.videoVisibilty) widget.audioWidget,
            if (widget.showShareButton)
              IconButton(
                icon: const Icon(Icons.share, color: OlukoColors.white),
                onPressed: () {
                  //TODO: Add share action
                },
              )
            else
              const SizedBox(),
            if (widget.showHeartButton)
              Image.asset(
                'assets/courses/heart.png',
                scale: 4,
              )
            else
              const SizedBox(),
          ],
        ));
  }

  Widget videoSection() {
    return Stack(alignment: Alignment.center, children: [
      AspectRatio(
        aspectRatio: 1,
        child: widget.image == null
            ? Image.asset(
                'assets/courses/profile_photos.png',
                fit: BoxFit.cover,
              )
            : Image.network(
                widget.image,
                fit: BoxFit.cover,
              ),
      ),
      if (widget.video != null && widget.video != "null")
        Padding(
            padding: EdgeInsets.only(bottom: widget.videoVisibilty ? 0 : 16),
            child: GestureDetector(
              onTap: () => widget.onPlay(),
              child: Align(
                  child: Stack(alignment: Alignment.center, children: [
                Visibility(
                    visible: widget.videoVisibilty,
                    child: SizedBox(
                        width: ScreenUtils.width(context),
                        height: ScreenUtils.height(context) / 2,
                        child: VideoOverlay(
                          isOlukoControls: true,
                          autoPlay: true,
                          videoUrl: widget.video,
                          onPlay: widget.onPlay,
                        ))),
                Visibility(
                    visible: !widget.videoVisibilty,
                    child: Container(
                      height: 52,
                      width: 52,
                      child: OlukoBlurredButton(
                        childContent: Image.asset(
                          'assets/courses/white_play.png',
                          scale: 3.5,
                        ),
                      ),
                    ))
              ])),
            ))
    ]);
  }
}
