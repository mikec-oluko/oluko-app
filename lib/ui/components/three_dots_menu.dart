import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';

class ThreeDotsMenu extends StatefulWidget {
  final CourseEnrollment actualCourse;
  final Function() unrolledFunction;
  final bool deleteContent;

  const ThreeDotsMenu({
    this.actualCourse,
    this.unrolledFunction,
    this.deleteContent,
  }) : super();

  @override
  _ThreeDotsMenuState createState() => _ThreeDotsMenuState();
}

enum Unenroll { unenroll }

class _ThreeDotsMenuState extends State<ThreeDotsMenu> {
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
            child: Center(child: Text('Unenroll', style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white))),
          )
        ];
      },
      color: OlukoColors.black,
      icon: Container(
        width: 40,
        height: 40,
        child: Icon(
          Icons.more_vert_sharp,
          color: Colors.white,
          size: 36,
        ),
      ),
      iconSize: 36,
      padding: EdgeInsets.zero,
    );
  }
}
