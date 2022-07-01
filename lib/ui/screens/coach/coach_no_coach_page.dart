import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

import '../../../routes.dart';

class NoCoachPage extends StatefulWidget {
  final String introductionVideo;
  const NoCoachPage({this.introductionVideo});

  @override
  _NoCoachPageState createState() => _NoCoachPageState();
}

class _NoCoachPageState extends State<NoCoachPage> {
  ChewieController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OlukoAppBar(
        showTitle: OlukoNeumorphism.isNeumorphismDesign ? true : false,
        title: OlukoLocalizations.get(context, 'coach'),
        showBackButton: OlukoNeumorphism.isNeumorphismDesign ? false : true,
        onPressed: () => Navigator.pushNamed(context, routeLabels[RouteEnum.root]),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: OlukoNeumorphismColors.appBackgroundColor,
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Container(
              color: OlukoNeumorphismColors.appBackgroundColor,
              width: MediaQuery.of(context).size.width,
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  Align(
                      child: Padding(
                    padding: OlukoNeumorphism.isNeumorphismDesign ? const EdgeInsets.symmetric(horizontal: 20.0) : EdgeInsets.zero,
                    child: showVideoPlayer(widget.introductionVideo),
                  )),
                ],
              ),
            ),
            Container(
                color: OlukoNeumorphismColors.appBackgroundColor,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    SizedBox(
                      height: 80,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, routeLabels[RouteEnum.profileHelpAndSupport]);
                        _controller.pause();
                      },
                      child: Text(
                        OlukoLocalizations.get(context, 'tapHere'),
                        textAlign: TextAlign.center,
                        style: OlukoFonts.olukoSubtitleFont(customColor: OlukoColors.primary, customFontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(
                      height: OlukoNeumorphism.isNeumorphismDesign ? 20 : 0,
                    ),
                    Text(
                      OlukoLocalizations.get(context, 'noCoachMessage'),
                      textAlign: TextAlign.center,
                      style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w500),
                    ),
                  ],
                )),
          ],
        ),
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
                isOlukoControls: true,
                showOptions: true,
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
