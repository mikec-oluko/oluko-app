import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_get_header_for_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';

class CoachTimelineVideoContent extends StatefulWidget {
  const CoachTimelineVideoContent({this.videoTitle, this.videoThumbnail, this.date, this.fileType});
  final String videoTitle, videoThumbnail;
  final DateTime date;
  final CoachFileTypeEnum fileType;

  @override
  _CoachTimelineVideoContentState createState() => _CoachTimelineVideoContentState();
}

class _CoachTimelineVideoContentState extends State<CoachTimelineVideoContent> {
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
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          width: 140,
                          height: 70,
                          child: Stack(
                            children: [
                              Align(
                                  child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                                          image: DecorationImage(
                                            image: NetworkImage(widget.videoThumbnail),
                                            fit: BoxFit.cover,
                                          )))),
                              Align(
                                child: SizedBox(
                                    child: Image.asset(
                                  'assets/self_recording/play_button.png',
                                  color: Colors.white,
                                  height: 30,
                                  width: 30,
                                )),
                              )
                            ],
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
                              Text(widget.videoTitle,
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
