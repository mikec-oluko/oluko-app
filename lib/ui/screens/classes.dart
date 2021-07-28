import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/class_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/statistics_bloc.dart';
import 'package:oluko_app/blocs/course_bloc.dart';
import 'package:oluko_app/constants/Theme.dart';

import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/course_enrollment_service.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/class_expansion_panel.dart';
import 'package:oluko_app/ui/components/class_section.dart';
import 'package:oluko_app/ui/components/course_progress_bar.dart';
import 'package:oluko_app/ui/components/course_segment_section.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/statistics_chart.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/screens/inside_classes.dart';
import 'package:oluko_app/utils/movement_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';

class Classes extends StatefulWidget {
  final String courseId;

  Classes({Key key, this.courseId}) : super(key: key);

  get progress => null;

  @override
  _ClassesState createState() => _ClassesState();
}

class _ClassesState extends State<Classes> {
  final _formKey = GlobalKey<FormState>();
  ChewieController _controller;
  CourseBloc _courseBloc;
  ClassBloc _classBloc;
  StatisticsBloc _statisticsBloc;
  CourseEnrollmentBloc _courseEnrollmentBloc;

  @override
  void initState() {
    super.initState();
    _courseBloc = CourseBloc();
    _classBloc = ClassBloc();
    _statisticsBloc = StatisticsBloc();
    _courseEnrollmentBloc = CourseEnrollmentBloc();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        return MultiBlocProvider(
            providers: [
              BlocProvider<CourseBloc>(
                create: (context) => _courseBloc..getById(widget.courseId),
              ),
              BlocProvider<ClassBloc>(
                create: (context) => _classBloc,
              ),
              BlocProvider<StatisticsBloc>(
                create: (context) => _statisticsBloc,
              ),
              BlocProvider<CourseEnrollmentBloc>(
                create: (context) => _courseEnrollmentBloc,
              ),
            ],
            child:
                BlocBuilder<CourseBloc, CourseState>(builder: (context, state) {
              if (state is GetCourseSuccess) {
                _classBloc..getAll(state.course);
                _statisticsBloc..get(state.course.statisticsReference);
                _courseEnrollmentBloc
                  ..get(authState.firebaseUser, state.course);
                return form(state.course, authState.firebaseUser);
              } else {
                return SizedBox();
              }
            }));
      } else {
        return Text("Not logged user.");
      }
    });
  }

  Widget form(Course course, User user) {
    return BlocBuilder<CourseEnrollmentBloc, CourseEnrollmentState>(
        builder: (context, enrollmentState) {
      return BlocBuilder<ClassBloc, ClassState>(builder: (context, classState) {
        if ((enrollmentState is GetEnrollmentSuccess) &&
            classState is GetSuccess) {
          bool existsEnrollment = enrollmentState.courseEnrollment != null;
          return Form(
              key: _formKey,
              child: Scaffold(
                  appBar: OlukoAppBar(
                      title: OlukoLocalizations.of(context).find('course')),
                  body: Container(
                      color: Colors.black,
                      child: Stack(
                        children: [
                          ListView(children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: OrientationBuilder(
                                builder: (context, orientation) {
                                  if (existsEnrollment) {
                                    return showVideoPlayer(
                                        classState.classes[0].video);
                                  } else {
                                    return showVideoPlayer(course.video);
                                  }
                                },
                              ),
                            ),
                            /*existsEnrollment
                                ? CourseProgressBar(
                                    value: enrollmentState
                                        .courseEnrollment.completion)
                                : SizedBox(),*/
                            showButton(enrollmentState.courseEnrollment,
                                context, user, course, classState.classes),
                            Padding(
                                padding: EdgeInsets.only(
                                    right: 15, left: 15, top: 0),
                                child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            course.name,
                                            style: OlukoFonts.olukoTitleFont(
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
                                                  course.classes != null
                                                      ? course.classes.length
                                                      : 0,
                                                  context),
                                              style: OlukoFonts.olukoBigFont(
                                                  custoFontWeight:
                                                      FontWeight.normal,
                                                  customColor:
                                                      OlukoColors.grayColor),
                                            ),
                                          ),
                                          BlocBuilder<StatisticsBloc,
                                                  StatisticsState>(
                                              builder: (context, state) {
                                            if (state is StatisticsSuccess) {
                                              return Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 15),
                                                  child: StatisticChart(
                                                      courseStatistics: state
                                                          .courseStatistics));
                                            } else {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(50.0),
                                                child: Center(
                                                  child: Text(
                                                      OlukoLocalizations.of(
                                                              context)
                                                          .find(
                                                              'loadingWhithDots'),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      )),
                                                ),
                                              );
                                            }
                                          }),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10.0, right: 10),
                                            child: Text(
                                              course.description,
                                              style: OlukoFonts.olukoBigFont(
                                                  custoFontWeight:
                                                      FontWeight.normal,
                                                  customColor:
                                                      OlukoColors.grayColor),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 25.0),
                                            child: Text(
                                              OlukoLocalizations.of(context)
                                                  .find('classes'),
                                              style:
                                                  OlukoFonts.olukoSubtitleFont(
                                                      custoFontWeight:
                                                          FontWeight.bold),
                                            ),
                                          ),
                                          ClassExpansionPanel(
                                              classes: classState.classes),
                                          /*Column(
                                            children: [
                                              ListView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount:
                                                      classState.classes != null
                                                          ? classState
                                                              .classes.length
                                                          : 0,
                                                  shrinkWrap: true,
                                                  itemBuilder:
                                                      (context, num index) {
                                                    Class classObj = classState
                                                        .classes[index];
                                                    double classProgress =
                                                        CourseEnrollmentService
                                                            .getClassProgress(
                                                                enrollmentState
                                                                    .courseEnrollment,
                                                                index);
                                                    return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 5.0),
                                                        child: ClassSection(
                                                          classProgresss:
                                                              classProgress,
                                                          index: index,
                                                          total: classState
                                                              .classes.length,
                                                          classObj: classObj,
                                                          onPressed: () {
                                                            if (!existsEnrollment) {
                                                              MovementUtils
                                                                  .movementDialog(
                                                                      context,
                                                                      _confirmDialogContent());
                                                            }
                                                          },
                                                        ));
                                                  }),
                                            ],
                                          )*/
                                        ]))),
                            SizedBox(
                              height: 150,
                            )
                          ]),
                        ],
                      ))));
        } else {
          return SizedBox();
        }
      });
    });
  }

  Widget showButton(CourseEnrollment courseEnrollment, BuildContext context,
      User user, Course course, List<Class> classes) {
    return courseEnrollment == null
        ? Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                OlukoPrimaryButton(
                  title: OlukoLocalizations.of(context).find('enroll'),
                  onPressed: () {
                    _courseEnrollmentBloc..create(user, course);

                    Navigator.pushNamed(context, routeLabels[RouteEnum.root]);
                  },
                ),
              ],
            ))
        : SizedBox(
            height: 15,
          );

    /*String buttonText;
    int index;
    double classProgress;

    if (courseEnrollment != null) {
      buttonText = OlukoLocalizations.of(context).find('start');
      index = CourseEnrollmentService.getFirstUncompletedClassIndex(
          courseEnrollment);
      if (index != -1) {
        classProgress =
            CourseEnrollmentService.getClassProgress(courseEnrollment, index);
      }
    } else {
      buttonText = OlukoLocalizations.of(context).find('enroll');
    }
    return index == -1
        ? SizedBox()
        : Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                OlukoPrimaryButton(
                  title: buttonText,
                  onPressed: () {
                    if (courseEnrollment != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InsideClasses(
                                    user: user,
                                    courseEnrollment: courseEnrollment,
                                    classIndex: index,
                                    classProgress: classProgress,
                                    actualClass: classes[index],
                                    courseName: course.name,
                                  )));
                    } else {
                      _courseEnrollmentBloc..create(user, course);
                    }
                  },
                ),
              ],
            ));*/
  }

  Widget showVideoPlayer(String videoUrl) {
    List<Widget> widgets = [];
    if (_controller == null) {
      widgets.add(Center(child: CircularProgressIndicator()));
    }
    widgets.add(OlukoVideoPlayer(
        videoUrl: videoUrl,
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) =>
            this.setState(() {
              _controller = chewieController;
            })));

    return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? ScreenUtils.height(context) / 4
                    : ScreenUtils.height(context) / 1.5,
            minHeight:
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? ScreenUtils.height(context) / 4
                    : ScreenUtils.height(context) / 1.5),
        child: Container(height: 400, child: Stack(children: widgets)));
  }

  List<Widget> _confirmDialogContent() {
    return [
      Icon(Icons.warning_amber_rounded, color: Colors.white, size: 100),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(OlukoLocalizations.of(context).find('enrollWarning'),
            textAlign: TextAlign.center, style: OlukoFonts.olukoBigFont()),
      )
    ];
  }
}
