import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_statistics.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class StatisticChart extends StatefulWidget {
  final CourseStatistics courseStatistics;

  StatisticChart({this.courseStatistics});

  @override
  _State createState() => _State();
}

class _State extends State<StatisticChart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: OlukoColors.listGrayColor.withOpacity(0.5),
          borderRadius: BorderRadius.all(Radius.circular(15))),
      width: ScreenUtils.width(context),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(widget.courseStatistics.doing.toString(),
                                  style: OlukoFonts.olukoSuperBigFont(
                                      custoFontWeight: FontWeight.bold)),
                              Text(
                                  ' ' +
                                      OlukoLocalizations.of(context)
                                          .find('people'),
                                  style: OlukoFonts.olukoSuperBigFont())
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                OlukoLocalizations.of(context)
                                    .find('areDoingThisCourse'),
                                style: OlukoFonts.olukoMediumFont(),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(
                                  OlukoLocalizations.of(context)
                                      .find('explore'),
                                  style: OlukoFonts.olukoMediumFont(
                                      customColor: OlukoColors.primary,
                                      decoration: TextDecoration.underline),
                                ),
                              )
                            ],
                          )
                        ]),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(children: [
                      Row(
                        children: [
                          Text(widget.courseStatistics.takingUp.toString(),
                              style: OlukoFonts.olukoSuperBigFont(
                                  custoFontWeight: FontWeight.bold)),
                          Text(
                              ' ' +
                                  OlukoLocalizations.of(context).find('people'),
                              style: OlukoFonts.olukoSuperBigFont())
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            OlukoLocalizations.of(context)
                                .find('haveTakingUpThis'),
                            style: OlukoFonts.olukoMediumFont(),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            OlukoLocalizations.of(context).find('courseSmall'),
                            style: OlukoFonts.olukoMediumFont(),
                          ),
                        ],
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(widget.courseStatistics.completed.toString(),
                                  style: OlukoFonts.olukoSuperBigFont(
                                      custoFontWeight: FontWeight.bold)),
                              Text(
                                  ' ' +
                                      OlukoLocalizations.of(context)
                                          .find('people'),
                                  style: OlukoFonts.olukoSuperBigFont())
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                OlukoLocalizations.of(context)
                                    .find('completedIt'),
                                style: OlukoFonts.olukoMediumFont(),
                              )
                            ],
                          ),
                        ]),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(children: [
                      Row(
                        children: [
                          Text(
                              widget.courseStatistics.completionRate
                                      .toString() +
                                  '%',
                              style: OlukoFonts.olukoSuperBigFont(
                                  custoFontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            OlukoLocalizations.of(context)
                                .find('completionRate'),
                            style: OlukoFonts.olukoMediumFont(),
                          )
                        ],
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
