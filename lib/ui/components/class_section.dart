import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class ClassSection extends StatefulWidget {
  final Class classObj;
  final int index;
  final int total;
  final double classProgress;
  final Function() onPressed;
  final bool isCourseEnrolled;
  final DateTime scheduledDate;

  const ClassSection({this.classObj, this.index, this.total, this.classProgress = 0, this.onPressed, this.isCourseEnrolled = false, this.scheduledDate});

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
                      : OlukoColors.black,
                  borderRadius: const BorderRadius.all(Radius.circular(22)),
                )
              : BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
          child: OlukoNeumorphism.isNeumorphismDesign ? neumorphicContent(isStarted) : content()),
    );
  }

  Widget neumorphicContent(bool isStarted) {
    return Column(
      children: [
        Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: widget.isCourseEnrolled
                    ? BorderRadius.only(bottomLeft: (Radius.circular(22)), topLeft: (Radius.circular(22)))
                    : const BorderRadius.all(Radius.circular(10)),
                child: CachedNetworkImage(
                  imageUrl: widget.classObj.thumbnailImage ?? widget.classObj.image,
                  height: 100,
                  width: 90,
                  maxWidthDiskCache: (ScreenUtils.width(context) * 0.40).toInt(),
                  maxHeightDiskCache: (ScreenUtils.height(context) * 0.25).toInt(),
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: widget.isCourseEnrolled
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(left: 15.0, bottom: 5, top: 15),
                                  child: Text(
                                    "${OlukoLocalizations.get(context, 'class')} ${widget.index + 1}",
                                    style: OlukoFonts.olukoSmallFont(
                                        customFontWeight: FontWeight.bold, customColor: isStarted ? OlukoColors.yellow : OlukoColors.black),
                              )),
                              const Spacer(),
                              if (widget.scheduledDate != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0, bottom: 5, top: 15, right: 15),
                                  child: Text(
                                    DateFormat('E MMM d').format(widget.scheduledDate),
                                    style: OlukoFonts.olukoSmallFont(
                                        customFontWeight: FontWeight.bold, customColor: isStarted ? OlukoColors.yellow : OlukoColors.black),
                                )),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0, top: 0, bottom: 10, right: 10),
                            child: Text(
                              widget.classObj.name,
                              style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.w500, customColor: OlukoColors.grayColor),
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
                              style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w500, customColor: OlukoColors.grayColor),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Text(
                                "${OlukoLocalizations.get(context, 'class').toUpperCase()} ${widget.index + 1}/${widget.total}",
                                style: OlukoFonts.olukoSmallFont(customFontWeight: FontWeight.bold, customColor: OlukoColors.white),
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
                          color: OlukoColors.success,
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
    );
  }

  Widget content() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: CachedNetworkImage(
                imageUrl: widget.classObj.image,
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
                      style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.w500, customColor: OlukoColors.grayColor),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(
                        "${OlukoLocalizations.get(context, 'class').toUpperCase()} ${widget.index + 1}/${widget.total}",
                        style: OlukoFonts.olukoSmallFont(customFontWeight: FontWeight.bold, customColor: OlukoColors.white),
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
                          style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor));
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
    );
  }
}
