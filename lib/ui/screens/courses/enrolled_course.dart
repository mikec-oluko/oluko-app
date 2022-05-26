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
import 'package:oluko_app/blocs/video_bloc.dart';
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
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/overlay_video_preview.dart';
import 'package:oluko_app/ui/components/statistics_chart.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_video_preview.dart';
import 'package:oluko_app/utils/course_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';

class EnrolledCourse extends StatefulWidget {
  final Course course;
  final bool fromCoach;
  final bool isCoachRecommendation;
  final CourseEnrollment courseEnrollment;
  final int courseIndex;
  final bool fromHome;
  Function playPauseVideo;
  Function closeVideo;

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
    Function outSideCloseVideo,
    Course outsideCourse,
    CourseEnrollment outsideCourseEnrollment,
    int outsideCourseIndex,
  }) {
    final CourseEnrollment enrollment = courseEnrollment ?? outsideCourseEnrollment;
    final int index = courseIndex ?? outsideCourseIndex;

    final List<Class> _coursesClases = CourseService.getCourseClasses(course ?? outsideCourse, classes);
    final List<ClassItem> _classItems = [];
    for (final element in _coursesClases) {
      final ClassItem classItem = ClassItem(classObj: element, expanded: false);
      _classItems.add(classItem);
    }
    final List<ClassItem> _classItemsToUse = [];
    for (final enrolledClass in enrollment.classes) {
      for (final courseClass in _classItems) {
        if (enrolledClass.id == courseClass.classObj.id) {
          _classItemsToUse.add(courseClass);
        }
      }
    }

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        ..._classItemsToUse.map(
          (item) => getIncompletedClasses(_classItemsToUse, enrollment, outSideCloseVideo, closeVideo, context, index, item),
        ),
        ..._classItemsToUse.map(
          (item) => getCompletedClasses(enrollment, _classItemsToUse, item, context, index),
        )
      ],
    );
  }

  Widget getCompletedClasses(
      CourseEnrollment enrollment, List<ClassItem> _classItemsToUse, ClassItem item, BuildContext context, int index) {
    final classIndex = _classItemsToUse.indexOf(item);
    return enrollment.classes[classIndex] != null && enrollment.classes[classIndex].completedAt != null
        ? GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              routeLabels[RouteEnum.insideClass],
              arguments: {
                'courseEnrollment': enrollment,
                'classIndex': classIndex,
                'courseIndex': index,
              },
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: ClassSection(
                classProgress: 1,
                isCourseEnrolled: true,
                index: classIndex,
                total: _classItemsToUse.length,
                classObj: item.classObj,
              ),
            ),
          )
        : const SizedBox();
  }
}

Widget getIncompletedClasses(List<ClassItem> _classItemsToUse, CourseEnrollment enrollment, Function outSideCloseVideo, Function closeVideo,
    BuildContext context, int index, ClassItem item) {
  final classIndex = _classItemsToUse.indexOf(item);
  final classProgress = CourseEnrollmentService.getClassProgress(enrollment, classIndex);
  return enrollment.classes[classIndex].completedAt == null
      ? classProgress == 0
          ? Neumorphic(
              margin: const EdgeInsets.all(15),
              style: OlukoNeumorphism.getNeumorphicStyleForCardClasses(
                classProgress > 0,
              ),
              child: GestureDetector(
                onTap: () {
                  if (closeVideo != null) {
                    closeVideo();
                  } else {
                    outSideCloseVideo();
                  }
                  Navigator.pushNamed(
                    context,
                    routeLabels[RouteEnum.insideClass],
                    arguments: {
                      'courseEnrollment': enrollment,
                      'classIndex': classIndex,
                      'courseIndex': index,
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: ClassSection(
                    classProgress: classProgress,
                    isCourseEnrolled: true,
                    index: classIndex,
                    total: _classItemsToUse.length,
                    classObj: item.classObj,
                  ),
                ),
              ),
            )
          : GestureDetector(
              onTap: () {
                if (closeVideo != null) {
                  closeVideo();
                } else {
                  outSideCloseVideo();
                }
                Navigator.pushNamed(
                  context,
                  routeLabels[RouteEnum.insideClass],
                  arguments: {
                    'courseEnrollment': enrollment,
                    'classIndex': classIndex,
                    'courseIndex': index,
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: ClassSection(
                  classProgress: classProgress,
                  isCourseEnrolled: true,
                  index: classIndex,
                  total: _classItemsToUse.length,
                  classObj: item.classObj,
                ),
              ),
            )
      : const SizedBox();
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

    widget.playPauseVideo = () => setState(() {
          _isVideoPlaying = !_isVideoPlaying;
        });
    widget.closeVideo = () => setState(() {
          if (_isVideoPlaying) {
            _isVideoPlaying = !_isVideoPlaying;
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthSuccess) {
          _user = authState.firebaseUser;
          if (_userState == null) {
            _userState = authState;
            BlocProvider.of<SubscribedCourseUsersBloc>(context).get(widget.course.id, _userState.user.id);
            BlocProvider.of<ClassSubscriptionBloc>(context).getStream();
            BlocProvider.of<StatisticsSubscriptionBloc>(context).getStream();
            BlocProvider.of<CourseEnrollmentBloc>(context).get(authState.firebaseUser, widget.course);
            BlocProvider.of<MovementBloc>(context).getStream();
            BlocProvider.of<VideoBloc>(context).getAspectRatio(widget.course.video);
          }
          return form();
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget form() {
    return BlocBuilder<MovementBloc, MovementState>(
      builder: (context, movementState) {
        if (movementState is LoadingMovementState) {
          return nil;
        }
        if (movementState is GetAllSuccess) {
          _movements = movementState.movements;
          return BlocBuilder<CourseEnrollmentBloc, CourseEnrollmentState>(
            builder: (context, enrollmentState) {
              return BlocBuilder<ClassSubscriptionBloc, ClassSubscriptionState>(
                builder: (context, classState) {
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
                                    ListView(
                                      children: [
                                        OlukoVideoPreview(
                                          showBackButton: true,
                                          image: widget.course.posterImage ?? widget.course.image,
                                          video: widget.course.video,
                                          onBackPressed: () => Navigator.pop(context),
                                          onPlay: () => widget.playPauseVideo(),
                                          videoVisibilty: _isVideoPlaying,
                                          bottomWidgets: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                              child: Text(
                                                widget.course.name,
                                                style: OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        showEnrollButton(enrollmentState.courseEnrollment, context),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 15, left: 15, top: 5),
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 10.0, right: 10),
                                                  child: Text(
                                                    widget.course.description ?? '',
                                                    style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.normal),
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
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 150,
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                color: Colors.black,
                                child: Stack(
                                  children: [
                                    ListView(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 3),
                                          child: OverlayVideoPreview(
                                            image: widget.course.posterImage ?? widget.course.image,
                                            video: widget.course.video,
                                            showBackButton: true,
                                            showHeartButton: true,
                                            showShareButton: true,
                                            onBackPressed: () => Navigator.pop(context),
                                          ),
                                        ),
                                        showEnrollButton(enrollmentState.courseEnrollment, context),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 15, left: 15, top: 0),
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget.course.name,
                                                  style: OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.bold),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 10.0, right: 10),
                                                  child: Text(
                                                    //TODO: change weeks number
                                                    CourseUtils.toCourseDuration(
                                                      int.tryParse(widget.course.duration) ?? 0,
                                                      widget.course.classes != null ? widget.course.classes.length : 0,
                                                      context,
                                                    ),
                                                    style: OlukoFonts.olukoBigFont(
                                                      custoFontWeight: FontWeight.normal,
                                                      customColor: OlukoColors.grayColor,
                                                    ),
                                                  ),
                                                ),
                                                buildStatistics(),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 10.0, right: 10),
                                                  child: Text(
                                                    widget.course.description ?? '',
                                                    style: OlukoFonts.olukoBigFont(
                                                      custoFontWeight: FontWeight.normal,
                                                      customColor: OlukoColors.grayColor,
                                                    ),
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
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 150,
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    );
                  } else {
                    return nil;
                  }
                },
              );
            },
          );
        } else {
          return nil;
        }
      },
    );
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
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
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
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildStatistics() {
    return BlocBuilder<StatisticsSubscriptionBloc, StatisticsSubscriptionState>(
      builder: (context, statisticsState) {
        if (statisticsState is StatisticsSubscriptionSuccess) {
          final CourseStatistics courseStatistics =
              statisticsState.courseStatistics.where((element) => element.courseId == widget.course.id).toList()[0];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: StatisticChart(
              courseStatistics: courseStatistics,
              course: widget.course,
            ),
          );
        }
        if (statisticsState is StatisticsSubscriptionLoading) {
          return Padding(
            padding: const EdgeInsets.all(50.0),
            child: Center(
              child: Text(
                OlukoLocalizations.get(context, 'loadingWhithDots'),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          );
        } else {
          return const Padding(
            padding: EdgeInsets.all(50.0),
            child: Center(
              child: Text(
                'error',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget buildClassExpansionPanels() {
    return ClassExpansionPanels(
      classes: CourseService.getCourseClasses(widget.course, _classes),
      movements: _movements,
      onPressedMovement: (BuildContext context, Movement movement) {
        widget.playPauseVideo();
        Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movement': movement});
      },
    );
  }
}
