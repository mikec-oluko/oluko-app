import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/class/class_subscription_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart' as CourseEnrollmentBlocLoading show Loading;
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_stream_bloc.dart';
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
import 'package:oluko_app/utils/course_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/time_converter.dart';
import 'package:sliver_tools/sliver_tools.dart';

class CourseMarketing extends StatefulWidget {
  final Course course;
  final bool fromCoach;
  final bool isCoachRecommendation;
  final CourseEnrollment courseEnrollment;
  final int courseIndex;
  final bool fromHome;
  Function isVideoPlaying;
  Function closeVideo;

  CourseMarketing(
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
  _CourseMarketingState createState() => _CourseMarketingState();
}

class _CourseMarketingState extends State<CourseMarketing> {
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
            if ((enrollmentState is GetEnrollmentSuccess || enrollmentState is CourseEnrollmentBlocLoading.Loading) &&
                classState is ClassSubscriptionSuccess) {
              _classes = classState.classes;
              return Form(
                  key: _formKey,
                  child: Scaffold(
                      body: OlukoNeumorphism.isNeumorphismDesign
                          ? customScrollView(enrollmentState)
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
                                    showEnrollButton(
                                        enrollmentState is GetEnrollmentSuccess ? enrollmentState.courseEnrollment : null, context),
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
                                                  CourseUtils.toCourseDuration(int.tryParse(widget.course.duration) ?? 0,
                                                      widget.course.classes != null ? widget.course.classes.length : 0, context),
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
                                              if (!OlukoNeumorphism.isNeumorphismDesign)
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

  Widget customScrollView(CourseEnrollmentState courseEnrollmentState) {
    return SafeArea(
      child: Container(
        color: OlukoNeumorphismColors.finalGradientColorDark,
        child: CustomScrollView(
          slivers: [
            SliverStack(positionedAlignment: Alignment.bottomRight, children: [
              SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverAppBarDelegate(ScreenUtils.height(context) * 0.14, ScreenUtils.height(context) * 0.14,
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        color: OlukoNeumorphismColors.finalGradientColorDark,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: OlukoNeumorphicDivider(
                            isFadeOut: true,
                          ),
                        ),
                      ))),
              SliverToBoxAdapter(
                child: OlukoVideoPreview(
                  image: widget.course.posterImage ?? widget.course.image,
                  video: widget.course.video,
                  onBackPressed: () => Navigator.pop(context),
                  onPlay: () => widget.isVideoPlaying(),
                  videoVisibilty: _isVideoPlaying,
                ),
              ),
              SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverAppBarDelegate(
                    ScreenUtils.height(context) * 0.11,
                    ScreenUtils.height(context) * 0.11,
                    child: topButtons(() => Navigator.pop(context), _isVideoPlaying),
                  )),
            ]),
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverAppBarDelegate(
                ScreenUtils.height(context) * 0.08,
                ScreenUtils.height(context) * 0.08,
                child: Container(
                  alignment: Alignment.centerLeft,
                  color: OlukoNeumorphismColors.finalGradientColorDark,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                      widget.course.name,
                      style: OlukoFonts.olukoTitleFont(custoFontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
                delegate: SliverChildListDelegate([
              Padding(
                padding: EdgeInsets.only(right: 15, left: 15, top: 10),
                child: Text(
                  CourseUtils.toCourseDuration(
                      int.tryParse(widget.course.duration) ?? 0, widget.course.classes != null ? widget.course.classes.length : 0, context),
                  style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
                ),
              ),
            ])),
            if (courseEnrollmentState is GetEnrollmentSuccess)
              SliverVisibility(
                visible: (courseEnrollmentState.courseEnrollment != null && courseEnrollmentState.courseEnrollment.isUnenrolled == true) ||
                    courseEnrollmentState.courseEnrollment == null,
                sliver: SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverAppBarDelegate(
                      ScreenUtils.height(context) * 0.12,
                      ScreenUtils.height(context) * 0.12,
                      child: Container(
                          color: OlukoNeumorphismColors.finalGradientColorDark,
                          child: showEnrollButton(courseEnrollmentState.courseEnrollment, context)),
                    )),
              )
            else
              SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.only(right: 15, left: 15),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildStatistics(),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, right: 10),
                          child: Text(
                            widget.course.description ?? '',
                            style: OlukoFonts.olukoBigFont(custoFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0, bottom: 15),
                          child: OlukoNeumorphicDivider(),
                        ),
                        buildClassExpansionPanels()
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 150,
                )
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget showEnrollButton(CourseEnrollment courseEnrollment, BuildContext context) {
    if ((courseEnrollment != null && courseEnrollment.isUnenrolled == true) ||
        (courseEnrollment == null || courseEnrollment.completion >= 1)) {
      return BlocListener<CourseEnrollmentBloc, CourseEnrollmentState>(
        listener: (context, courseEnrollmentState) {
          if (courseEnrollmentState is CreateEnrollmentSuccess) {
            BlocProvider.of<CourseEnrollmentListStreamBloc>(context).getStream(_user.uid);
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
          ),
        ),
      );
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
        if (widget.closeVideo != null) {
          widget.closeVideo();
        }
        Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movement': movement});
      },
    );
  }

  _peopleAction(List<dynamic> users, List<dynamic> favorites, BuildContext context) {
    BottomDialogUtils.showBottomDialog(
        context: context,
        content: SizedBox(
          height: ScreenUtils.height(context) * 0.5,
          child: ModalPeopleEnrolled(
            userId: _user.uid,
            users: users,
            favorites: favorites,
          ),
        ));
  }
}

Widget topButtons(Function() onBackPressed, bool _isVideoPlaying) {
  return Padding(
      padding: EdgeInsets.only(top: 15),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: GestureDetector(
                onTap: onBackPressed,
                child: topButtonsBackground(
                  Image.asset(
                    'assets/courses/left_back_arrow.png',
                    scale: 3.5,
                  ),
                )),
          ),
          Expanded(child: SizedBox()),
          _isVideoPlaying ? SizedBox() : topButtonsBackground(Image.asset('assets/courses/grey_heart_outlined.png', scale: 3.5)),
          _isVideoPlaying
              ? SizedBox()
              : Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 15),
                  child: topButtonsBackground(Image.asset(
                    'assets/courses/grey_share_outlined.png',
                    scale: 3.5,
                  )),
                )
        ],
      ));
}

Widget topButtonsBackground(Widget child) {
  return Neumorphic(
    style: OlukoNeumorphism.getNeumorphicStyleForCircleElement(),
    child: Container(
        decoration: const BoxDecoration(
          color: OlukoNeumorphismColors.finalGradientColorDark,
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        height: 55,
        width: 55,
        child: child),
  );
}
