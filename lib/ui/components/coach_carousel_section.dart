import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_introduction_video_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CoachCarouselSliderSection extends StatefulWidget {
  const CoachCarouselSliderSection({this.contentForCarousel, this.introductionCompleted, this.introductionVideo, this.onVideoFinished});
  final List<Widget> contentForCarousel;
  final String introductionVideo;
  final bool introductionCompleted;
  final Function() onVideoFinished;

  @override
  _CoachCarouselSliderSectionState createState() => _CoachCarouselSliderSectionState();
}

class _CoachCarouselSliderSectionState extends State<CoachCarouselSliderSection> {
  ChewieController _controller;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoachIntroductionVideoBloc, CoachIntroductionVideoState>(
      builder: (context, state) {
        if (state is CoachIntroductionVideoPause) {
          if (state.pauseVideo && _controller != null) {
            _controller.pause();
          }
        }
        return Container(
          color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : Colors.black,
          width: MediaQuery.of(context).size.width,
          height: 250,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              if (widget.introductionCompleted != null && widget.introductionCompleted)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: widget.contentForCarousel.isNotEmpty
                      ? CarouselSlider(
                          items: widget.contentForCarousel,
                          options: CarouselOptions(
                              height: 250.0, autoPlay: true, autoPlayInterval: const Duration(seconds: 5), enlargeCenterPage: true),
                        )
                      : const SizedBox.shrink(),
                )
              else
                Align(child: showVideoPlayer(widget.introductionVideo)),
            ],
          ),
        );
      },
    );
  }

  Widget showVideoPlayer(String videoUrl) {
    List<Widget> widgets = [];
    if (_controller == null) {
      widgets.add(const Center(child: CircularProgressIndicator()));
    }

    widgets.add(OlukoVideoPlayer(
        videoUrl: videoUrl,
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) => setState(() {
              _controller = chewieController;
            }),
        onVideoFinished: widget.onVideoFinished));

    return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).orientation == Orientation.portrait
                ? ScreenUtils.height(context) / 4
                : ScreenUtils.height(context) / 1.5,
            minHeight: MediaQuery.of(context).orientation == Orientation.portrait
                ? ScreenUtils.height(context) / 4
                : ScreenUtils.height(context) / 1.5),
        child: SizedBox(height: 400, child: Stack(children: widgets)));
  }
}
