import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/services/course_enrollment_service.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class ClassSection extends StatefulWidget {
  final Class classObj;
  final int index;
  final int total;
  final double classProgress;
  final Function() onPressed;
  final bool isCourseEnrolled;

  const ClassSection({this.classObj, this.index, this.total, this.classProgress = 0, this.onPressed, this.isCourseEnrolled = false});

  @override
  _State createState() => _State();
}

class _State extends State<ClassSection> {
  @override
  Widget build(BuildContext context) {
    bool isStarted = widget.classProgress > 0;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Container(
        decoration: OlukoNeumorphism.isNeumorphismDesign
            ? BoxDecoration(
                color: widget.isCourseEnrolled
                    ? isStarted
                        ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDarker
                        : Colors.white
                    : Colors.black,
                borderRadius: const BorderRadius.all(Radius.circular(25)),
              )
            : BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
        child: OlukoNeumorphism.isNeumorphismDesign
            ? Column(
                children: [
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: widget.isCourseEnrolled
                              ? BorderRadius.only(bottomLeft: (Radius.circular(22)), topLeft: (Radius.circular(22)))
                              : const BorderRadius.all(Radius.circular(10)),
                          child: Image.network(
                            widget.classObj.image,
                            height: 100,
                            width: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          child: widget.isCourseEnrolled
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.only(left: 15.0, bottom: 5, top: 15),
                                        child: Text(
                                          "${OlukoLocalizations.get(context, 'class')} ${widget.index + 1}",
                                          style: OlukoFonts.olukoSmallFont(
                                              custoFontWeight: FontWeight.bold,
                                              customColor: isStarted ? OlukoColors.yellow : OlukoColors.black),
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 15.0, top: 0, bottom: 10, right: 10),
                                      child: Text(
                                        widget.classObj.name,
                                        style: OlukoFonts.olukoMediumFont(
                                            custoFontWeight: FontWeight.w500,
                                            customColor: isStarted ? OlukoColors.yellow : OlukoColors.grayColor),
                                      ),
                                    ),
                                    widget.classProgress == 1
                                        ? SizedBox()
                                        : Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 15),
                                            child: CourseProgressBar(isStartedClass: isStarted, value: widget.classProgress),
                                          )
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 15.0, top: 0, bottom: 10),
                                      child: Text(
                                        widget.classObj.name,
                                        style:
                                            OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w500, customColor: OlukoColors.grayColor),
                                      ),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(left: 15.0),
                                        child: Text(
                                          "${OlukoLocalizations.get(context, 'class').toUpperCase()} ${widget.index + 1}/${widget.total}",
                                          style:
                                              OlukoFonts.olukoSmallFont(custoFontWeight: FontWeight.bold, customColor: OlukoColors.white),
                                        )),
                                  ],
                                ),
                        ),
                        widget.classProgress == 1
                            ? Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Container(
                                    color: Color(0xff33BC84),
                                    width: 25,
                                    height: 25,
                                    child: Image.asset(
                                      'assets/courses/white_completed_tick.png',
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox()
                      ],
                    ),
                  ),           
                ],
              )
            : Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        child: Image.network(
                          widget.classObj.image,
                          height: 90,
                          width: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0, top: 0, bottom: 10),
                              child: Text(
                                widget.classObj.name,
                                style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.w500, customColor: OlukoColors.grayColor),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(left: 15.0),
                                child: Text(
                                  "${OlukoLocalizations.get(context, 'class').toUpperCase()} ${widget.index + 1}/${widget.total}",
                                  style: OlukoFonts.olukoSmallFont(custoFontWeight: FontWeight.bold, customColor: OlukoColors.white),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0, bottom: 0, right: 10),
                            child: () {
                              if (widget.classObj.description != null) {
                                return Text(widget.classObj.description,
                                    style:
                                        OlukoFonts.olukoMediumFont(custoFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor));
                              } else {
                                return const SizedBox();
                              }
                            }(),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ],
              ),
      ),
    );
  }
}
