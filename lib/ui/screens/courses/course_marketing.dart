import 'dart:developer';

import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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
import 'package:oluko_app/utils/app_loader.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/time_converter.dart';

class CourseMarketing extends StatefulWidget {
  final Course course;
  final bool fromCoach;
  final bool isCoachRecommendation;
  final CourseEnrollment courseEnrollment;
  CourseMarketing({Key key, this.course, this.fromCoach = false, this.isCoachRecommendation = false, this.courseEnrollment})
      : super(key: key);

  get progress => null;

  @override
  _CourseMarketingState createState() => _CourseMarketingState();
}

class _CourseMarketingState extends State<CourseMarketing> {
  final _formKey = GlobalKey<FormState>();
  ChewieController _controller;
  User _user;
  AuthSuccess _userState;
  List<Class> _classes;
  List<Movement> _movements;
  bool _disableAction = false;

  @override
  void initState() {
    super.initState();
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
          /*BlocProvider.of<SubscribedCourseUsersBloc>(context)
              .get(widget.course.id, _userState.user.id);*/
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
                      body: Container(
                          color: OlukoNeumorphism.isNeumorphismDesign ? OlukoNeumorphismColors.olukoNeumorphicBackgroundDark : Colors.black,
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
                                    onBackPressed: widget.fromCoach != null && widget.fromCoach
                                        ? () {
                                            Navigator.pop(context);
                                          }
                                        : () {
                                            Navigator.pop(context);
                                          },
                                  ),
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
                                                  6, widget.course.classes != null ? widget.course.classes.length : 0, context),
                                              style: OlukoFonts.olukoBigFont(
                                                  custoFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
                                            ),
                                          ),
                                          OlukoNeumorphism.isNeumorphismDesign ? SizedBox() : buildStatistics(),
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
                                          //TODO: si no hay courseEnrollment se muestra la vista vieja
                                          OlukoNeumorphism.isNeumorphismDesign && widget.courseEnrollment!=null? buildClassEnrolledCards() : buildClassExpansionPanels()
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
      onPressedMovement: (BuildContext context, Movement movement) =>
          Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movement': movement}),
    );
  }

  Widget buildClassEnrolledCards() {
    List<Class> _coursesClases = CourseService.getCourseClasses(widget.course, _classes);
    List<ClassItem> _classItems = [];
    _coursesClases.forEach((element) {
      ClassItem classItem = ClassItem(classObj: element, expanded: false);
      _classItems.add(classItem);
    });
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        ..._classItems.map((item) => widget.courseEnrollment.classes[_classItems.indexOf(item)].completedAt == null
            ? CourseEnrollmentService.getClassProgress(widget.courseEnrollment, _classItems.indexOf(item)) == 0
                ? Neumorphic(
                    margin: EdgeInsets.all(10),
                    style: OlukoNeumorphism.getNeumorphicStyleForCardClasses(
                        CourseEnrollmentService.getClassProgress(widget.courseEnrollment, _classItems.indexOf(item)) > 0),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.insideClass], arguments: {
                        'courseEnrollment': widget.courseEnrollment,
                        'classIndex': _classItems.indexOf(item),
                        'classImage': item.classObj.image
                      }),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ClassSection(
                          classProgress: CourseEnrollmentService.getClassProgress(widget.courseEnrollment, _classItems.indexOf(item)),
                          isCourseEnrolled: true,
                          index: _classItems.indexOf(item),
                          total: _classItems.length,
                          classObj: item.classObj,
                        ),
                      ),
                    ))
                : Container(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.insideClass], arguments: {
                        'courseEnrollment': widget.courseEnrollment,
                        'classIndex': _classItems.indexOf(item),
                        'classImage': item.classObj.image
                      }),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ClassSection(
                          classProgress: CourseEnrollmentService.getClassProgress(widget.courseEnrollment, _classItems.indexOf(item)),
                          isCourseEnrolled: true,
                          index: _classItems.indexOf(item),
                          total: _classItems.length,
                          classObj: item.classObj,
                        ),
                      ),
                    ),
                  )
            : Container(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.insideClass], arguments: {
                    'courseEnrollment': widget.courseEnrollment,
                    'classIndex': _classItems.indexOf(item),
                    'classImage': item.classObj.image
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ClassSection(
                      classProgress: 1,
                      isCourseEnrolled: true,
                      index: _classItems.indexOf(item),
                      total: _classItems.length,
                      classObj: item.classObj,
                    ),
                  ),
                ),
              )),
      ],
    );
  }
}
