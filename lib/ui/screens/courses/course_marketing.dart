import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/class_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/movement_bloc.dart';
import 'package:oluko_app/blocs/statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/class_expansion_panel.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/overlay_video_preview.dart';
import 'package:oluko_app/ui/components/statistics_chart.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/components/video_overlay.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        BlocProvider.of<ClassBloc>(context)..getAll(widget.course);
        BlocProvider.of<StatisticsBloc>(context)
          ..get(widget.course.statisticsReference);
        BlocProvider.of<MovementBloc>(context)..getAll();
        BlocProvider.of<CourseEnrollmentBloc>(context)
          ..get(authState.firebaseUser, widget.course);
        return form(authState.firebaseUser);
      } else {
        return SizedBox();
      }
    });
  }

  Widget form(User user) {
    return BlocBuilder<CourseEnrollmentBloc, CourseEnrollmentState>(
        builder: (context, enrollmentState) {
      return BlocBuilder<ClassBloc, ClassState>(builder: (context, classState) {
        if ((enrollmentState is GetEnrollmentSuccess) &&
            classState is GetSuccess) {
          bool existsEnrollment = enrollmentState.courseEnrollment != null;
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
                            /*existsEnrollment
                                ? CourseProgressBar(
                                    value: enrollmentState
                                        .courseEnrollment.completion)
                                : SizedBox(),*/
                            showButton(
                                enrollmentState.courseEnrollment,
                                context,
                                user,
                                widget.course,
                                classState.classes),
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
                                            widget.course.name,
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
                                                  widget.course.classes != null
                                                      ? widget
                                                          .course.classes.length
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
                                              widget.course.description,
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
                                          BlocBuilder<MovementBloc,
                                                  MovementState>(
                                              builder:
                                                  (context, movementState) {
                                            if (movementState
                                                is GetAllSuccess) {
                                              return ClassExpansionPanel(
                                                classes: classState.classes,
                                                movements:
                                                    movementState.movements,
                                                onPressedMovement: (BuildContext
                                                            context,
                                                        Movement movement) =>
                                                    Navigator.pushNamed(
                                                        context,
                                                        routeLabels[RouteEnum
                                                            .movementIntro],
                                                        arguments: {
                                                      'movement': movement
                                                    }),
                                              );
                                            } else {
                                              return SizedBox();
                                            }
                                          }),
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

  //TODO: Adapt when home view is ready
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
                    BlocProvider.of<CourseEnrollmentBloc>(context)
                      ..create(user, course);
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
