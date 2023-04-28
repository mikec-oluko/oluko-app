import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/submodels/class_item.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/course_enrollment_service.dart';
import 'package:oluko_app/services/course_service.dart';
import 'package:oluko_app/ui/components/class_section.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CourseClassCardsList extends StatefulWidget {
  final Course course;
  final CourseEnrollment courseEnrollment;
  final List<Class> classes;
  final int courseIndex;
  final bool fromCoach;
  final bool isCoachRecommendation;
  final bool fromHome;
  final Function playPauseVideo;
  final Function closeVideo;
  final Function onPressed;
  final bool isFromHome;
  const CourseClassCardsList(
      {this.course,
      this.courseEnrollment,
      this.classes,
      this.courseIndex,
      this.fromCoach,
      this.isCoachRecommendation,
      this.fromHome,
      this.playPauseVideo,
      this.closeVideo,
      this.onPressed,
      this.isFromHome = false})
      : super();

  @override
  State<CourseClassCardsList> createState() => _CourseClassCardsListState();
}

class _CourseClassCardsListState extends State<CourseClassCardsList> {
  List<ClassItem> _classItemList = [];
  List<Class> _courseClassList = [];

  @override
  void initState() {
    setState(() {
      _classItemList = _buildClassesList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        ..._classItemList.map((ClassItem classElement) => getIncompletedClasses(_classItemList.indexOf(classElement),
            CourseEnrollmentService.getClassProgress(widget.courseEnrollment, _classItemList.indexOf(classElement)), classElement)),
        ..._classItemList.map((ClassItem classElement) => getCompletedClasses(_classItemList.indexOf(classElement), classElement))
      ],
    );
  }

  List<ClassItem> _buildClassesList() {
    List<ClassItem> _classListToReturn = [];
    try {
      _courseClassList = CourseService.getCourseClasses(widget.classes, courseEnrollment: widget.courseEnrollment, course: widget.course);
      if (_courseClassList.isNotEmpty) {
        _courseClassList.forEach((Class courseClass) {
          final ClassItem classItem = ClassItem(classObj: courseClass, expanded: false);
          _classItemList.add(classItem);
        });

        widget.courseEnrollment.classes.forEach((EnrollmentClass enrollmentClass) {
          _classItemList.forEach((ClassItem classItem) {
            if (classItem.classObj.id == enrollmentClass.id) {
              _classListToReturn.add(classItem);
            }
          });
        });
      }
      return _classListToReturn;
    } catch (e) {
      return [];
    }
  }

  Widget getCompletedClasses(int classIndex, ClassItem item) {
    if (widget.courseEnrollment?.classes[classIndex] != null && widget.courseEnrollment?.classes[classIndex].completedAt != null) {
      return GestureDetector(
          onTap: () {
            if (widget.onPressed != null) widget.onPressed();
            getNavigationToClass(widget.courseEnrollment, _classItemList.indexOf(item), widget.courseIndex);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: _getClassCards(classIndex, item, 1),
          ));
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget getIncompletedClasses(int classIndex, double classProgress, ClassItem item) {
    if (widget.courseEnrollment?.classes[classIndex].completedAt == null) {
      if (classProgress == 0) {
        return GestureDetector(
          onTap: () {
            if (widget.onPressed != null) widget.onPressed();
            if (widget.closeVideo != null) widget.closeVideo();
            getNavigationToClass(widget.courseEnrollment, _classItemList.indexOf(item), widget.courseIndex);
          },
          child: Neumorphic(
              margin: const EdgeInsets.all(5),
              style: OlukoNeumorphism.getNeumorphicStyleForCardClasses(
                classProgress > 0,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: _getClassCards(classIndex, item, CourseEnrollmentService.getClassProgress(widget.courseEnrollment, classIndex)),
              )),
        );
      } else {
        return GestureDetector(
          onTap: () {
            if (widget.onPressed != null) widget.onPressed();
            if (widget.closeVideo != null) widget.closeVideo();
            getNavigationToClass(widget.courseEnrollment, _classItemList.indexOf(item), widget.courseIndex);
          },
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: _getClassCards(classIndex, item, CourseEnrollmentService.getClassProgress(widget.courseEnrollment, classIndex)),
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  ClassSection _getClassCards(int classIndex, ClassItem item, double classProgress) {
    return ClassSection(
      classProgress: classProgress,
      isCourseEnrolled: true,
      index: classIndex,
      total: _classItemList.length,
      classObj: item.classObj,
    );
  }

  void getNavigationToClass(CourseEnrollment enrollment, int classIndex, int courseIndex) {
    if (widget.isFromHome) {
      Navigator.popAndPushNamed(
        context,
        routeLabels[RouteEnum.insideClass],
        arguments: {'courseEnrollment': enrollment, 'classIndex': classIndex, 'courseIndex': courseIndex, 'actualCourse': widget.course},
      );
    } else {
      Navigator.pushNamed(
        context,
        routeLabels[RouteEnum.insideClass],
        arguments: {'courseEnrollment': enrollment, 'classIndex': classIndex, 'courseIndex': courseIndex, 'actualCourse': widget.course},
      );
    }
  }
}
