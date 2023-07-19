import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/class/class_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/movement_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/video_player_helper.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/black_app_bar.dart';
import 'package:oluko_app/ui/components/class_expansion_panel.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_custom_video_player.dart';
import 'package:oluko_app/utils/course_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';

class EnrolledClass extends StatefulWidget {
  final Course course;

  EnrolledClass({Key key, this.course}) : super(key: key);

  get progress => null;

  @override
  _EnrolledClassState createState() => _EnrolledClassState();
}

class _EnrolledClassState extends State<EnrolledClass> {
  final _formKey = GlobalKey<FormState>();
  ChewieController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        BlocProvider.of<ClassBloc>(context)..getAll(widget.course);
        BlocProvider.of<CourseEnrollmentBloc>(context)..get(authState.user.id, widget.course);
        return form(authState.firebaseUser);
      } else {
        return SizedBox();
      }
    });
  }

  Widget form(User user) {
    return BlocBuilder<CourseEnrollmentBloc, CourseEnrollmentState>(builder: (context, enrollmentState) {
      return BlocBuilder<ClassBloc, ClassState>(builder: (context, classState) {
        if ((enrollmentState is GetEnrollmentSuccess) && classState is GetSuccess) {
          bool existsEnrollment = enrollmentState.courseEnrollment != null;
          return Form(
              key: _formKey,
              child: Scaffold(
                  backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
                  appBar: OlukoAppBar(title: OlukoLocalizations.get(context, 'class')),
                  body: SingleChildScrollView(
                    controller: _scrollController,
                    child: Container(
                        color: OlukoColors.black,
                        child: Stack(
                          children: [
                            Wrap(children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: OrientationBuilder(
                                  builder: (context, orientation) {
                                    if (existsEnrollment) {
                                      return showVideoPlayer(VideoPlayerHelper.getVideoFromSourceActive(
                                          videoHlsUrl: classState.classes[0].videoHls, videoUrl: classState.classes[0].video));
                                    } else {
                                      return showVideoPlayer(
                                          VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: widget.course.videoHls, videoUrl: widget.course.video));
                                    }
                                  },
                                ),
                              ),
                              showButton(enrollmentState.courseEnrollment, context, user, widget.course, classState.classes),
                              Padding(
                                  padding: EdgeInsets.only(right: 15, left: 15, top: 0),
                                  child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(
                                          widget.course.name,
                                          style: OlukoFonts.olukoTitleFont(customFontWeight: FontWeight.bold),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10.0, right: 10),
                                          child: Text(
                                            //TODO: change weeks number
                                            CourseUtils.toCourseDuration(6, widget.course.classes != null ? widget.course.classes.length : 0, context),
                                            style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10.0, right: 10),
                                          child: Text(
                                            widget.course.description,
                                            style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 25.0),
                                          child: Text(
                                            OlukoLocalizations.get(context, 'classes'),
                                            style: OlukoFonts.olukoSubtitleFont(customFontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        ClassExpansionPanels(
                                          screenController: _scrollController,
                                          classes: classState.classes,
                                          onPressedMovement: (BuildContext context, MovementSubmodel movement) =>
                                              Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movementSubmodel': movement}),
                                        )
                                      ]))),
                              SizedBox(
                                height: 150,
                              )
                            ]),
                          ],
                        )),
                  )));
        } else {
          return SizedBox();
        }
      });
    });
  }

  //TODO: Adapt when home view is ready
  Widget showButton(CourseEnrollment courseEnrollment, BuildContext context, User user, Course course, List<Class> classes) {
    return courseEnrollment == null
        ? Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                OlukoPrimaryButton(
                  title: OlukoLocalizations.get(context, 'start'),
                  onPressed: () {
                    BlocProvider.of<CourseEnrollmentBloc>(context)..create(user, course);
                    Navigator.pushNamed(context, routeLabels[RouteEnum.root]);
                  },
                ),
              ],
            ))
        : SizedBox(
            height: 15,
          );
  }

  Widget showVideoPlayer(String videoUrl) {
    return OlukoCustomVideoPlayer(
        useConstraints: true,
        videoUrl: videoUrl,
        autoPlay: false,
        whenInitialized: (ChewieController chewieController) => this.setState(() {
              _controller = chewieController;
            }));
  }

  List<Widget> _confirmDialogContent() {
    return [
      Icon(Icons.warning_amber_rounded, color: Colors.white, size: 100),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(OlukoLocalizations.get(context, 'enrollWarning'), textAlign: TextAlign.center, style: OlukoFonts.olukoBigFont()),
      )
    ];
  }
}
