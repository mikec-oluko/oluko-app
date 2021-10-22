import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/video_overlay.dart';

class OverlayVideoPreview extends StatefulWidget {
  final String video;
  final String image;
  final bool showBackButton;
  final bool showShareButton;
  final bool showHeartButton;
  //final Function() onSharePressed;
  //final Function() onHeartPressed;
  final List<Widget> bottomWidgets;

  OverlayVideoPreview(
      {this.video,
      this.image,
      this.showBackButton = false,
      this.showHeartButton = false,
      this.showShareButton = false,
      this.bottomWidgets,
      Key key})
      : super(key: key);

  @override
  _OverlayVideoPreviewState createState() => _OverlayVideoPreviewState();
}

class _OverlayVideoPreviewState extends State<OverlayVideoPreview> {
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
            children: [videoWithButtons()] + widget.bottomWidgets)
        : videoWithButtons();
  }

  Widget videoWithButtons() {
    return Stack(children: [
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
        padding: EdgeInsets.only(top: 15),
        child: Row(
          children: [
            widget.showBackButton
                ? IconButton(
                    icon:
                        Icon(Icons.chevron_left, size: 35, color: Colors.white),
                    onPressed: () => Navigator.pop(context))
                : SizedBox(),
            Expanded(child: SizedBox()),
            widget.showShareButton
                ? IconButton(
                    icon: Icon(Icons.share, color: OlukoColors.white),
                    onPressed: () {
                      //TODO: Add share action
                    },
                  )
                : SizedBox(),
            widget.showHeartButton
                ? Image.asset(
                    'assets/courses/heart.png',
                    scale: 4,
                  )
                : SizedBox(),
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
                )),
      if (widget.video != null && widget.video != "null")
        Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (_, __, ___) =>
                      VideoOverlay(videoUrl: widget.video),
                ),
              ),
              child: Align(
                  alignment: Alignment.center,
                  child: Stack(alignment: Alignment.center, children: [
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
}
