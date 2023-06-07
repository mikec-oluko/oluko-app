import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:nil/nil.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/class/class_subscription_bloc.dart';
import 'package:oluko_app/blocs/course/course_user_interaction_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart' as CourseEnrollmentBlocLoading show Loading;
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_stream_bloc.dart';
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
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/course_service.dart';
import 'package:oluko_app/ui/components/class_expansion_panel.dart';
import 'package:oluko_app/ui/components/schedule_modal_content.dart';
import 'package:oluko_app/ui/components/modal_people_enrolled.dart';
import 'package:oluko_app/ui/components/oluko_primary_button.dart';
import 'package:oluko_app/ui/components/overlay_video_preview.dart';
import 'package:oluko_app/ui/components/pinned_header.dart';
import 'package:oluko_app/ui/components/statistics_chart.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_divider.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_primary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_neumorphic_secondary_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_video_preview.dart';
import 'package:oluko_app/utils/bottom_dialog_utils.dart';
import 'package:oluko_app/utils/course_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/utils/sound_player.dart';
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
      {Key key, this.course, this.fromCoach = false, this.isCoachRecommendation = false, this.courseEnrollment, this.courseIndex, this.fromHome = false})
      : super(key: key);

  @override
  _CourseMarketingState createState() => _CourseMarketingState();
}

class _CourseMarketingState extends State<CourseMarketing> {
  final _formKey = GlobalKey<FormState>();
  User _user;
  AuthSuccess _userState;
  final int _batchClassMaxRange = 8;
  bool _disableAction = false;
  bool _isVideoPlaying = false;
  bool _courseLiked = false;
  bool isCourseEnrolled = false;
  bool _isSavingLikedCourse = false;
  double _pixelsToReload;
  List<Class> _classes = [];
  List<Class> _growingClassList = [];
  List<Class> _allCourseClasses = [];
  final ScrollController _scrollController = ScrollController();
  final SoundPlayer _soundPlayer = SoundPlayer();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<StatisticsSubscriptionBloc>(context).getStream();
    BlocProvider.of<ClassSubscriptionBloc>(context).getStream();
    BlocProvider.of<VideoBloc>(context).getAspectRatio(widget.course.video);
    _scrollCotrollerInit();
    _videoPlayerActions();
    _courseLiked = false;
    _soundPlayer.init(SessionCategory.playback);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _soundPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _pixelsToReload = ScreenUtils.height(context) * 0.60;
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
        }
        // BlocProvider.of<CourseUserIteractionBloc>(context).isCourseLiked(courseId: widget.course.id, userId: _userState.user.id);
        return form();
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget form() {
    return BlocConsumer<CourseEnrollmentBloc, CourseEnrollmentState>(listener: (context, courseEnrollmentState) {
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
    }, builder: (context, enrollmentState) {
      if (enrollmentState is GetAllEnrollmentSuccess) {
        isCourseEnrolled = enrollmentState.enrolledCourses.where((courseEnrollment) => courseEnrollment.course.id == widget.course.id).toList().isNotEmpty;
      }
      return BlocBuilder<ClassSubscriptionBloc, ClassSubscriptionState>(builder: (context, classState) {
        if (classState is ClassSubscriptionSuccess) {
          _classes = classState.classes;
          _allCourseClasses = CourseService.getCourseClasses(_classes, course: widget.course);
          _getMoreClasses();
          return Form(
              key: _formKey,
              child: Scaffold(body: OlukoNeumorphism.isNeumorphismDesign ? neumorphicMarketingView(enrollmentState) : defaultMarketingView(context)));
        } else {
          return nil;
        }
      });
    });
  }

  Container defaultMarketingView(BuildContext context) {
    return Container(
        color: OlukoColors.black,
        child: Stack(
          children: [
            ListView(addAutomaticKeepAlives: false, addRepaintBoundaries: false, children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: OverlayVideoPreview(
                    image: widget.course.image,
                    video: VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: widget.course.videoHls, videoUrl: widget.course.video),
                    showBackButton: true,
                    showHeartButton: true,
                    showShareButton: true,
                    onBackPressed: () => Navigator.pop(context)),
              ),
              showEnrollButton(context),
              Padding(
                  padding: const EdgeInsets.only(right: 15, left: 15, top: 0),
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
                            CourseUtils.toCourseDuration(
                                int.tryParse(widget.course.duration) ?? 0, widget.course.classes != null ? widget.course.classes.length : 0, context),
                            style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
                          ),
                        ),
                        buildStatistics(),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, right: 10),
                          child: Text(
                            widget.course.description ?? '',
                            style: OlukoFonts.olukoBigFont(customFontWeight: FontWeight.normal, customColor: OlukoColors.grayColor),
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
        ));
  }

  Widget neumorphicMarketingView(CourseEnrollmentState courseEnrollmentState) {
    return Container(
      color: OlukoNeumorphismColors.finalGradientColorDark,
      child: CustomScrollView(
        controller: _scrollController,
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
                video: VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: widget.course.videoHls, videoUrl: widget.course.video),
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
                      CourseUtils.toCourseDuration(
                          int.tryParse(widget.course.duration) ?? 0, widget.course.classes != null ? widget.course.classes.length : 0, context),
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
          SliverVisibility(
            visible: !isCourseEnrolled,
            sliver: SliverPersistentHeader(
                pinned: true,
                delegate: SliverAppBarDelegate(
                  ScreenUtils.height(context) * 0.12,
                  ScreenUtils.height(context) * 0.12,
                  child: Container(color: OlukoNeumorphismColors.finalGradientColorDark, child: showEnrollButton(context)),
                )),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.only(right: 15, left: 15),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: ListView(
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    shrinkWrap: true,
                    primary: false,
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
    );
  }

  Widget showEnrollButton(BuildContext context) {
    if (!isCourseEnrolled) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (OlukoNeumorphism.isNeumorphismDesign)
              OlukoNeumorphicPrimaryButton(
                isDisabled: _disableAction,
                thinPadding: true,
                title: OlukoLocalizations.get(context, 'enroll'),
                onPressed: () {
                  if (!_disableAction) {
                    showScheduleDialog(context);
                  }
                },
              )
            else
              OlukoPrimaryButton(
                title: OlukoLocalizations.get(context, 'enroll'),
                isDisabled: _disableAction,
                onPressed: () {
                  if (!_disableAction) {
                    showScheduleDialog(context);
                  }
                },
              ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  void showScheduleDialog(BuildContext context) {
    BottomDialogUtils.showBottomDialog(
      content: ScheduleModalContent(
        course: widget.course,
        scheduleRecommendations: widget.course.scheduleRecommendations,
        user: _user,
        totalClasses: _allCourseClasses.length,
        firstAppInteractionAt: _userState.user.firstAppInteractionAt,
        isCoachRecommendation: widget.isCoachRecommendation,
        disableAction: _disableAction,
        blocAuth: BlocProvider.of<AuthBloc>(context),
        blocCourseEnrollment: BlocProvider.of<CourseEnrollmentBloc>(context),
        blocRecommendation: BlocProvider.of<RecommendationBloc>(context),
        onEnrollAction: () {
          setState(() {
            _disableAction = true;
          });
        },
      ),
      isScrollControlled: true,
      context: context,
    );
  }

  Future<void> enrollAction(BuildContext context) async {
    if (_disableAction == false) {
      if (_userState.user.firstAppInteractionAt == null) {
        BlocProvider.of<AuthBloc>(context).storeFirstsUserInteraction(userIteraction: UserInteractionEnum.firstAppInteraction);
      }
      BlocProvider.of<CourseEnrollmentBloc>(context).create(_user, widget.course);
      if (!widget.isCoachRecommendation) {
        BlocProvider.of<RecommendationBloc>(context).removeRecomendedCourse(_user.uid, widget.course.id);
      }
      await _soundPlayer.playAsset(soundEnum: SoundsEnum.enroll);
    }
    _setDisableUnrollAction();
  }

  void _setDisableUnrollAction() {
    setState(() {
      _disableAction = true;
    });
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
                  if (_userState.user.firstAppInteractionAt == null) {
                    BlocProvider.of<AuthBloc>(context).storeFirstsUserInteraction(userIteraction: UserInteractionEnum.firstAppInteraction);
                  }
                  BlocProvider.of<CourseEnrollmentBloc>(context).create(_user, widget.course);

                  if (!widget.isCoachRecommendation) {
                    BlocProvider.of<RecommendationBloc>(context).removeRecomendedCourse(_user.uid, widget.course.id);
                  }
                }
                _setDisableUnrollAction();
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
                _setDisableUnrollAction();
              },
            ),
        ],
      ),
    );
  }

  Widget buildStatistics() {
    return BlocBuilder<StatisticsSubscriptionBloc, StatisticsSubscriptionState>(builder: (context, statisticsState) {
      if (statisticsState is StatisticsSubscriptionSuccess) {
        List<CourseStatistics> courseStatistics = statisticsState.courseStatistics.where((element) => element.courseId == widget.course.id).toList();

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
      totalClasses: _allCourseClasses.length,
      classes: _growingClassList,
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
      padding: OlukoNeumorphism.buttonBackPaddingFromTop,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 15.0),
            height: 65,
            width: 65,
            child: OlukoNeumorphicSecondaryButton(
              title: '',
              useBorder: true,
              isExpanded: false,
              thinPadding: true,
              onlyIcon: true,
              icon: const Icon(Icons.arrow_back, color: OlukoColors.grayColor),
              onPressed: onBackPressed,
            ),
          ),
          const Expanded(child: SizedBox()),
          if (_isVideoPlaying)
            const SizedBox()
          else
            BlocBuilder<CourseUserIteractionBloc, CourseUserInteractionState>(
              builder: (context, state) {
                if (state is CourseLikedSuccess) {
                  _courseLiked = state.courseLiked != null ? state.courseLiked.isActive : false;
                  _isSavingLikedCourse = false;
                }
                return topButtonsBackground(Image.asset(_courseLiked ? 'assets/courses/heart.png' : 'assets/courses/grey_heart_outlined.png', scale: 3.5),
                    onPressed: changeLikeState);
              },
            ),
          if (_isVideoPlaying)
            const SizedBox()
          else
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 15),
              child: topButtonsBackground(
                Image.asset(
                  'assets/courses/grey_share_outlined.png',
                  scale: 3.5,
                ),
                onPressed: () => Navigator.pushNamed(
                  context,
                  routeLabels[RouteEnum.courseShareView],
                  arguments: {'currentUser': _userState.user, 'courseToShare': widget.course},
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget topButtonsBackground(Widget child, {Function onPressed}) {
    return Container(
      padding: const EdgeInsets.only(left: 15.0),
      height: 55,
      width: 65,
      child: OlukoNeumorphicSecondaryButton(
        title: '',
        useBorder: true,
        isExpanded: false,
        thinPadding: true,
        onlyIcon: true,
        icon: child,
        onPressed: onPressed != null ? () => onPressed() : null,
      ),
    );
  }

  void _videoPlayerActions() {
    widget.isVideoPlaying = () => setState(() {
          _isVideoPlaying = !_isVideoPlaying;
        });
    widget.closeVideo = () => setState(() {
          if (_isVideoPlaying) {
            _isVideoPlaying = !_isVideoPlaying;
          }
        });
  }

  void changeLikeState() {
    if (!_isSavingLikedCourse) {
      setState(() {
        _courseLiked = !_courseLiked;
      });
      BlocProvider.of<CourseUserIteractionBloc>(context).updateCourseLikeValue(userId: _userState.user.id, courseId: widget.course.id);
    }
    setState(() {
      _isSavingLikedCourse = true;
    });
  }

  void _scrollCotrollerInit() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > _pixelsToReload * 0.85) {
        if (_growingClassList.length != _allCourseClasses.length) {
          _getMoreClasses();
          _pixelsToReload += _scrollController.position.extentInside;
          setState(() {});
        }
      }
    });
  }

  void _getMoreClasses() => _growingClassList = _allCourseClasses.isNotEmpty
      ? [
          ..._allCourseClasses.getRange(
              0,
              _allCourseClasses.length > _growingClassList.length + _batchClassMaxRange
                  ? _growingClassList.length + _batchClassMaxRange
                  : _allCourseClasses.length)
        ]
      : [];
}
