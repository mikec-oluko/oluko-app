import 'dart:developer';

import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/class_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_bloc.dart';
import 'package:oluko_app/blocs/movement_bloc.dart';
import 'package:oluko_app/blocs/statistics_bloc.dart';
import 'package:oluko_app/blocs/subscribed_course_users_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/course_statistics.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/class_expansion_panel.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/overlay_video_preview.dart';
import 'package:oluko_app/ui/components/statistics_chart.dart';
import 'package:oluko_app/utils/app_loader.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/time_converter.dart';

class CourseMarketing extends StatefulWidget {
  final Course course;

  CourseMarketing({Key key, this.course}) : super(key: key);

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
          BlocProvider.of<ClassBloc>(context)..getAll(widget.course);
          BlocProvider.of<StatisticsBloc>(context)
            ..get(widget.course.statisticsReference);
          BlocProvider.of<MovementBloc>(context)..getAll();
          BlocProvider.of<CourseEnrollmentBloc>(context)
            ..get(authState.firebaseUser, widget.course);
        }

        return form();
      } else {
        return SizedBox();
      }
    });
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
          return BlocBuilder<ClassBloc, ClassState>(
              builder: (context, classState) {
            if ((enrollmentState is GetEnrollmentSuccess) &&
                classState is GetSuccess) {
              _classes = classState
                  .classes; //TODO: this is receiving old classes from another (previously opened) course
              return Form(
                  key: _formKey,
                  child: Scaffold(
                      body: Container(
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
                                  ),
                                ),
                                showEnrollButton(
                                    enrollmentState.courseEnrollment, context),
                                Padding(
                                    padding: EdgeInsets.only(
                                        right: 15, left: 15, top: 0),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.course.name,
                                                style:
                                                    OlukoFonts.olukoTitleFont(
                                                        custoFontWeight:
                                                            FontWeight.bold),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10.0, right: 10),
                                                child: Text(
                                                  //TODO: change weeks number
                                                  TimeConverter.toCourseDuration(
                                                      6,
                                                      widget.course.classes !=
                                                              null
                                                          ? widget.course
                                                              .classes.length
                                                          : 0,
                                                      context),
                                                  style:
                                                      OlukoFonts.olukoBigFont(
                                                          custoFontWeight:
                                                              FontWeight.normal,
                                                          customColor:
                                                              OlukoColors
                                                                  .grayColor),
                                                ),
                                              ),
                                              buildStatistics(),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10.0, right: 10),
                                                child: Text(
                                                  widget.course.description ??
                                                      '',
                                                  style:
                                                      OlukoFonts.olukoBigFont(
                                                          custoFontWeight:
                                                              FontWeight.normal,
                                                          customColor:
                                                              OlukoColors
                                                                  .grayColor),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 25.0),
                                                child: Text(
                                                  OlukoLocalizations.get(
                                                      context, 'classes'),
                                                  style: OlukoFonts
                                                      .olukoSubtitleFont(
                                                          custoFontWeight:
                                                              FontWeight.bold),
                                                ),
                                              ),
                                              buildClassExpansionPanels(),
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

  Widget showEnrollButton(
      CourseEnrollment courseEnrollment, BuildContext context) {
    if (courseEnrollment == null || courseEnrollment.completion >= 1) {
      return BlocListener<CourseEnrollmentBloc, CourseEnrollmentState>(
          listener: (context, courseEnrollmentState) {
            if (courseEnrollmentState is CreateEnrollmentSuccess) {
              BlocProvider.of<CourseEnrollmentListBloc>(context)
                ..getCourseEnrollmentsByUser(_user.uid);
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
                      BlocProvider.of<CourseEnrollmentBloc>(context)
                        ..create(_user, widget.course);
                    },
                  ),
                ],
              )));
    } else {
      return SizedBox();
    }
  }

  Widget buildStatistics() {
    return BlocBuilder<SubscribedCourseUsersBloc, SubscribedCourseUsersState>(
        builder: (context, state) {
      if (state is SubscribedCourseUsersSuccess) {
        return Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: StatisticChart(
              courseStatistics: CourseStatistics(
                  courseId: widget.course.id,
                  takingUp: state.users.length,
                  doing: state.users.length),
              course: widget.course,
            ));
      } else {
        return Padding(
          padding: const EdgeInsets.all(50.0),
          child: Center(
            child: Text(OlukoLocalizations.get(context, 'loadingWhithDots'),
                style: TextStyle(
                  color: Colors.white,
                )),
          ),
        );
      }
    });
  }

  Widget buildClassExpansionPanels() {
    return ClassExpansionPanel(
      classes: _classes,
      movements: _movements,
      onPressedMovement: (BuildContext context, Movement movement) =>
          Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro],
              arguments: {'movement': movement}),
    );
  }
}
