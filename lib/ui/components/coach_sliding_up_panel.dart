import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_timeline_content.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'coach_timeline_panel.dart';
import 'dart:math' as math;

class CoachSlidingUpPanel extends StatefulWidget {
  const CoachSlidingUpPanel({this.content, this.timelineItemsContent});
  final Widget content;
  final List<CoachTimelineGroup> timelineItemsContent;

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
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              OlukoLocalizations.get(context, 'myTimeline'),
              style: OlukoFonts.olukoBigFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w500),
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
      ),
      borderRadius: radius,
      backdropEnabled: true,
      padding: EdgeInsets.zero,
      color: OlukoColors.black,
      minHeight: 50.0,
      panel: Container(
        decoration: BoxDecoration(
          color: OlukoColors.black,
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
          timelineContentItems: widget.timelineItemsContent,
        ),
      ),
      controller: _panelController,
      body: Container(
        color: OlukoColors.black,
        child: widget.content,
      ),
    );
  }
}
