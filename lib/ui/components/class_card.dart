import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/Theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/services/course_enrollment_service.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

import 'course_progress_bar.dart';

class ClassCard extends StatefulWidget {
  final Class classObj;
  final int classIndex;
  final CourseEnrollment courseEnrollment;
  final bool selected;

  ClassCard(
      {this.classObj,
      this.classIndex,
      this.courseEnrollment,
      this.selected = false});

  @override
  _State createState() => _State();
}

class _State extends State<ClassCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Container(
          child: Column(
            children: [
              Container(width: 110, child: Column(children: card())),
            ],
          ),
        ));
  }

  List<Widget> card() {
    if (widget.selected) {
      return [classRectangle(), SizedBox(height: 6), classContainer()];
    } else {
      return [classContainer()];
    }
  }

  Widget classRectangle() {
    return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: OlukoColors.primary),
          width: 50,
          height: 19,
          child: Align(
              alignment: Alignment.center,
              child: Text(
                  OlukoLocalizations.of(context).find('class') +
                      " " +
                      (widget.classIndex + 1).toString(),
                  style: OlukoFonts.olukoSmallFont(
                      custoFontWeight: FontWeight.bold,
                      customColor: OlukoColors.black))),
        ));
  }

  Widget classContainer() {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(3)),
          border: Border.all(
            color: OlukoColors.white,
            width: 1,
          ),
        ),
        child: Container(
            child: Column(children: [
          Stack(alignment: Alignment.bottomRight, children: [
            ClipRRect(
              child: Image.network(
                widget.classObj.image,
                height: 150,
                width: 110,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
            widget.selected ? rightButton() : SizedBox()
          ]),
          widget.selected
              ? Container(
                  width: 120,
                  child: CourseProgressBar(
                      value: CourseEnrollmentService.getClassProgress(
                          widget.courseEnrollment, widget.classIndex)))
              : SizedBox(),
        ])));
  }

  Widget rightButton() {
    return Padding(
        padding: EdgeInsets.all(5),
        child: GestureDetector(
            onTap: () {
              //TODO: Add action
            },
            child: Stack(alignment: Alignment.center, children: [
              Image.asset(
                'assets/home/ellipse_button.png',
                scale: 4,
              ),
              Image.asset(
                'assets/home/right_icon.png',
                scale: 4,
              )
            ])));
  }
}
