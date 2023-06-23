import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TabContentList extends StatefulWidget {
  const TabContentList({this.contentToDisplay});
  final List<Widget> contentToDisplay;

  @override
  _TabContentListState createState() => _TabContentListState();
}

class _TabContentListState extends State<TabContentList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          physics: OlukoNeumorphism.listViewPhysicsEffect,
          padding: EdgeInsets.zero,
          children: buildContentToShow()),
    );
  }

  List<Widget> buildContentToShow() {
    List<Widget> contentToShow = [];
    setState(() {
      contentToShow.addAll(createTimelineContent(widget.contentToDisplay));
    });
    return contentToShow;
  }
}

List<Widget> createTimelineContent(List<Widget> contentToDisplay) {
  List<Widget> contentForTimelineTile = [];
  contentToDisplay.forEach((content) {
    if (contentToDisplay.indexOf(content) == 0 && contentToDisplay.length > 1) {
      contentForTimelineTile.add(Container(
        color: OlukoNeumorphismColors.appBackgroundColor,
        child: TimelineTile(
            lineXY: 0.0,
            indicatorStyle: const IndicatorStyle(width: 15, height: 15, indicatorXY: 0.0, color: OlukoColors.primary),
            beforeLineStyle: const LineStyle(thickness: 1.5, color: OlukoColors.primary),
            afterLineStyle: const LineStyle(thickness: 1.5, color: OlukoColors.primary),
            isFirst: true,
            endChild: content),
      ));
    } else if (contentToDisplay.indexOf(content) == contentToDisplay.length - 1) {
      contentForTimelineTile.add(Container(
        color: OlukoNeumorphismColors.appBackgroundColor,
        child: TimelineTile(
            lineXY: 0.0,
            isLast: true,
            indicatorStyle: const IndicatorStyle(width: 15, height: 15, indicatorXY: 0.0, color: OlukoColors.primary),
            beforeLineStyle: const LineStyle(thickness: 1.5, color: OlukoColors.primary),
            afterLineStyle: const LineStyle(thickness: 1.5, color: OlukoColors.primary),
            endChild: content),
      ));
    } else {
      contentForTimelineTile.add(Container(
        color: OlukoNeumorphismColors.appBackgroundColor,
        child: TimelineTile(
            lineXY: 0.0,
            indicatorStyle: const IndicatorStyle(width: 15, height: 15, indicatorXY: 0.0, color: OlukoColors.primary),
            beforeLineStyle: const LineStyle(thickness: 1.5, color: OlukoColors.primary),
            afterLineStyle: const LineStyle(thickness: 1.5, color: OlukoColors.primary),
            endChild: content),
      ));
    }
  });
  return contentForTimelineTile;
}
