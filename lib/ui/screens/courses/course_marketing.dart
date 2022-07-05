import 'package:audioplayers/audioplayers.dart';
import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/class/class_subscription_bloc.dart';
import 'package:oluko_app/blocs/course/course_user_interaction_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart' as CourseEnrollmentBlocLoading show Loading;
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_stream_bloc.dart';
import 'package:oluko_app/blocs/movement_bloc.dart';
import 'package:oluko_app/blocs/recommendation_bloc.dart';
import 'package:oluko_app/blocs/statistics/statistics_subscription_bloc.dart';
import 'package:oluko_app/blocs/subscribed_course_users_bloc.dart';
import 'package:oluko_app/blocs/user_progress_list_bloc.dart';
import 'package:oluko_app/blocs/user_progress_stream_bloc.dart';
import 'package:oluko_app/blocs/video_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/course_helper.dart';
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
import 'package:oluko_app/utils/sound_player.dart';
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
  bool _disableAction = false;
  bool _isVideoPlaying = false;
  bool _courseLiked = false;

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
    _courseLiked = false;
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
          BlocProvider.of<VideoBloc>(context).getAspectRatio(widget.course.video);
        }
        BlocProvider.of<CourseUserIteractionBloc>(context).isCourseLiked(courseId: widget.course.id, userId: _userState.user.id);

        return form();
      } else {
        return SizedBox();
      }
    });
  }

  Widget form() {
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
                          color: OlukoColors.black,
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
                                            style: OlukoFonts.olukoTitleFont(customFontWeight: FontWeight.bold),
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
                                                style: OlukoFonts.olukoSubtitleFont(customFontWeight: FontWeight.bold),
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
                  bottomWidgets: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text(
                          widget.course.name,
                          style: OlukoFonts.olukoTitleFont(customFontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        CourseUtils.toCourseDuration(int.tryParse(widget.course.duration) ?? 0,
                            widget.course.classes != null ? widget.course.classes.length : 0, context),
                        style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
                      ),
                    ),
                  ],
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
                    child: ListView(
                      shrinkWrap: true,
                      primary: false,
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildStatistics(),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, right: 10),
                          child: Text(
                            widget.course.description ?? '',
                            style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
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
    bool showEnorollButton = (courseEnrollment != null && courseEnrollment.isUnenrolled == true) ||
        (courseEnrollment == null || courseEnrollment.completion >= 1);
    if (showEnorollButton) {
      return BlocListener<CourseEnrollmentBloc, CourseEnrollmentState>(
        listener: (context, courseEnrollmentState) {
          if (courseEnrollmentState is CreateEnrollmentSuccess) {
            BlocProvider.of<CourseEnrollmentListStreamBloc>(context).getStream(_user.uid);
            if (ModalRoute.of(context).settings.name != routeLabels[RouteEnum.root]) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                routeLabels[RouteEnum.root],
                (route) => false,
                arguments: {
                  'tab': 0,
                },
              );
            } else {
              Navigator.popUntil(
                context,
                ModalRoute.withName(routeLabels[RouteEnum.root]),
              );
            }
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
                    enrollAction(context);
                  },
                )
              else
                OlukoPrimaryButton(
                  title: OlukoLocalizations.get(context, 'enroll'),
                  onPressed: () {
                    enrollAction(context);
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

  Future<void> enrollAction(BuildContext context) async {
    if (_disableAction == false) {
      BlocProvider.of<CourseEnrollmentBloc>(context).create(_user, widget.course);
      if (!widget.isCoachRecommendation) {
        BlocProvider.of<RecommendationBloc>(context).removeRecomendedCourse(_user.uid, widget.course.id);
      }
      await SoundPlayer.playAsset(soundEnum: SoundsEnum.enroll);
    }
    _disableAction = true;
  }

  Widget enrollButton() {
    return Padding(
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
    );
  }

  Widget buildStatistics() {
    return BlocBuilder<StatisticsSubscriptionBloc, StatisticsSubscriptionState>(builder: (context, statisticsState) {
      if (statisticsState is StatisticsSubscriptionSuccess) {
        List<CourseStatistics> courseStatistics =
            statisticsState.courseStatistics.where((element) => element.courseId == widget.course.id).toList();

        final CourseStatistics courseStatistic = courseStatistics.isNotEmpty ? courseStatistics[0] : null;
        return Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: StatisticChart(
              courseStatistics: courseStatistic,
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
    return ClassExpansionPanels(
      classes: CourseService.getCourseClasses(widget.course, _classes),
      onPressedMovement: (BuildContext context, MovementSubmodel movement) {
        if (widget.closeVideo != null) {
          widget.closeVideo();
        }
        Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movementSubmodel': movement});
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
            if (_isVideoPlaying)
              const SizedBox()
            else
              BlocBuilder<CourseUserIteractionBloc, CourseUserInteractionState>(
                builder: (context, state) {
                  if (state is CourseLikedSuccess) {
                    _courseLiked = state.courseLiked != null ? state.courseLiked.isActive : false;
                  }
                  return GestureDetector(
                    onTap: () {
                      BlocProvider.of<CourseUserIteractionBloc>(context)
                          .updateCourseLikeValue(userId: _userState.user.id, courseId: widget.course.id);
                    },
                    child: topButtonsBackground(
                        Image.asset(_courseLiked ? 'assets/courses/heart.png' : 'assets/courses/grey_heart_outlined.png', scale: 3.5)),
                  );
                },
              ),
            if (_isVideoPlaying)
              const SizedBox()
            else
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 15),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.courseShareView],
                      arguments: {'currentUser': _userState.user, 'courseToShare': widget.course}),
                  child: topButtonsBackground(Image.asset(
                    'assets/courses/grey_share_outlined.png',
                    scale: 3.5,
                  )),
                ),
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
}
