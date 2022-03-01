import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_media_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/coach_media.dart';
import 'package:oluko_app/models/coach_user.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/carousel_small_section.dart';
import 'package:oluko_app/ui/components/image_and_video_container.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/utils/screen_utils.dart';

import '../../../routes.dart';

class AboutCoachPage extends StatefulWidget {
  // final CoachUser coachUser;
  // const AboutCoachPage({this.coachUser});
  const AboutCoachPage();

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
        title: 'About Coach',
        actions: [],
      ),
      body: coachMediaGalleryComponent(),
    );
  }

  Container coachMediaGalleryComponent() {
    return Container(
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
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  width: ScreenUtils.width(context),
                  height: ScreenUtils.height(context) / 4,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: OlukoNeumorphismColors.appBackgroundColor),
                  child: Stack(
                    fit: StackFit.expand,
                    clipBehavior: Clip.none,
                    children: [
                      Align(child: showVideoPlayer(coachUploadedContent[1].video.url)),
                    ],
                  ),
                ),
              ),
              Container(
                width: ScreenUtils.width(context),
                height: ScreenUtils.height(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemCount: coachUploadedContent.length,
                      itemBuilder: (context, index) => Card(
                            color: Colors.transparent,
                            child: ImageAndVideoContainer(
                                backgroundImage: coachUploadedContent[index].video.thumbUrl,
                                isContentVideo: true,
                                videoUrl: coachUploadedContent[index].video.url,
                                displayOnViewNamed: ActualProfileRoute.transformationJourney,
                                originalContent: coachUploadedContent[index],
                                isCoachMediaContent: true),
                          )),
                ),
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
