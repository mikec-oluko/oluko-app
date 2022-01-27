import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_get_header_for_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class CoachTimelineCardContent extends StatefulWidget {
  const CoachTimelineCardContent({this.cardTitle, this.cardSubTitle, this.cardImage, this.date, this.fileType});
  final String cardTitle, cardSubTitle, cardImage;
  final DateTime date;
  final CoachFileTypeEnum fileType;

  @override
  _CoachTimelineCardContentState createState() => _CoachTimelineCardContentState();
}

class _CoachTimelineCardContentState extends State<CoachTimelineCardContent> {
  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: OlukoNeumorphismColors.appBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Wrap(
          children: [
            Row(
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 140,
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(5)),
                              image: DecorationImage(
                                image: NetworkImage(widget.cardImage),
                                fit: BoxFit.cover,
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(DateFormat.jm().format(widget.date).toString(),
                              style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor)),
                        ),
                      ],
                    )
                  ],
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(CoachHeders.getContentHeader(context: context, fileType: widget.fileType),
                            style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w500)),
                        Text(widget.cardTitle,
                            style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500)),
                        const SizedBox(height: 10),
                        Text(
                            widget.fileType == CoachFileTypeEnum.recommendedClass
                                ? OlukoLocalizations.of(context).find('timelineCourse')
                                : widget.fileType == CoachFileTypeEnum.recommendedCourse
                                    ? OlukoLocalizations.of(context).find('classes')
                                    : '',
                            style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor, custoFontWeight: FontWeight.w500)),
                        Text(widget.cardSubTitle,
                            overflow: TextOverflow.ellipsis,
                            style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
