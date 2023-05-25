import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/ui/components/schedule_modal_content.dart';

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
  final bool openEditScheduleOnInit;
  const CourseClassCardsList({
    this.course,
    this.courseEnrollment,
    this.classes,
    this.courseIndex,
    this.fromCoach,
    this.isCoachRecommendation,
    this.fromHome,
    this.playPauseVideo,
    this.closeVideo,
    this.onPressed,
    this.isFromHome = false,
    this.openEditScheduleOnInit = false,
  }) : super();

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
    if (widget.openEditScheduleOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openEditSchedule(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () {
              _openEditSchedule(context);
            },
            child: Text(
              OlukoLocalizations.get(context, 'editSchedule'),
              style: OlukoFonts.olukoBigFont(
                customFontWeight: FontWeight.w600,
                customColor: OlukoColors.white,
              ),
            ),
          ),
        ),
        ..._classItemList.map((ClassItem classElement) => getIncompletedClasses(_classItemList.indexOf(classElement),
            CourseEnrollmentService.getClassProgress(widget.courseEnrollment, _classItemList.indexOf(classElement)), classElement)),
        ..._classItemList.map((ClassItem classElement) => getCompletedClasses(_classItemList.indexOf(classElement), classElement))
      ],
    );
  }

  void _openEditSchedule(BuildContext context) {
    BottomDialogUtils.showBottomDialog(
      content: ScheduleModalContent(
        scheduleRecommendations: widget.course.scheduleRecommendations,
        isCoachRecommendation: widget.isCoachRecommendation,
        courseEnrollment: widget.courseEnrollment,
        totalClasses: _classItemList.length,
        blocCourseEnrollment: BlocProvider.of<CourseEnrollmentBloc>(context),
        onUpdateScheduleAction: () {
          setState(() {
            _classItemList = _updateClassScheduledDates();
          });
        },
      ),
      isScrollControlled: true,
      context: context,
    );
  }

  List<ClassItem> _updateClassScheduledDates() {
    for (var i = 0; i < _classItemList.length; i++) {
      _classItemList[i].scheduledDate = widget.courseEnrollment.classes[i].scheduledDate;
    }
    return _classItemList;
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
              classItem.scheduledDate = enrollmentClass.scheduledDate;
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
              margin: const EdgeInsets.only(top: 5, bottom: 5),
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
      scheduledDate: item.scheduledDate?.toDate(),
    );
  }

  void getNavigationToClass(CourseEnrollment enrollment, int classIndex, int courseIndex) {
    Navigator.popAndPushNamed(
      context,
      routeLabels[RouteEnum.insideClass],
      arguments: {'courseEnrollment': enrollment, 'classIndex': classIndex, 'courseIndex': courseIndex, 'actualCourse': widget.course},
    );
  }
}
