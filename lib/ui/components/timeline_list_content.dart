import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimelineListContent extends StatefulWidget {
  const TimelineListContent({this.content, this.newDate});
  final List<Widget> content;
  final String newDate;

  @override
  _TimelineListContentState createState() => _TimelineListContentState();
}

class _TimelineListContentState extends State<TimelineListContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: OlukoColors.black,
      child: TimelineTile(
        indicatorStyle: IndicatorStyle(width: 15, height: 15, indicatorXY: 0.0),
        beforeLineStyle: LineStyle(thickness: 2),
        afterLineStyle: LineStyle(thickness: 2),
        endChild: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(widget.newDate ?? OlukoLocalizations.get(context, 'todayCapitalMessage'),
                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500)),
          ),
          Column(children: widget.content)
        ]),
      ),
    );
  }
}
