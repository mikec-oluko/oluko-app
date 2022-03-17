import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_media_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/coach_media.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/coach_media_grid_gallery.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class AboutCoachPage extends StatefulWidget {
  final String coachBannerVideo;
  const AboutCoachPage({this.coachBannerVideo});

  @override
  _AboutCoachPageState createState() => _AboutCoachPageState();
}

class _AboutCoachPageState extends State<AboutCoachPage> {
  List<CoachMedia> coachUploadedContent = [];
  ChewieController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OlukoAppBar(
        showTitle: true,
        showBackButton: true,
        title: OlukoLocalizations.get(context, 'aboutCoach'),
      ),
      body: coachMediaGalleryComponent(),
    );
  }

  Container coachMediaGalleryComponent() {
    return Container(
      width: ScreenUtils.width(context),
      height: ScreenUtils.height(context),
      color: OlukoNeumorphismColors.appBackgroundColor,
      child: BlocBuilder<CoachMediaBloc, CoachMediaState>(
        builder: (context, state) {
          if (state is CoachMediaContentUpdate) {
            coachUploadedContent = state.coachMediaContent;
          }
          if (state is CoachMediaContentSuccess) {
            coachUploadedContent = state.coachMediaContent;
          }
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              if (widget.coachBannerVideo != null)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    width: ScreenUtils.width(context),
                    height: ScreenUtils.height(context) / 4,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)), color: OlukoNeumorphismColors.appBackgroundColor),
                    child: Stack(
                      fit: StackFit.expand,
                      clipBehavior: Clip.none,
                      children: [
                        Align(child: showVideoPlayer(widget.coachBannerVideo)),
                      ],
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              CoachMediaGridGallery(
                coachMedia: coachUploadedContent,
              )
            ],
          );
        },
      ),
    );
  }

  Widget showVideoPlayer(String videoUrl) {
    List<Widget> widgets = [];
    if (_controller == null) {
      widgets.add(const Center(child: CircularProgressIndicator()));
    }
    widgets.add(OlukoNeumorphism.isNeumorphismDesign
        ? ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: OlukoVideoPlayer(
                videoUrl: videoUrl,
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
