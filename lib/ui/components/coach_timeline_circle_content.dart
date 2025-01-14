import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_get_header_for_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CoachTimelineCircleContent extends StatefulWidget {
  const CoachTimelineCircleContent({this.circleImage, this.circleTitle, this.date, this.fileType});
  final String circleImage, circleTitle;
  final DateTime date;
  final CoachFileTypeEnum fileType;

  @override
  _CoachTimelineCircleContentState createState() => _CoachTimelineCircleContentState();
}

class _CoachTimelineCircleContentState extends State<CoachTimelineCircleContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: OlukoNeumorphismColors.appBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                            width: 70,
                            height: 70,
                            child: widget.circleImage != null
                                ? Neumorphic(
                                    style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(),
                                    child: CircleAvatar(
                                      backgroundImage: CachedNetworkImageProvider(widget.circleImage),
                                      backgroundColor: OlukoColors.randomColor(),
                                      radius: 30,
                                    ),
                                  )
                                : Neumorphic(
                                    style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(),
                                    child: CircleAvatar(
                                      backgroundColor: OlukoColors.randomColor(),
                                      radius: 30,
                                      child: Text(titleForCircle(widget.fileType),
                                          textAlign: TextAlign.center,
                                          style:
                                              OlukoFonts.olukoSmallFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500)),
                                    ),
                                  )),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(CoachHeders.getContentHeader(context: context, fileType: widget.fileType),
                                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, customFontWeight: FontWeight.w500)),
                              Text(widget.circleTitle,
                                  overflow: TextOverflow.ellipsis,
                                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, customFontWeight: FontWeight.w500)),
                            ],
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(DateFormat.jm().format(widget.date).toString(),
                          style: OlukoFonts.olukoSmallFont(customColor: OlukoColors.grayColor)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String titleForCircle(CoachFileTypeEnum fileType) {
    switch (fileType) {
      case CoachFileTypeEnum.recommendedMovement:
        return OlukoLocalizations.get(context, 'movement');
      case CoachFileTypeEnum.recommendedSegment:
        return OlukoLocalizations.get(context, 'segment');
      default:
        return '';
    }
  }
}
