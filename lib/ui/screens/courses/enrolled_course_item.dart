import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/class/class_subscription_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_bloc.dart';
import 'package:oluko_app/blocs/movement_bloc.dart';
import 'package:oluko_app/blocs/recommendation_bloc.dart';
import 'package:oluko_app/blocs/statistics/statistics_subscription_bloc.dart';
import 'package:oluko_app/blocs/subscribed_course_users_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/course_statistics.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/class_item.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/course_enrollment_service.dart';
import 'package:oluko_app/services/course_service.dart';
import 'package:oluko_app/ui/components/class_expansion_panel.dart';
import 'package:oluko_app/ui/components/class_section.dart';
import 'package:oluko_app/ui/components/modal_people_enrolled.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/overlay_video_preview.dart';
import 'package:oluko_app/ui/components/pinned_header.dart';
import 'package:oluko_app/ui/components/statistics_chart.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_video_preview.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:sliver_tools/sliver_tools.dart';

class EnrolledCourse extends StatefulWidget {
  final Course course;
  final bool fromCoach;
  final bool isCoachRecommendation;
  final CourseEnrollment courseEnrollment;
  final int courseIndex;
  final bool fromHome;
  Function isVideoPlaying;

  EnrolledCourse(
      {Key key,
      this.course,
      this.fromCoach = false,
      this.isCoachRecommendation = false,
      this.courseEnrollment,
      this.courseIndex,
      this.fromHome = false})
      : super(key: key);

  get progress => null;

  @override
  _EnrolledCourseState createState() => _EnrolledCourseState();

  Widget buildClassEnrolledCards(
    BuildContext context,
    List<Class> classes, {
    Course outsideCourse,
    CourseEnrollment outsideCourseEnrollment,
    int outsideCourseIndex,
  }) {
    final CourseEnrollment enrollment = courseEnrollment ?? outsideCourseEnrollment;
    final int index = courseIndex ?? outsideCourseIndex;

    List<Class> _coursesClases = CourseService.getCourseClasses(course ?? outsideCourse, classes);
    List<ClassItem> _classItems = [];
    _coursesClases.forEach((element) {
      ClassItem classItem = ClassItem(classObj: element, expanded: false);
      _classItems.add(classItem);
    });
    List<ClassItem> _classItemsToUse = [];
    enrollment.classes.forEach((enrolledClass) {
      _classItems.forEach((courseClass) {
        if (enrolledClass.id == courseClass.classObj.id) {
          _classItemsToUse.add(courseClass);
        }
      });
    });

    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        ..._classItemsToUse.map((item) => enrollment.classes[_classItemsToUse.indexOf(item)].completedAt == null
            ? CourseEnrollmentService.getClassProgress(enrollment, _classItemsToUse.indexOf(item)) == 0
                ? Neumorphic(
                    margin: EdgeInsets.all(10),
                    style: OlukoNeumorphism.getNeumorphicStyleForCardClasses(
                        CourseEnrollmentService.getClassProgress(enrollment, _classItemsToUse.indexOf(item)) > 0),
                    child: GestureDetector(
                      onTap: () {
                        if (isVideoPlaying != null) {
                          isVideoPlaying();
                        }
                        Navigator.pushNamed(context, routeLabels[RouteEnum.insideClass], arguments: {
                          'courseEnrollment': enrollment,
                          'classIndex': _classItemsToUse.indexOf(item),
                          'courseIndex': index,
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ClassSection(
                          classProgress: CourseEnrollmentService.getClassProgress(enrollment, _classItemsToUse.indexOf(item)),
                          isCourseEnrolled: true,
                          index: _classItemsToUse.indexOf(item),
                          total: _classItemsToUse.length,
                          classObj: item.classObj,
                        ),
                      ),
                    ))
                : Container(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.insideClass], arguments: {
                        'courseEnrollment': enrollment,
                        'classIndex': _classItemsToUse.indexOf(item),
                        'courseIndex': index,
                      }),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ClassSection(
                          classProgress: CourseEnrollmentService.getClassProgress(enrollment, _classItemsToUse.indexOf(item)),
                          isCourseEnrolled: true,
                          index: _classItemsToUse.indexOf(item),
                          total: _classItemsToUse.length,
                          classObj: item.classObj,
                        ),
                      ),
                    ),
                  )
            : SizedBox()),
        ..._classItemsToUse.map((item) => enrollment.classes[_classItemsToUse.indexOf(item)] != null &&
                enrollment.classes[_classItemsToUse.indexOf(item)].completedAt != null
            ? Container(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.insideClass], arguments: {
                    'courseEnrollment': enrollment,
                    'classIndex': _classItemsToUse.indexOf(item),
                    'courseIndex': index,
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ClassSection(
                      classProgress: 1,
                      isCourseEnrolled: true,
                      index: _classItemsToUse.indexOf(item),
                      total: _classItemsToUse.length,
                      classObj: item.classObj,
                    ),
                  ),
                ),
              )
            : SizedBox())
      ],
    );
  }
}
class _EnrolledCourseState extends State<EnrolledCourse> {
  final _formKey = GlobalKey<FormState>();
  User _user;
  AuthSuccess _userState;
  List<Class> _classes;
  List<Movement> _movements;
  bool _disableAction = false;
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();

    widget.isVideoPlaying = () => setState(() {
          _isVideoPlaying = !_isVideoPlaying;
        });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        _user = authState.firebaseUser;
        if (_userState == null) {
          _userState = authState;
          BlocProvider.of<SubscribedCourseUsersBloc>(context).get(widget.course.id, _userState.user.id);
          BlocProvider.of<ClassSubscriptionBloc>(context).getStream();
          BlocProvider.of<StatisticsSubscriptionBloc>(context).getStream();
          BlocProvider.of<CourseEnrollmentBloc>(context).get(authState.firebaseUser, widget.course);
          BlocProvider.of<MovementBloc>(context).getStream();
        }
        return form();
      } else {
        return SizedBox();
      }
    });
  }
  Widget form() {
    return BlocBuilder<MovementBloc, MovementState>(builder: (context, movementState) {
      if (movementState is LoadingMovementState) {
        return nil;
      }
      if (movementState is GetAllSuccess) {
        _movements = movementState.movements;
        return BlocBuilder<CourseEnrollmentBloc, CourseEnrollmentState>(builder: (context, enrollmentState) {
          return BlocBuilder<ClassSubscriptionBloc, ClassSubscriptionState>(builder: (context, classState) {
            if ((enrollmentState is GetEnrollmentSuccess) && classState is ClassSubscriptionSuccess) {
              _classes = classState.classes;
              return Form(
                  key: _formKey,
                  child: Scaffold(
                      body: OlukoNeumorphism.isNeumorphismDesign
                              ? Container(
                                  color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
                                  child: Stack(
                                    children: [
                                      ListView(children: [
                                        OlukoVideoPreview(
                                          showBackButton: true,
                                          image: widget.course.image,
                                          video: widget.course.video,
                                          onBackPressed: () => Navigator.pop(context),
                                          onPlay: () => widget.isVideoPlaying(),
                                          videoVisibilty: _isVideoPlaying,
                                        ),
                                        showEnrollButton(enrollmentState.courseEnrollment, context),
                                        Padding(
                                            padding: EdgeInsets.only(right: 15, left: 15, top: 5),
                                            child: Container(
                                                width: MediaQuery.of(context).size.width,
                                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                  Text(
                                                    widget.course.name,
                                                    style: OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.bold),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 10.0, right: 10),
                                                    child: Text(
                                                      widget.course.description ?? '',
                                                      style: OlukoFonts.olukoBigFont(
                                                          custoFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 25.0),
                                                    child: Text(
                                                      OlukoLocalizations.get(context, 'classes'),
                                                      style: OlukoFonts.olukoSubtitleFont(custoFontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  widget.buildClassEnrolledCards(context, _classes)
                                                ]))),
                                        SizedBox(
                                          height: 150,
                                        )
                                      ]),
                                    ],
                                  ),)
                          : Container(
                              color: Colors.black,
                              child: Stack(
                                children: [
                                  ListView(children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 3),
                                      child: OverlayVideoPreview(
                                          image: widget.course.image,
                                          video: widget.course.video,
                                          showBackButton: true,
                                          showHeartButton: true,
                                          showShareButton: true,
                                          onBackPressed: () => Navigator.pop(context)),
                                    ),
                                    showEnrollButton(enrollmentState.courseEnrollment, context),
                                    Padding(
                                        padding: EdgeInsets.only(right: 15, left: 15, top: 0),
                                        child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                              Text(
                                                widget.course.name,
                                                style: OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.bold),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 10.0, right: 10),
                                                child: Text(
                                                  //TODO: change weeks number
                                                  TimeConverter.toCourseDuration(
                                                      widget.course.duration is int ? widget.course.duration as int : 0,
                                                      widget.course.classes != null ? widget.course.classes.length : 0,
                                                      context),
                                                  style: OlukoFonts.olukoBigFont(
                                                      custoFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
                                                ),
                                              ),
                                              buildStatistics(),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 10.0, right: 10),
                                                child: Text(
                                                  widget.course.description ?? '',
                                                  style: OlukoFonts.olukoBigFont(
                                                      custoFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
                                                ),
                                              ),                                            
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 25.0),
                                                  child: Text(
                                                    OlukoLocalizations.get(context, 'classes'),
                                                    style: OlukoFonts.olukoSubtitleFont(custoFontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              buildClassExpansionPanels()
                                            ]))),
                                    SizedBox(
                                      height: 150,
                                    )
                                  ]),
                                ],
                              ))));
            } else {
              return nil;
            }
          });
        });
      } else {
        return nil;
      }
    });
  }

  Widget showEnrollButton(CourseEnrollment courseEnrollment, BuildContext context) {
    if ((courseEnrollment != null && courseEnrollment.isUnenrolled == true) ||
        (courseEnrollment == null || courseEnrollment.completion >= 1)) {
      return BlocListener<CourseEnrollmentBloc, CourseEnrollmentState>(
          listener: (context, courseEnrollmentState) {
            if (courseEnrollmentState is CreateEnrollmentSuccess) {
              BlocProvider.of<CourseEnrollmentListBloc>(context).getCourseEnrollmentsByUser(_user.uid);
              Navigator.pushNamed(context, routeLabels[RouteEnum.root]);
            }
          },
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (OlukoNeumorphism.isNeumorphismDesign)
                    OlukoNeumorphicPrimaryButton(
                      thinPadding: true,
                      title: OlukoLocalizations.get(context, 'enroll'),
                      onPressed: () {
                        if (_disableAction == false) {
                          BlocProvider.of<CourseEnrollmentBloc>(context).create(_user, widget.course);
                          if (!widget.isCoachRecommendation) {
                            BlocProvider.of<RecommendationBloc>(context).removeRecomendedCourse(_user.uid, widget.course.id);
                          }
                        }
                        _disableAction = true;
                      },
                    )
                  else
                    OlukoPrimaryButton(
                      title: OlukoLocalizations.get(context, 'enroll'),
                      onPressed: () {
                        if (_disableAction == false) {
                          BlocProvider.of<CourseEnrollmentBloc>(context).create(_user, widget.course);
                          if (!widget.isCoachRecommendation) {
                            BlocProvider.of<RecommendationBloc>(context).removeRecomendedCourse(_user.uid, widget.course.id);
                          }
                        }
                        _disableAction = true;
                      },
                    ),
                ],
              )));
    } else {
      return const SizedBox();
    }
  }

  Widget buildStatistics() {
    return BlocBuilder<StatisticsSubscriptionBloc, StatisticsSubscriptionState>(builder: (context, statisticsState) {
      if (statisticsState is StatisticsSubscriptionSuccess) {
        CourseStatistics courseStatistics =
            statisticsState.courseStatistics.where((element) => element.courseId == widget.course.id).toList()[0];
        return Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: StatisticChart(
              courseStatistics: courseStatistics,
              course: widget.course,
            ));
      }
      if (statisticsState is StatisticsSubscriptionLoading) {
        return Padding(
          padding: const EdgeInsets.all(50.0),
          child: Center(
            child: Text(OlukoLocalizations.get(context, 'loadingWhithDots'),
                style: TextStyle(
                  color: Colors.white,
                )),
          ),
        );
      } else {
        return Padding(
            padding: const EdgeInsets.all(50.0),
            child: Center(
              child: Text('error',
                  style: TextStyle(
                    color: Colors.white,
                  )),
            ));
      }
    });
  }

  Widget buildClassExpansionPanels() {
    return ClassExpansionPanel(
      classes: CourseService.getCourseClasses(widget.course, _classes),
      movements: _movements,
      onPressedMovement: (BuildContext context, Movement movement) {
        widget.isVideoPlaying();
        Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movement': movement});
      },
    );
  }

}


