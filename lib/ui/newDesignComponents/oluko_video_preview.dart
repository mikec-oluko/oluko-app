import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/ui/components/selfies_grid.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_back_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/utils/collage_utils.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:video_player/video_player.dart';

class OlukoVideoPreview extends StatefulWidget {
  final String video;
  final String image;
  final bool showCrossButton;
  final List<String> randomImages;
  final bool bannerVideo;
  final bool showBackButton;
  final bool showShareButton;
  final bool showHeartButton;
  final bool showVideoOptions;
  final bool fromHomeContent;
  final Function() onBackPressed;
  final Function() onPlay;
  //final Function() onSharePressed;
  //final Function() onHeartPressed;
  final List<Widget> bottomWidgets;
  final bool videoVisibilty;
  final Widget audioWidget;
  final bool bigPlayButton;

  OlukoVideoPreview(
      {this.video,
      this.image,
      this.showBackButton = false,
      this.showHeartButton = false,
      this.showShareButton = false,
      this.bottomWidgets,
      this.onBackPressed,
      this.randomImages,
      Key key,
      this.onPlay,
      this.videoVisibilty = false,
      this.bannerVideo = false,
      this.audioWidget,
      this.showVideoOptions = false,
      this.fromHomeContent = false,
      this.showCrossButton = true,
      this.bigPlayButton = false})
      : super(key: key);

  @override
  _OlukoVideoPreviewState createState() => _OlukoVideoPreviewState();
}

class _OlukoVideoPreviewState extends State<OlukoVideoPreview> {
  ChewieController _controller;
  double aspectRatio;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.bottomWidgets != null
        ? Stack(
            alignment: Alignment.bottomLeft,
            children: [videoWithButtons()] +
                [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.bottomWidgets,
                  )
                ])
        : videoWithButtons();
  }

  Widget videoWithButtons() {
    return Stack(children: [
      if (widget.videoVisibilty && widget.bottomWidgets == null)
        videoSection()
      else
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
                  ? OlukoNeumorphicCircleButton(
                      onPressed: widget.onBackPressed,
                    )
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
    if (widget.bannerVideo) {
      return Stack(alignment: Alignment.center, children: [
        AspectRatio(
            aspectRatio: 5 / 3,
            child: Container(
                color: OlukoColors.white,
                child: widget.image != null
                    ? imageSection()
                    : widget.bannerVideo
                        ? imageSection()
                        : SelfiesGrid(images: widget.randomImages))),
        if (widget.video != null)
          AspectRatio(
            aspectRatio: 5 / 3,
            child: Padding(
                padding: EdgeInsets.only(bottom: widget.videoVisibilty ? 0 : 16),
                child: GestureDetector(
                  onTap: () => widget.onPlay(),
                  child: Align(
                      child: Stack(children: [
                    if (widget.videoVisibilty)
                      showVideoPlayer(widget.video)
                    else
                      SizedBox(
                        height: 52,
                        width: 52,
                        child: OlukoBlurredButton(
                          childContent: Image.asset(
                            'assets/courses/white_play.png',
                            scale: 3.5,
                          ),
                        ),
                      ),
                  ])),
                )),
          )
      ]);
    } else {
      return BlocBuilder<VideoBloc, VideoState>(
        builder: (context, state) {
          if (state is VideoSuccess && state.aspectRatio != null) {
            aspectRatio = state.aspectRatio;
          }
          return Stack(alignment: Alignment.center, children: [
            AspectRatio(
                aspectRatio: 347 / 520,
                child: Container(
                    color: OlukoColors.white,
                    child: widget.image != null
                        ? imageSection()
                        : widget.bannerVideo
                            ? imageSection()
                            : SelfiesGrid(images: widget.randomImages))),
            if (widget.video != null)
              Padding(
                  padding: EdgeInsets.only(bottom: widget.videoVisibilty ? 0 : 16),
                  child: GestureDetector(
                    onTap: () => widget.onPlay(),
                    child: Align(
                        child: Stack(children: [
                      if (aspectRatio == null && widget.videoVisibilty)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else if (widget.videoVisibilty)
                        AspectRatio(aspectRatio: aspectRatio, child: showVideoPlayer(widget.video))
                      else
                        SizedBox(
                          height: widget.bigPlayButton ? 82 : 52,
                          width: widget.bigPlayButton ? 82 : 52,
                          child: OlukoBlurredButton(
                            childContent: Image.asset(
                              'assets/courses/white_play.png',
                              scale: widget.bigPlayButton ? 2 : 3.5,
                            ),
                          ),
                        ),
                    ])),
                  )),
          ]);
        },
      );
    }
  }

  Widget buttonBack(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height / 10,
      left: 20,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
                color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDarker,
                width: 52,
                height: 52,
                child: Image.asset(
                  'assets/courses/left_back_arrow.png',
                  scale: 3.5,
                )),
          )),
    );
  }

  Widget showVideoPlayer(String videoUrl) {
    List<Widget> widgets = [];
    if (_controller == null) {
      widgets.add(const Center(child: CircularProgressIndicator()));
    }
    widgets.add(
      OlukoVideoPlayer(
        showOptions: widget.showVideoOptions,
        closeVideoPlayer: () => widget.onPlay(),
        isOlukoControls: true,
        videoUrl: videoUrl,
        whenInitialized: (ChewieController chewieController) => setState(() {
          _controller = chewieController;
        }),
      ),
    );
    return Container(
      color: OlukoColors.black,
      child: Stack(
        children: widgets +
            [
              Visibility(
                visible: widget.showCrossButton,
                child: Positioned(
                  top: ScreenUtils.height(context) * 0.07,
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
      ),
    );
  }

  Widget imageSection() {
    return widget.image != null
        ? Image(
            image: CachedNetworkImageProvider(widget.image),
            fit: BoxFit.cover,
          )
        : widget.randomImages == null
            ? Image.asset(
                widget.bannerVideo ? 'assets/home/mvtthumbnail.png' : 'assets/courses/profile_photos.png',
                fit: BoxFit.cover,
              )
            : Image(
                image: CachedNetworkImageProvider(widget.randomImages[random(0, widget.randomImages.length - 1)]),
                fit: BoxFit.cover,
              );
  }

  int random(int min, int max) {
    var rn = new Random();
    return min + rn.nextInt(max - min);
  }
}
