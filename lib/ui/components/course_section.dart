import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/ui/components/class_carousel_gallery.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/ui/components/course_step_section.dart';
import 'package:oluko_app/utils/course_utils.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';

class CourseSection extends StatefulWidget {
  final Course course;
  final CourseEnrollment courseEnrollment;
  final int courseIndex;
  final int qtyCourses;
  final int classIndex;

  const CourseSection({
    Key key,
    @required this.course,
    @required this.courseEnrollment,
    @required this.courseIndex,
    @required this.qtyCourses,
    this.classIndex,
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
          image: widget.course.image != null
              ? CachedNetworkImageProvider(widget.course.image)
              : AssetImage("assets/home/mvt.png") as ImageProvider,
          fit: widget.course.image != null ? BoxFit.cover : BoxFit.contain,
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
          Text(widget.course.name, style: OlukoFonts.olukoSuperBigFont(customFontWeight: FontWeight.bold, customColor: OlukoColors.white)),
          SizedBox(height: 15),
          Text(
            //TODO: change weeks number
            CourseUtils.toCourseDuration(3, widget.course.classes != null ? widget.course.classes.length : 0, context),
            style: OlukoFonts.olukoMediumFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
          ),
          SizedBox(height: 2),
          CourseStepSection(totalCourseSteps: widget.qtyCourses, currentCourseStep: widget.courseIndex + 1),
          SizedBox(height: 25),
          ClassCarouselGallery(courseEnrollment: widget.courseEnrollment, courseIndex: widget.courseIndex, classIndex: widget.classIndex),
        ]));
  }
}
