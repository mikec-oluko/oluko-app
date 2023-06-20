import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';

class CoachHorizontalCarousel extends StatefulWidget {
  final bool isForVideoContent;
  final bool isAssessmentContent;
  final List<Widget> contentToDisplay;
  const CoachHorizontalCarousel({this.contentToDisplay, this.isForVideoContent = false, this.isAssessmentContent = false});

  @override
  _CoachHorizontalCarouselState createState() => _CoachHorizontalCarouselState();
}

class _CoachHorizontalCarouselState extends State<CoachHorizontalCarousel> {
  @override
  Widget build(BuildContext context) {
    Widget contentToReturn;
    if (widget.isForVideoContent) {
      contentToReturn = Container(
        color: OlukoNeumorphismColors.appBackgroundColor,
        width: MediaQuery.of(context).size.width,
        height: 155,
        child: ListView(
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          physics: OlukoNeumorphism.listViewPhysicsEffect,
          scrollDirection: Axis.horizontal,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: widget.contentToDisplay,
              ),
            )
          ],
        ),
      );
    } else if (widget.isAssessmentContent) {
      contentToReturn = Container(
          color: OlukoColors.black,
          width: MediaQuery.of(context).size.width,
          height: 200,
          child: ListView(
              physics: OlukoNeumorphism.listViewPhysicsEffect,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                Wrap(
                  children: widget.contentToDisplay,
                )
              ]));
    } else {
      contentToReturn = Container(
          color: OlukoNeumorphismColors.appBackgroundColor,
          width: MediaQuery.of(context).size.width,
          height: 120,
          child: ListView(
              physics: OlukoNeumorphism.listViewPhysicsEffect,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                Wrap(children: widget.contentToDisplay),
              ]));
    }
    return contentToReturn;
  }
}
