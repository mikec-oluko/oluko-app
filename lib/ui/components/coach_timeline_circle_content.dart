import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_get_header_for_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';

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
      color: OlukoColors.black,
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
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(widget.circleImage),
                            backgroundColor: OlukoColors.black,
                            radius: 30,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(CoachHeders.getContentHeader(context: context, fileType: widget.fileType),
                                  style: OlukoFonts.olukoMediumFont(
                                      customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w500)),
                              Text(widget.circleTitle,
                                  style: OlukoFonts.olukoMediumFont(
                                      customColor: OlukoColors.white, custoFontWeight: FontWeight.w500)),
                            ],
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(DateFormat.jm().format(widget.date).toString(),
                          style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor)),
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
}
