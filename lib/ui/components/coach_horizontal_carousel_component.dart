import 'package:flutter/material.dart';

class CoachHorizontalCarousel extends StatefulWidget {
  final bool isForVideoContent;
  final bool isAssessmentContent;
  final List<Widget> contentToDisplay;
  const CoachHorizontalCarousel(
      {this.contentToDisplay,
      this.isForVideoContent = false,
      this.isAssessmentContent = false});

  @override
  _CoachHorizontalCarouselState createState() =>
      _CoachHorizontalCarouselState();
}

class _CoachHorizontalCarouselState extends State<CoachHorizontalCarousel> {
  @override
  Widget build(BuildContext context) {
    Widget contentToReturn;
    if (widget.isForVideoContent) {
      contentToReturn = Container(
        color: Colors.black,
        width: MediaQuery.of(context).size.width,
        height: 150,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.contentToDisplay,
              ),
            )
          ],
        ),
      );
    } else if (widget.isAssessmentContent) {
      contentToReturn = Container(
          color: Colors.black,
          width: MediaQuery.of(context).size.width,
          height: 200,
          child: ListView(
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
          color: Colors.black,
          width: MediaQuery.of(context).size.width,
          height: 120,
          child: ListView(
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