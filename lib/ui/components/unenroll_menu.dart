import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';

class UnenrollCourse extends StatefulWidget {
  const UnenrollCourse({this.actualCourse, this.unrolledFunction}) : super();
  final CourseEnrollment actualCourse;
  final Function() unrolledFunction;

  @override
  _UnenrollCourseState createState() => _UnenrollCourseState();
}

enum Unenroll { unenroll }

class _UnenrollCourseState extends State<UnenrollCourse> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Unenroll>(
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<Unenroll>>[
          PopupMenuItem(
            onTap: () {
              BlocProvider.of<CourseEnrollmentListBloc>(context).unenrollCourseForUser(widget.actualCourse, isUnenrolledValue: true);
              if (widget.unrolledFunction != null) {
                widget.unrolledFunction();
              }
            },
            value: Unenroll.unenroll,
            padding: EdgeInsets.zero,
            // ),
            child: Center(child: Text('Unenroll', style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white))),
          )
        ];
      },
      color: OlukoColors.black,
      icon: const Icon(
        Icons.more_vert,
        color: Colors.white,
        size: 36,
      ),
      iconSize: 36,
      padding: EdgeInsets.zero,
    );
  }
}
