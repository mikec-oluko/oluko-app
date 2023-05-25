import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_timeline_content.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'coach_timeline_panel.dart';
import 'dart:math' as math;

class CoachSlidingUpPanel extends StatefulWidget {
  const CoachSlidingUpPanel({this.content, this.timelineItemsContent, this.isIntroductionVideoComplete, this.currentUser, this.onCurrentUserSelected});
  final bool isIntroductionVideoComplete;
  final Widget content;
  final List<CoachTimelineGroup> timelineItemsContent;
  final UserResponse currentUser;
  final Function() onCurrentUserSelected;

  @override
  _CoachSlidingUpPanelState createState() => _CoachSlidingUpPanelState();
}

class _CoachSlidingUpPanelState extends State<CoachSlidingUpPanel> {
  final PanelController _panelController = PanelController();

  bool isPanelOpen = true;
  BorderRadiusGeometry radius = const BorderRadius.only(
    topLeft: Radius.circular(30.0),
    topRight: Radius.circular(30.0),
  );
  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      header: OlukoNeumorphism.isNeumorphismDesign ? neumorphicTimelineHeader(context) : timelineHeader(context),
      borderRadius: radius,
      backdropEnabled: true,
      padding: EdgeInsets.zero,
      color: OlukoNeumorphismColors.appBackgroundColor,
      minHeight: 80,
      panel: Container(
        decoration: BoxDecoration(
          color: OlukoNeumorphismColors.appBackgroundColor,
          borderRadius: radius,
          gradient: const LinearGradient(
              colors: [OlukoColors.grayColorFadeTop, OlukoColors.grayColorFadeBottom],
              stops: [0.0, 1],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        width: MediaQuery.of(context).size.width,
        height: 300,
        child: CoachTimelinePanel(
          isIntroductionVideoComplete: widget.isIntroductionVideoComplete,
          currentUser: widget.currentUser,
          onCurrentUserSelected: widget.onCurrentUserSelected,
        ),
      ),
      controller: _panelController,
      body: Container(
        color: OlukoNeumorphismColors.appBackgroundColor,
        child: widget.content,
      ),
    );
  }

  Row timelineHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            OlukoLocalizations.get(context, 'myActivityHistory'),
            style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 250),
        IconButton(
            onPressed: () {
              if (_panelController.isPanelOpen) {
                _panelController.close();
                setState(() {
                  isPanelOpen = true;
                });
              } else {
                _panelController.open();
                setState(() {
                  isPanelOpen = false;
                });
              }
            },
            icon: isPanelOpen
                ? Stack(
                    children: [
                      Image.asset(
                        'assets/courses/white_arrow_up.png',
                        scale: 3,
                      ),
                      Positioned(
                        top: 4,
                        child: Image.asset(
                          'assets/courses/grey_arrow_up.png',
                          scale: 3,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      Transform.rotate(
                          angle: 180 * math.pi / 180,
                          child: Image.asset(
                            'assets/courses/white_arrow_up.png',
                            scale: 3,
                          )),
                      Positioned(
                        top: -4,
                        child: Transform.rotate(
                          angle: 180 * math.pi / 180,
                          child: Image.asset(
                            'assets/courses/grey_arrow_up.png',
                            scale: 3,
                          ),
                        ),
                      ),
                    ],
                  ))
      ],
    );
  }

  Widget neumorphicTimelineHeader(BuildContext context) {
    return Container(
      width: ScreenUtils.width(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              if (_panelController.isPanelOpen) {
                _panelController.close();
                setState(() {
                  isPanelOpen = true;
                });
              } else {
                _panelController.open();
                setState(() {
                  isPanelOpen = false;
                });
              }
            },
            child: Center(
              child: Container(
                width: 50,
                height: 10,
                child: Image.asset('assets/courses/horizontal_vector.png', scale: 2, color: OlukoColors.grayColor),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 10),
            child: Text(
              OlukoLocalizations.get(context, 'activityHistory'),
              style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
