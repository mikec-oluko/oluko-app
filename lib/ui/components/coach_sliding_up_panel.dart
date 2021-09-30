import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_timeline_content.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'coach_timeline_panel.dart';

class CoachSlidingUpPanel extends StatefulWidget {
  const CoachSlidingUpPanel({this.content, this.timelineItemsContent});
  final Widget content;
  final List<CoachTimelineGroup> timelineItemsContent;

  @override
  _CoachSlidingUpPanelState createState() => _CoachSlidingUpPanelState();
}

class _CoachSlidingUpPanelState extends State<CoachSlidingUpPanel> {
  final PanelController _panelController = PanelController();

  BorderRadiusGeometry radius = const BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );
  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      header: Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            OlukoLocalizations.of(context).find('myTimeline'),
            style: OlukoFonts.olukoBigFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
          ),
        ),
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
