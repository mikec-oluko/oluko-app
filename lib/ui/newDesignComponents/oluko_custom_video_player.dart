import 'package:chewie/chewie.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class OlukoCustomVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String filePath;
  final bool useConstraints;
  final bool onlyPlayer;
  final bool useOverlay;
  final bool roundedBorder;
  final bool showControls;
  final bool autoPlay;
  final bool allowFullScreen;
  final bool isOlukoControls;
  final bool showOptions;
  final bool storiesGap;
  final double aspectRatio;
  final Function(ChewieController chewieController) whenInitialized;
  final Function() onVideoFinished;
  final Function() closeVideoPlayer;
  const OlukoCustomVideoPlayer({
    this.videoUrl,
    this.filePath,
    this.useConstraints = false,
    this.onlyPlayer = false,
    this.useOverlay = false,
    this.roundedBorder = false,
    this.showControls = true,
    this.autoPlay = true,
    this.allowFullScreen = true,
    this.isOlukoControls = false,
    this.showOptions = false,
    this.storiesGap = false,
    this.aspectRatio,
    this.whenInitialized,
    this.onVideoFinished,
    this.closeVideoPlayer,
  });

  @override
  State<OlukoCustomVideoPlayer> createState() => _OlukoCustomVideoPlayerState();
}

class _OlukoCustomVideoPlayerState extends State<OlukoCustomVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    Widget playerComponent = _getVideoPlayer();
    if (widget.onlyPlayer) {
      playerComponent = _getVideoPlayer();
    }
    if (widget.useOverlay) {
      playerComponent = Stack(
        children: [_getVideoPlayer(), _getVideoOverlay()],
      );
    }
    return widget.useConstraints ? _getConstrainedBox(playerComponent) : playerComponent;
  }

  Widget _getVideoPlayer() {
    Widget _videoPlayer = OlukoVideoPlayer(
      isOlukoControls: widget.isOlukoControls,
      showOptions: widget.showOptions,
      videoUrl: widget.videoUrl,
      autoPlay: widget.autoPlay,
      useRoundBorder: widget.roundedBorder,
      whenInitialized: widget.whenInitialized,
      filePath: widget.filePath,
      aspectRatio: widget.aspectRatio,
      allowFullScreen: widget.allowFullScreen,
      showControls: widget.showControls,
      onVideoFinished: widget.onVideoFinished,
      closeVideoPlayer: widget.closeVideoPlayer,
    );
    return widget.roundedBorder
        ? ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: _videoPlayer,
          )
        : _videoPlayer;
  }

  Widget _getVideoOverlay() {
    return Visibility(
      child: Positioned(
        top: widget.storiesGap ? 25 : 15,
        right: 10,
        child: GestureDetector(
          onTap: () => widget.closeVideoPlayer(), //widget.onPlay(),
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
    );
  }

  Widget _getConstrainedBox(Widget childComponent) {
    return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).orientation == Orientation.portrait ? ScreenUtils.height(context) / 4 : ScreenUtils.height(context) / 1.5,
            minHeight: MediaQuery.of(context).orientation == Orientation.portrait ? ScreenUtils.height(context) / 4 : ScreenUtils.height(context) / 1.5),
        child: Container(height: 400, child: Stack(children: [childComponent])));
  }
}
