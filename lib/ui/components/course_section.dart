import 'package:flutter/material.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/ui/components/class_carousel_gallery.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/ui/components/course_step_section.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';

class CourseSection extends StatefulWidget {
  final Course course;
  final CourseEnrollment courseEnrollment;
  final int courseIndex;
  final int qtyCourses;

  const CourseSection({
    Key key,
    @required this.course,
    @required this.courseEnrollment,
    @required this.courseIndex,
    @required this.qtyCourses,
  }) : super(key: key);

  @override
  _CourseSectionState createState() => _CourseSectionState();
}

class _CourseSectionState extends State<CourseSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: NetworkImage(widget.course.image),
          fit: BoxFit.cover,
        )),
        height: ScreenUtils.height(context),
        width: ScreenUtils.width(context),
        child: Column(children: [
          CourseProgressBar(value: widget.courseEnrollment.completion),
          SizedBox(height: 10),
          Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.share, color: OlukoColors.white),
                onPressed: () {
                  //TODO: Add share action
                },
              )),
          SizedBox(height: 120),
          Text(widget.course.name,
              style: OlukoFonts.olukoSuperBigFont(
                  custoFontWeight: FontWeight.bold,
                  customColor: OlukoColors.white)),
          SizedBox(height: 15),
          Text(
            //TODO: change weeks number
            TimeConverter.toCourseDuration(
                3,
                widget.course.classes != null
                    ? widget.course.classes.length
                    : 0,
                context),
            style: OlukoFonts.olukoMediumFont(
                custoFontWeight: FontWeight.normal,
                customColor: OlukoColors.grayColor),
          ),
          SizedBox(height: 2),
          CourseStepSection(
              totalCourseSteps: widget.qtyCourses,
              currentCourseStep: widget.courseIndex + 1),
          SizedBox(height: 25),
          ClassCarouselGallery(courseEnrollment: widget.courseEnrollment),
        ]));
  }
}
