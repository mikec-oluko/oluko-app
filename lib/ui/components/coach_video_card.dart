import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_introduction_video_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_blue_title_header.dart';
import 'package:oluko_app/utils/container_grediant.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CoachVideoCard extends StatefulWidget {
  const CoachVideoCard({this.videoUrl, this.onVideoFinished, this.onCloseCard, this.onOpenCard});

  final String videoUrl;
  final Function() onCloseCard;
  final Function() onOpenCard;
  final Function() onVideoFinished;

  @override
  _CoachVideoCardState createState() => _CoachVideoCardState();
}

class _CoachVideoCardState extends State<CoachVideoCard> {
  bool isVisible = true;
  ChewieController _controller;

  @override
  void initState() {
    setState(() {
      isVisible = true;
    });
    super.initState();
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
        return Visibility(
          visible: isVisible,
          child: SizedBox(
            child: GestureDetector(
              onTap: widget.onOpenCard ?? () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: OlukoNeumorphism.isNeumorphismDesign
                        ? OlukoBlueHeader(textContent: OlukoLocalizations.get(context, 'welcomeVideo'))
                        : Text(OlukoLocalizations.get(context, 'welcomeVideo'),
                            overflow: TextOverflow.ellipsis,
                            style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500)),
                  ),
                  Container(
                    decoration: UserInformationBackground.getContainerGradientDecoration(
                        customBorder: false, isNeumorphic: OlukoNeumorphism.isNeumorphismDesign, useGradient: true),
                    child: showVideoPlayer(videoUrl: widget.videoUrl, isForCard: true),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget showVideoPlayer({String videoUrl, bool isForCard = false}) {
    List<Widget> widgets = [];
    if (_controller == null) {
      widgets.add(const Center(child: CircularProgressIndicator()));
    }

    widgets.add(OlukoNeumorphism.isNeumorphismDesign
        ? Padding(
            padding: EdgeInsets.symmetric(horizontal: isForCard ? 0 : 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: OlukoVideoPlayer(
                  videoUrl: videoUrl,
                  autoPlay: false,
                  whenInitialized: (ChewieController chewieController) => setState(() {
                        _controller = chewieController;
                      }),
                  onVideoFinished: () => finishVideo()),
            ),
          )
        : OlukoVideoPlayer(
            videoUrl: videoUrl,
            autoPlay: false,
            whenInitialized: (ChewieController chewieController) => setState(() {
                  _controller = chewieController;
                }),
            onVideoFinished: () => finishVideo()));

    return Container(child: SizedBox(height: 180, child: Stack(children: widgets)));
  }

  finishVideo() {
    _controller.exitFullScreen();
    widget.onVideoFinished();
  }
}
