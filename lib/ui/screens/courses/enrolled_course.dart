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
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/video_player_helper.dart';
import 'package:oluko_app/models/class.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/course_statistics.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/submodels/class_item.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
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
import 'package:oluko_app/ui/screens/courses/enrolled_course_list_of_classes.dart';
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
      {Key key, this.course, this.fromCoach = false, this.isCoachRecommendation = false, this.courseEnrollment, this.courseIndex, this.fromHome = false})
      : super(key: key);

  @override
  _EnrolledCourseState createState() => _EnrolledCourseState();
}

class _EnrolledCourseState extends State<EnrolledCourse> {
  final _formKey = GlobalKey<FormState>();
  User _user;
  AuthSuccess _userState;
  List<Class> _classes;
  bool _disableAction = false;
  bool _isVideoPlaying = false;
  bool isCourseEnrolled = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ClassSubscriptionBloc>(context).getStream();
    BlocProvider.of<StatisticsSubscriptionBloc>(context).getStream();
    BlocProvider.of<VideoBloc>(context).getAspectRatio(widget.course.video);
    _videoPlayerActions();
  }

  @override
  void dispose() {
    super.dispose();
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
          }
          return form();
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget form() {
    return BlocConsumer<CourseEnrollmentBloc, CourseEnrollmentState>(
      listener: (context, enrollmentState) {
        if (enrollmentState is CreateEnrollmentSuccess) {
          BlocProvider.of<CourseEnrollmentListBloc>(context).getCourseEnrollmentsByUser(_user.uid);
          Navigator.pushNamed(context, routeLabels[RouteEnum.root]);
        }
      },
      builder: (context, enrollmentState) {
        if (enrollmentState is GetAllEnrollmentSuccess) {
          isCourseEnrolled = enrollmentState.enrolledCourses.where((courseEnrollment) => courseEnrollment.course.id == widget.course.id).toList().isNotEmpty;
        }
        return BlocBuilder<ClassSubscriptionBloc, ClassSubscriptionState>(
          builder: (context, classState) {
            if (classState is ClassSubscriptionSuccess) {
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
                                physics: OlukoNeumorphism.listViewPhysicsEffect,
                                padding: EdgeInsets.zero,
                                addAutomaticKeepAlives: false,
                                addRepaintBoundaries: false,
                                children: [
                                  OlukoVideoPreview(
                                    showBackButton: true,
                                    image: widget.course.posterImage ?? widget.course.image,
                                    video: VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: widget.course.videoHls, videoUrl: widget.course.video),
                                    onBackPressed: () => Navigator.pop(context),
                                    onPlay: () => widget.playPauseVideo(),
                                    videoVisibilty: _isVideoPlaying,
                                    bottomWidgets: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                        child: _courseTitle(),
                                      ),
                                    ],
                                  ),
                                  showEnrollButton(context),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15, left: 15, top: 5),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10.0, right: 10),
                                            child: _courseDescription(),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 25.0),
                                            child: _classesText(context),
                                          ),
                                          CourseClassCardsList(
                                            classes: _classes,
                                            course: widget.course,
                                            courseEnrollment: widget.courseEnrollment,
                                            courseIndex: widget.courseIndex,
                                          )
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
                          color: OlukoColors.black,
                          child: Stack(
                            children: [
                              ListView(
                                physics: OlukoNeumorphism.listViewPhysicsEffect,
                                addAutomaticKeepAlives: false,
                                addRepaintBoundaries: false,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 3),
                                    child: OverlayVideoPreview(
                                      image: widget.course.posterImage ?? widget.course.image,
                                      video: VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: widget.course.videoHls, videoUrl: widget.course.video),
                                      showBackButton: true,
                                      showHeartButton: true,
                                      showShareButton: true,
                                      onBackPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                  showEnrollButton(context),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15, left: 15, top: 0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _courseTitle(),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10.0, right: 10),
                                            child: _courseDuration(context),
                                          ),
                                          buildStatistics(),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10.0, right: 10),
                                            child: _courseDescription(),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 25.0),
                                            child: _classesText(context),
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
  }

  Text _classesText(BuildContext context) {
    return Text(
      OlukoLocalizations.get(context, 'classes'),
      style: OlukoFonts.olukoSubtitleFont(customFontWeight: FontWeight.bold),
    );
  }

  Text _courseDescription() {
    return Text(
      widget.course.description ?? '',
      style: OlukoFonts.olukoBigFont(
        customFontWeight: FontWeight.normal,
        customColor: OlukoColors.grayColor,
      ),
    );
  }

  Text _courseDuration(BuildContext context) {
    return Text(
      //TODO: change weeks number
      CourseUtils.toCourseDuration(
        int.tryParse(widget.course.duration) ?? 0,
        widget.course.classes != null ? widget.course.classes.length : 0,
        context,
      ),
      style: OlukoFonts.olukoBigFont(
        customFontWeight: FontWeight.normal,
        customColor: OlukoColors.grayColor,
      ),
    );
  }

  Text _courseTitle() {
    return Text(
      widget.course.name,
      style: OlukoFonts.olukoTitleFont(customFontWeight: FontWeight.bold),
    );
  }

  Widget showEnrollButton(BuildContext context) {
    if (!isCourseEnrolled) {
      return Padding(
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
                    if (_userState.user.firstAppInteractionAt == null) {
                      BlocProvider.of<AuthBloc>(context).storeFirstsUserInteraction(userIteraction: UserInteractionEnum.firstAppInteraction);
                    }
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
                    if (_userState.user.firstAppInteractionAt == null) {
                      BlocProvider.of<AuthBloc>(context).storeFirstsUserInteraction(userIteraction: UserInteractionEnum.firstAppInteraction);
                    }
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
      );
    } else {
      return const SizedBox();
    }
  }

  Widget buildStatistics() {
    return BlocBuilder<StatisticsSubscriptionBloc, StatisticsSubscriptionState>(
      builder: (context, statisticsState) {
        if (statisticsState is StatisticsSubscriptionSuccess) {
          final CourseStatistics courseStatistics = statisticsState.courseStatistics.where((element) => element.courseId == widget.course.id).toList()[0];
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
      classes: CourseService.getCourseClasses(_classes, course: widget.course),
      onPressedMovement: (BuildContext context, MovementSubmodel movement) {
        widget.playPauseVideo();
        Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movementSubmodel': movement});
      },
    );
  }

  void _videoPlayerActions() {
    widget.playPauseVideo = () => setState(() {
          _isVideoPlaying = !_isVideoPlaying;
        });
    widget.closeVideo = () => setState(() {
          if (_isVideoPlaying) {
            _isVideoPlaying = !_isVideoPlaying;
          }
        });
  }
}
