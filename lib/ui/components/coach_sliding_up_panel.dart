import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class CoachSlidingUpPanel extends StatefulWidget {
  final Widget content;
  const CoachSlidingUpPanel({this.content});

  @override
  _CoachSlidingUpPanelState createState() => _CoachSlidingUpPanelState();
}

class _CoachSlidingUpPanelState extends State<CoachSlidingUpPanel> {
  final PanelController _panelController = new PanelController();

  BorderRadiusGeometry radius = BorderRadius.only(
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
            style: OlukoFonts.olukoBigFont(
                customColor: OlukoColors.grayColor,
                custoFontWeight: FontWeight.w500),
          ),
        ),
      ),
      borderRadius: radius,
      backdropEnabled: true,
      isDraggable: true,
      margin: const EdgeInsets.all(0),
      backdropTapClosesPanel: true,
      padding: EdgeInsets.zero,
      color: OlukoColors.black,
      minHeight: 50.0,
      maxHeight: 500,
      panel: Container(
        decoration: BoxDecoration(
          color: OlukoColors.grayColor,
          borderRadius: radius,
          gradient: LinearGradient(colors: [
            OlukoColors.grayColorFadeTop,
            OlukoColors.grayColorFadeBottom
          ], stops: [
            0.0,
            1
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        width: MediaQuery.of(context).size.width,
        height: 300,
      ),
      defaultPanelState: PanelState.CLOSED,
      controller: _panelController,
      body: Container(
        color: Colors.black,
        child: widget.content,
      ),
    );
  }
}
