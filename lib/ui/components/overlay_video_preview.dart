import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/video_overlay.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';

class OverlayVideoPreview extends StatefulWidget {
  final String video;
  final String image;
  final List<String> randomImages;
  final bool showBackButton;
  final bool showShareButton;
  final bool showHeartButton;
  final Function() onBackPressed;
  //final Function() onSharePressed;
  //final Function() onHeartPressed;
  final List<Widget> bottomWidgets;
  final Widget audioWidget;

  const OverlayVideoPreview(
      {this.video,
      this.image,
      this.showBackButton = false,
      this.showHeartButton = false,
      this.showShareButton = false,
      this.bottomWidgets,
      this.onBackPressed,
      this.audioWidget,
      this.randomImages,
      Key key})
      : super(key: key);

  @override
  _OverlayVideoPreviewState createState() => _OverlayVideoPreviewState();
}

class _OverlayVideoPreviewState extends State<OverlayVideoPreview> {
  // ChewieController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.bottomWidgets != null ? Stack(alignment: Alignment.bottomLeft, children: [videoWithButtons()] + widget.bottomWidgets) : videoWithButtons();
  }

  Widget videoWithButtons() {
    return Stack(children: [
      ShaderMask(
        shaderCallback: (rect) {
          return const LinearGradient(
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
        padding: const EdgeInsets.only(top: OlukoNeumorphism.buttonBackPaddingFromTop, left: 15, right: 15),
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
            if (widget.audioWidget != null) widget.audioWidget,
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
          child: widget.image != null
              ? Image(
                  image: CachedNetworkImageProvider(widget.image),
                  fit: BoxFit.cover,
                )
              : widget.randomImages == null
                  ? Image.asset(
                      'assets/courses/profile_photos.png',
                      fit: BoxFit.cover,
                    )
                  : Image(
                      image: CachedNetworkImageProvider(widget.randomImages[random(0, widget.randomImages.length - 1)]),
                      fit: BoxFit.cover,
                    )),
      if (widget.video != null && widget.video != "null")
        Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (_, __, ___) => VideoOverlay(videoUrl: widget.video),
                ),
              ),
              child: Align(
                  alignment: Alignment.center,
                  child: OlukoNeumorphism.isNeumorphismDesign
                      ? Stack(alignment: Alignment.center, children: [
                          SizedBox(
                            height: 52,
                            width: 52,
                            child: OlukoBlurredButton(
                              childContent: Image.asset(
                                'assets/courses/white_play_arrow.png',
                                height: 16,
                                width: 16,
                              ),
                            ),
                          ),
                        ])
                      : Stack(alignment: Alignment.center, children: [
                          Image.asset(
                            'assets/courses/play_ellipse.png',
                            height: 46,
                            width: 46,
                          ),
                          Padding(
                              padding: const EdgeInsets.only(left: 3.5),
                              child: Image.asset(
                                'assets/courses/play_arrow.png',
                                height: 16,
                                width: 16,
                              )),
                        ])),
            ))
    ]);
  }

  int random(int min, int max) {
    var rn = new Random();
    return min + rn.nextInt(max - min);
  }
}
