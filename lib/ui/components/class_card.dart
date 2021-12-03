import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/course_enrollment_service.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

import 'course_progress_bar.dart';

class ClassCard extends StatefulWidget {
  final EnrollmentClass enrollmentClass;
  final int classIndex;
  final CourseEnrollment courseEnrollment;
  final bool selected;
  final int courseIndex;

  ClassCard({this.enrollmentClass, this.classIndex, this.courseIndex, this.courseEnrollment, this.selected = false});

  @override
  _State createState() => _State();
}

class _State extends State<ClassCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: card(),
    );
  }

  Widget card() {
    if (widget.selected) {
      return Container(
          width: 110,
          child: Column(children: [
            classRectangle(),
            SizedBox(height: 6),
            GestureDetector(
                onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.insideClass], arguments: {
                      'courseEnrollment': widget.courseEnrollment,
                      'classIndex': widget.classIndex,
                      'courseIndex': widget.courseIndex,
                    }),
                child: classContainer(150.0, 110.0))
          ]));
    } else {
      return Padding(
          padding: EdgeInsets.only(top: 40), child: Container(width: 95, child: Column(children: [classContainer(122.0, 95.0)])));
    }
  }

  Widget classRectangle() {
    return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: OlukoColors.primary),
          width: 50,
          height: 19,
          child: Align(
              alignment: Alignment.center,
              child: Text(OlukoLocalizations.get(context, 'class') + " " + (widget.classIndex + 1).toString(),
                  style: OlukoFonts.olukoSmallFont(custoFontWeight: FontWeight.bold, customColor: OlukoColors.black))),
        ));
  }

  Widget classContainer(double height, double width) {
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
                widget.enrollmentClass.image != null
                    ? widget.enrollmentClass.image // TODO: set default picture in const file
                    : "https://firebasestorage.googleapis.com/v0/b/oluko-2671e.appspot.com/o/classes_sample_images%2Fclass_sample_2.png?alt=media&token=f3ac6b80-a2f5-4612-ab72-ea72f88ad00e",
                height: height,
                width: width,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
            widget.selected ? rightButton() : SizedBox()
          ]),
          widget.selected
              ? Container(
                  width: 120,
                  child: CourseProgressBar(value: CourseEnrollmentService.getClassProgress(widget.courseEnrollment, widget.classIndex)))
              : SizedBox(),
        ])));
  }

  Widget rightButton() {
    return Padding(
        padding: EdgeInsets.all(5),
        child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.insideClass],
                arguments: {'courseEnrollment': widget.courseEnrollment, 'classIndex': widget.classIndex}),
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
