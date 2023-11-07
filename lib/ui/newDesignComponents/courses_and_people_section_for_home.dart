import 'package:flutter/widgets.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/ui/components/course_carousel_galery.dart';
import 'package:oluko_app/ui/newDesignComponents/not_enrolled_component.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class HomeCoursePosterSlider extends StatefulWidget {
  final List<CourseEnrollment> courseEnrollments;
  final int courseIndex;
  final Function(int) onCourseChange;
  final Function(int) onCourseTap;
  final Function(int) onCourseDeleted;
  const HomeCoursePosterSlider({this.courseEnrollments, this.courseIndex, this.onCourseChange, this.onCourseTap, this.onCourseDeleted}) : super();

  @override
  State<HomeCoursePosterSlider> createState() => _HomeCoursePosterSliderState();
}

class _HomeCoursePosterSliderState extends State<HomeCoursePosterSlider> {
  @override
  Widget build(BuildContext context) {
    return widget.courseEnrollments.isEmpty ? const NotEnrolledComponent() : _coursePosterSlider(context);
  }

  Column _coursePosterSlider(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 20,
        ),
        Text(OlukoLocalizations.get(context, 'enrolledCourses'), style: OlukoFonts.olukoBigFont()),
        const SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: CourseCarouselGallery(
            courseEnrollments: widget.courseEnrollments,
            onCourseChange: (index) => widget.onCourseChange(index),
            onCourseDeleted: (index) => widget.onCourseDeleted(index),
            onCourseTap: (index) => widget.onCourseTap(index),
            courseIndex: widget.courseIndex,
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        Text(widget.courseEnrollments[widget.courseIndex].course.name, style: OlukoFonts.olukoTitleFont()),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
