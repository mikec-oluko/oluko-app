import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_bloc.dart';
import 'package:oluko_app/blocs/challenge/upcoming_challenge_bloc.dart';
import 'package:oluko_app/blocs/class/class_bloc.dart';
import 'package:oluko_app/blocs/class/class_subscription_bloc.dart';
import 'package:oluko_app/blocs/course/course_friend_recommended_bloc.dart';
import 'package:oluko_app/blocs/course/course_liked_courses_bloc.dart';
import 'package:oluko_app/blocs/course/course_subscription_bloc.dart';
import 'package:oluko_app/blocs/course/course_user_interaction_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_stream_bloc.dart';
import 'package:oluko_app/blocs/enrollment_audio_bloc.dart';
import 'package:oluko_app/blocs/gallery_video_bloc.dart';
import 'package:oluko_app/blocs/points_card_bloc.dart';
import 'package:oluko_app/blocs/profile/profile_avatar_bloc.dart';
import 'package:oluko_app/blocs/profile/profile_bloc.dart';
import 'package:oluko_app/blocs/profile/profile_cover_image_bloc.dart';
import 'package:oluko_app/blocs/segment_bloc.dart';
import 'package:oluko_app/blocs/story_bloc.dart';
import 'package:oluko_app/blocs/subscribed_course_users_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/blocs/user_progress_list_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/oluko_exception_message.dart';
import 'package:oluko_app/helpers/profile_helper_functions.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/collected_card.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_category.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/models/points_card.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/user_statistics.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/hand_widget.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/points_card_component.dart';
import 'package:oluko_app/ui/components/stories_header.dart';
import 'package:oluko_app/ui/components/user_profile_information.dart';
import 'package:oluko_app/ui/newDesignComponents/courses_and_people_section_for_home.dart';
import 'package:oluko_app/ui/newDesignComponents/friends_recommended_courses.dart';
import 'package:oluko_app/ui/newDesignComponents/my_list_of_courses_home.dart';
import 'package:oluko_app/ui/newDesignComponents/upload_profile_media_menu.dart';
import 'package:oluko_app/ui/newDesignComponents/user_assessments_videos_component.dart';
import 'package:oluko_app/ui/newDesignComponents/user_challenges_component.dart';
import 'package:oluko_app/ui/newDesignComponents/user_cover_image_component.dart';
import 'package:oluko_app/ui/newDesignComponents/user_transformation_journey_section.dart';
import 'package:oluko_app/ui/screens/welcome_video_first_time_login.dart';
import 'package:oluko_app/utils/app_messages.dart';
import 'package:oluko_app/utils/course_utils.dart';
import 'package:oluko_app/utils/dialog_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'package:oluko_app/models/workout_day.dart';
import 'package:oluko_app/models/workout_schedule.dart';
import 'package:oluko_app/blocs/course/course_home_bloc.dart';
import 'package:oluko_app/utils/schedule_utils.dart';

class HomeNeumorphicLatestDesign extends StatefulWidget {
  final UserResponse currentUser;
  final List<CourseEnrollment> courseEnrollments;
  final AuthSuccess authState;
  final bool scrollToUpcomingWorkouts;

  const HomeNeumorphicLatestDesign({this.currentUser, this.courseEnrollments, this.authState, this.scrollToUpcomingWorkouts = false}) : super();

  @override
  State<HomeNeumorphicLatestDesign> createState() => _HomeNeumorphicLatestDesignState();
}

class _HomeNeumorphicLatestDesignState extends State<HomeNeumorphicLatestDesign> {
  final bool _showLogo = true;
  bool _showStories = false;
  UserStatistics _userStats;
  Map<String, UserProgress> _usersProgress = {};
  int _courseIndex = 0;
  List<Course> _courses = [];
  List<CourseEnrollment> _courseEnrollmentList = [];
  List<ChallengeNavigation> _listOfChallenges = [];
  UpcomingChallengesState _challengesCardsState;
  List<TransformationJourneyUpload> _transformationJourneyContent = [];
  List<TaskSubmission> _assessmentVideosContent = [];
  Success successState;
  UserResponse _currentUserLatestVersion;
  bool _videoSeen = false;
  bool _hasScheduledCourses = false;
  bool _isPanelOpen = false;
  final GlobalKey<State<StatefulWidget>> _upcomingWorkoutsKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _logoKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _storiesKey = GlobalKey();
  SliverAppBar _topBar;
  ScrollController _scrollController;

  @override
  void initState() {
    BlocProvider.of<ClassSubscriptionBloc>(context).getStream();
    setState(() {
      _courseEnrollmentList = widget.courseEnrollments;
      _currentUserLatestVersion = widget.currentUser;
    });
    super.initState();
    if (widget.scrollToUpcomingWorkouts) {
      _scrollController = ScrollController();
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToUpcomingWorkouts());
    }
  }

  @override
  void dispose() {
    if (_scrollController != null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          _currentUserLatestVersion = state.user;
          return BlocBuilder<CourseEnrollmentListStreamBloc, CourseEnrollmentListStreamState>(
            builder: (context, state) {
              if (state is CourseEnrollmentsByUserStreamSuccess) {
                _courseEnrollmentList = state.courseEnrollments;
              }
              return getHomeContent(context);
            },
          );
        } else {
          return OlukoCircularProgressIndicator();
        }
      },
    );
  }

  Future scrollToUpcomingWorkouts() async {
    final upcomingWorkoutElement = _upcomingWorkoutsKey.currentContext.findRenderObject() as RenderBox;
    final topBarElement = _logoKey.currentContext.findRenderObject() as RenderBox;
    final storiesElement = _storiesKey.currentContext.findRenderObject() as RenderBox;
    final double topBarHeight = topBarElement.size.height + storiesElement.size.height;
    final Offset position = upcomingWorkoutElement.localToGlobal(Offset.zero);
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(position.dy - topBarHeight - 70, duration: const Duration(seconds: 1), curve: Curves.easeIn);
    }
  }

  StatefulWidget getHomeContent(BuildContext context) {
    if (_currentUserLatestVersion.firstAppInteractionAt == null && _courseEnrollmentList.isEmpty) {
      return WelcomeVideoFirstTimeLogin(
        videoSeen: (value) {
          setState(() {
            _markWelcomeVideoAsSeen(value, context);
          });
        },
      );
    } else {
      return BlocBuilder<CourseEnrollmentListStreamBloc, CourseEnrollmentListStreamState>(
        builder: (context, state) {
          if (state is CourseEnrollmentsByUserStreamSuccess) {
            _courseEnrollmentList = state.courseEnrollments;
            if (_courseEnrollmentList.isNotEmpty) {
              BlocProvider.of<SubscribedCourseUsersBloc>(context)
                  .getCourseStatisticsUsers(_courseEnrollmentList[_courseIndex].course.id, _courseEnrollmentList[_courseIndex].createdBy);
            }
          }
          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return _stories(widget.authState);
              },
              body: Container(
                color: OlukoNeumorphismColors.appBackgroundColor,
                constraints: const BoxConstraints.expand(),
                child: ListView.builder(
                  controller: _scrollController,
                  physics: OlukoNeumorphism.listViewPhysicsEffect,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: false,
                  clipBehavior: Clip.none,
                  padding: EdgeInsets.zero,
                  itemCount: 1,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        _userCoverAndProfileDetails(),
                        _userCoursesSchedule(),
                        _enrolledCoursesAndPeople(),
                        myListOfCoursesAndFriendsRecommended(),
                        _challengesSection(),
                        _transformationPhotos(),
                        _assessmentVideos(),
                        _bottomSpaceContainer()
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      );
    }
  }

  SizedBox _bottomSpaceContainer() {
    return SizedBox(
      height: Platform.isIOS ? MediaQuery.of(context).size.height * 0.12 : MediaQuery.of(context).size.height * 0.05,
      width: MediaQuery.of(context).size.width,
    );
  }

  void _markWelcomeVideoAsSeen(bool value, BuildContext context) {
    _videoSeen = value;
    if (_currentUserLatestVersion.firstAppInteractionAt == null) {
      BlocProvider.of<AuthBloc>(context).storeFirstsUserInteraction(userInteraction: UserInteractionEnum.firstAppInteraction);
    }
  }

  List<Widget> _stories(AuthSuccess authState) {
    return [
      if (_showLogo) getLogo(authState) else const SliverToBoxAdapter(),
      if (GlobalConfiguration().getString('showStories') == 'true') getStoriesBar(context),
    ];
  }

  List<WorkoutDay> getThisWeekScheduledWorkouts() => ScheduleUtils.getThisWeekClasses(context, _courseEnrollmentList);

  Widget _userCoursesSchedule() {
    final List<WorkoutDay> thisWeekWorkouts = getThisWeekScheduledWorkouts();
    if (thisWeekWorkouts.isEmpty) {
      _hasScheduledCourses = false;
      return const SizedBox.shrink();
    }

    _hasScheduledCourses = true;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
      child: Column(
        children: [
          Align(
            key: _upcomingWorkoutsKey,
            alignment: Alignment.centerLeft,
            child: Text(OlukoLocalizations.get(context, 'upcomingWorkouts'),
                style: OlukoFonts.olukoSuperBigFont(
                  customFontWeight: FontWeight.w500,
                )),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _getScheduledWorkouts(thisWeekWorkouts),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToCourseSelectedScheduledClass(BuildContext context, WorkoutSchedule workoutSchedule) async {
    final DocumentSnapshot courseSnapshot = await workoutSchedule.courseEnrollment.course.reference.get();
    final Course selectedCourse = Course.fromJson(courseSnapshot.data() as Map<String, dynamic>);
    final courseIndex = _courses.indexWhere((course) => course.id == selectedCourse.id);
    final courseEnrollmentIndex = _courseEnrollmentList.indexWhere((courseEnrollment) => courseEnrollment.id == workoutSchedule.courseEnrollment.id);

    Navigator.pushNamed(
      context,
      routeLabels[RouteEnum.insideClass],
      arguments: {
        'courseEnrollment': _courseEnrollmentList[courseEnrollmentIndex],
        'classIndex': workoutSchedule.classIndex,
        'courseIndex': courseIndex,
        'actualCourse': selectedCourse
      },
    );
  }

  Future<void> _goToEditSchedule(BuildContext context, WorkoutSchedule workoutSchedule) async {
    BlocProvider.of<CourseHomeBloc>(context).getByCourseEnrollments([workoutSchedule.courseEnrollment]);
    final DocumentSnapshot courseSnapshot = await workoutSchedule.courseEnrollment.course.reference.get();
    final Course actualCourse = Course.fromJson(courseSnapshot.data() as Map<String, dynamic>);
    _isPanelOpen = false;
    Navigator.pushNamed(
      context,
      routeLabels[RouteEnum.courseHomePage],
      arguments: {
        'courseEnrollments': [workoutSchedule.courseEnrollment],
        'authState': widget.authState,
        'courses': [actualCourse],
        'user': _currentUserLatestVersion,
        'isFromHome': true,
        'openEditScheduleOnInit': true,
      },
    );
  }

  List<Widget> _getScheduledWorkouts(List<WorkoutDay> thisWeekWorkouts) {
    return thisWeekWorkouts.map((workout) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workout.day,
              style: OlukoFonts.olukoMediumFont(
                customColor: OlukoColors.white,
                customFontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: workout.scheduledWorkouts.map((scheduledWorkout) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: GestureDetector(
                          child: Text(
                            scheduledWorkout.className,
                            style: OlukoFonts.olukoMediumFont(
                              customColor: OlukoColors.yellow,
                              customFontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            _navigateToCourseSelectedScheduledClass(context, scheduledWorkout);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          if (!_isPanelOpen) {
                            _isPanelOpen = true;
                            _goToEditSchedule(context, scheduledWorkout);
                          }
                        },
                        child: Text(
                          OlukoLocalizations.get(context, 'editSchedule'),
                          style: OlukoFonts.olukoMediumFont(
                            customColor: OlukoColors.grayColor,
                            customFontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _userCoverAndProfileDetails() {
    return BlocBuilder<GalleryVideoBloc, GalleryVideoState>(
      builder: (context, state) {
        if (state is Success) {
          successState = state;
        }
        return Container(
          width: MediaQuery.of(context).size.width,
          height: _getCoverAndProfileHeight(context),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _coverImageReactiveComponent(),
              _userInformationPanel(),
              _uploadCoverImageReactiveMenu(),
            ],
          ),
        );
      },
    );
  }

  double _getCoverAndProfileHeight(BuildContext context) => ScreenUtils.height(context) / 1.8;

  BlocConsumer<ProfileCoverImageBloc, ProfileCoverImageState> _coverImageReactiveComponent() {
    return BlocConsumer<ProfileCoverImageBloc, ProfileCoverImageState>(
      listener: (context, state) {
        if (state is ProfileCoverImageFailure) {
          AppMessages.showSnackbar(
              context, OlukoExceptionMessage.getExceptionMessage(exceptionType: state.exceptionType, exceptionSource: state.exceptionSource, context: context),
              textColor: Colors.white);
        }
      },
      builder: (context, state) {
        if (state is ProfileCoverImageLoading) {
          return _getUserCoverImageComponent(userToDisplay: _currentUserLatestVersion, isLoadingState: true);
        }
        if (state is ProfileCoverImageDeleted) {
          _currentUserLatestVersion = state.removedCoverImageUser;
          return _getUserCoverImageComponent(userToDisplay: _currentUserLatestVersion);
        }
        if (state is ProfileCoverSuccess) {
          _currentUserLatestVersion = state.userUpdated;
          return _getUserCoverImageComponent(userToDisplay: _currentUserLatestVersion);
        } else {
          return _getUserCoverImageComponent(userToDisplay: _currentUserLatestVersion);
        }
      },
    );
  }

  BlocBuilder<ProfileCoverImageBloc, ProfileCoverImageState> _uploadCoverImageReactiveMenu() {
    return BlocBuilder<ProfileCoverImageBloc, ProfileCoverImageState>(
      buildWhen: (previous, current) => current != previous,
      builder: (context, state) {
        if (state is ProfileCoverImageDeleted) {
          _currentUserLatestVersion = state.removedCoverImageUser;
        }
        if (state is ProfileCoverSuccess) {
          _currentUserLatestVersion = state.userUpdated;
        }
        return coverImageWidget(currentUser: _currentUserLatestVersion);
      },
    );
  }

  UserCoverImageComponent _getUserCoverImageComponent({@required UserResponse userToDisplay, bool isLoadingState = false}) {
    return UserCoverImageComponent(
      currentAuthUser: userToDisplay,
      isHomeImage: true,
      isLoadingState: isLoadingState,
    );
  }

  Positioned coverImageWidget({UserResponse currentUser}) {
    return Positioned(
      top: MediaQuery.of(context).size.height / 5,
      right: 10,
      child: Visibility(
        visible: true,
        child: Container(
          width: 40,
          height: 40,
          child: UploadProfileMediaMenu(galleryState: successState, contentFrom: UploadFrom.profileCoverImage, deleteContent: currentUser.coverImage != null),
        ),
      ),
    );
  }

  Widget _enrolledCoursesAndPeople() {
    return BlocBuilder<UserProgressListBloc, UserProgressListState>(
      builder: (context, userProgressListState) {
        if (userProgressListState is GetUserProgressSuccess) {
          _usersProgress = userProgressListState.usersProgress;
        }
        return Padding(
          padding: EdgeInsets.fromLTRB(20, _hasScheduledCourses ? 10 : 45, 20, 20),
          child: _courseAndPeopleContent(context),
        );
      },
    );
  }

  Widget _courseAndPeopleContent(
    BuildContext context,
  ) {
    return HomeCoursesAndPeople(
      courseEnrollments: _courseEnrollmentList,
      usersProgress: _usersProgress,
      courseIndex: _courseIndex > _courseEnrollmentList.length ? getIndexForLastCourse() : _courseIndex,
      onCourseDeleted: (index) {
        setState(() {
          _courseIndex = 0;
        });
      },
      onCourseChange: (index) {
        setState(() {
          _courseIndex = index > _courseEnrollmentList.length ? getIndexForLastCourse() : index;
        });
        BlocProvider.of<SubscribedCourseUsersBloc>(context)
            .getCourseStatisticsUsers(_courseEnrollmentList[_courseIndex].course.id, _courseEnrollmentList[_courseIndex].createdBy);
      },
      onCourseTap: (index) {
        setState(() {
          _courseIndex = index > _courseEnrollmentList.length ? getIndexForLastCourse() : index;
        });
        _navigateToCourseFirstClassToComplete(context);
      },
    );
  }

  int getIndexForLastCourse() {
    return _courseEnrollmentList.length == 1 ? 0 : _courseEnrollmentList.length;
  }

  void _navigateToCourseFirstClassToComplete(BuildContext context) {
    final Course courseSelected = _courses.where((course) => course.id == _courseEnrollmentList[_courseIndex].course.id).first;
    final EnrollmentClass firstIncompleteClass = getClassToGo(_courseEnrollmentList[_courseIndex].classes);
    final ObjectSubmodel classToGo = _courses[_courses.indexOf(courseSelected)].classes.where((element) => element.id == firstIncompleteClass.id).first;
    final courseIndex = _courses.indexOf(courseSelected);
    final classIndex = _courses[courseIndex].classes.indexOf(classToGo);

    Navigator.pushNamed(
      context,
      routeLabels[RouteEnum.insideClass],
      arguments: {
        'courseEnrollment': _courseEnrollmentList[_courseIndex],
        'classIndex': classIndex,
        'courseIndex': _courses.indexOf(courseSelected),
        'actualCourse': courseSelected
      },
    );
  }

  void callProvidersForInsideClassView(BuildContext context, int classIndex) {
    BlocProvider.of<ClassBloc>(context).get(_courseEnrollmentList[_courseIndex].classes[classIndex].id);
    BlocProvider.of<SegmentBloc>(context).getSegmentsInClass(_courseEnrollmentList[_courseIndex].classes[classIndex]);
    BlocProvider.of<EnrollmentAudioBloc>(context).get(_courseEnrollmentList[_courseIndex].id, _courseEnrollmentList[_courseIndex].classes[classIndex].id);
    BlocProvider.of<SubscribedCourseUsersBloc>(context).get(_courseEnrollmentList[_courseIndex].course.id, _courseEnrollmentList[_courseIndex].userId);
  }

  Widget _friendsRecommended() {
    return BlocBuilder<CourseRecommendedByFriendBloc, CourseRecommendedByFriendState>(
      builder: (context, state) {
        List<Map<String, List<UserResponse>>> _coursesRecommendedMap = [];
        if (state is CourseRecommendedByFriendSuccess) {
          _coursesRecommendedMap = state.recommendedCourses ?? [];
          return FriendsRecommendedCourses(listOfCoursesRecommended: _coursesRecommendedMap, courses: _courses);
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _challengesSection() {
    List<Challenge> _activeChallenges = [];
    return BlocBuilder<ChallengeStreamBloc, ChallengeStreamState>(builder: (context, state) {
      if (state is GetChallengeStreamSuccess) {
        _activeChallenges = state.challenges;
        _listOfChallenges = ProfileHelperFunctions.getActiveChallenges(_activeChallenges, _listOfChallenges);
      }
      if (state is ChallengesForUserRequested) {
        _activeChallenges = state.challenges;
        _listOfChallenges = ProfileHelperFunctions.getActiveChallenges(_activeChallenges, _listOfChallenges);
      }
      if (state is ChallengesDefaultState) {
        _activeChallenges = [];
        _listOfChallenges = [];
        _challengesCardsState = null;
      }
      return BlocBuilder<UpcomingChallengesBloc, UpcomingChallengesState>(
        builder: (context, state) {
          if (state is UniqueChallengesSuccess) {
            _challengesCardsState = state;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: UserChallengeSection(
                userToDisplay: widget.currentUser,
                isCurrentUser: true,
                challengeState: state,
                isForHome: true,
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      );
    });
  }

  Widget _transformationPhotos() {
    return BlocBuilder<TransformationJourneyBloc, TransformationJourneyState>(builder: (context, state) {
      if (state is TransformationJourneySuccess) {
        _transformationJourneyContent = state.contentFromUser;
      }
      return TransformationJourneyComponent(
        transformationJourneyContent: _transformationJourneyContent,
        userToDisplay: widget.currentUser,
      );
    });
  }

  Widget _assessmentVideos() {
    return BlocBuilder<TaskSubmissionBloc, TaskSubmissionState>(builder: (context, state) {
      if (state is GetUserTaskSubmissionSuccess) {
        _assessmentVideosContent = state.taskSubmissions;
      }
      return _assessmentVideosContent.isNotEmpty
          ? AssessmentVideosComponent(
              assessmentVideosContent: _assessmentVideosContent,
              currentUser: widget.currentUser,
            )
          : const SizedBox.shrink();
    });
  }

  SliverAppBar getLogo(AuthSuccess authState) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      stretch: true,
      pinned: true,
      backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
      title: Container(
        key: _logoKey,
        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              OlukoNeumorphism.mvtLogo,
              scale: 5.5,
            ),
            HandWidget(authState: authState, onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget getStoriesBar(BuildContext context) {
    return BlocBuilder<StoryBloc, StoryState>(
      builder: (context, hasStories) {
        _showStories = hasStories is HasStoriesSuccess && hasStories.hasStories && _showLogo;
        return enrolledContent(showStories: _showStories);
      },
    );
  }

  Widget enrolledContent({bool showStories = false}) {
    return SliverToBoxAdapter(
      child: Container(
        key: _storiesKey,
        alignment: Alignment.centerLeft,
        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
        child: showStories
            ? StoriesHeader(
                widget.currentUser.id,
                onTap: () {},
                maxRadius: 30,
                color: OlukoColors.userColor(widget.currentUser.firstName, widget.currentUser.lastName),
              )
            : const SizedBox(),
      ),
    );
  }

  Positioned _userInformationPanel() {
    return Positioned(
      top: OlukoNeumorphism.isNeumorphismDesign ? ScreenUtils.height(context) / 4.5 : ScreenUtils.height(context) / 3.5,
      child: SizedBox(
          width: ScreenUtils.width(context),
          height: ScreenUtils.getAdaptiveHeight(context),
          child: BlocProvider.value(
              value: BlocProvider.of<ProfileBloc>(context),
              child: BlocBuilder<UserStatisticsBloc, UserStatisticsState>(
                builder: (context, state) {
                  if (state is StatisticsSuccess) {
                    _userStats = state.userStats;
                  }
                  return BlocBuilder<GalleryVideoBloc, GalleryVideoState>(
                    builder: (context, state) {
                      if (state is Success) {
                        successState = state;
                      }
                      return BlocConsumer<ProfileAvatarBloc, ProfileAvatarState>(
                        listener: (context, state) {
                          if (state is ProfileAvatarFailure) {
                            AppMessages.showSnackbar(
                              context,
                              OlukoExceptionMessage.getExceptionMessage(
                                  exceptionType: state.exceptionType, exceptionSource: state.exceptionSource, context: context),
                            );
                          }
                        },
                        builder: (context, state) {
                          if (state is ProfileAvatarLoading) {
                            return _getUserInformationComponent(userToDisplay: _currentUserLatestVersion, isLoadingState: true);
                          }
                          if (state is ProfileAvatarDeleted) {
                            _currentUserLatestVersion = state.removedAvatarUser;
                            return _getUserInformationComponent(userToDisplay: _currentUserLatestVersion);
                          }
                          if (state is ProfileAvatarSuccess) {
                            _currentUserLatestVersion = state.updatedUser;
                            return _getUserInformationComponent(userToDisplay: _currentUserLatestVersion);
                          } else {
                            return _getUserInformationComponent(userToDisplay: _currentUserLatestVersion);
                          }
                        },
                      );
                    },
                  );
                },
              ))),
    );
  }

  UserProfileInformation _getUserInformationComponent({@required UserResponse userToDisplay, bool isLoadingState = false}) {
    return UserProfileInformation(
      userToDisplayInformation: userToDisplay,
      actualRoute: ActualProfileRoute.homePage,
      currentUser: userToDisplay,
      userStats: _userStats,
      galleryState: successState,
      isLoadingState: isLoadingState,
    );
  }

  Widget myListOfCoursesAndFriendsRecommended() {
    return BlocBuilder<CourseSubscriptionBloc, CourseSubscriptionState>(builder: (context, courseSubscriptionState) {
      if (courseSubscriptionState is CourseSubscriptionSuccess) {
        _courses = courseSubscriptionState.values;
      }
      if (courseSubscriptionState is CourseDisposeState) {
        _courses = [];
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _myListOfCourses(),
            _friendsRecommended(),
          ],
        ),
      );
    });
  }

  Widget _myListOfCourses() {
    return Container(
      child: BlocBuilder<LikedCoursesBloc, LikedCourseState>(builder: (context, state) {
        Map<CourseCategory, List<Course>> myListOfCourses = {};
        if (state is LikedCoursesDispose) {
          myListOfCourses = null;
        }
        if (state is CourseLikedListSuccess) {
          CourseCategory _myListCategory = state.myLikedCourses;
          if (_myListCategory != null) {
            myListOfCourses = CourseUtils.mapCoursesByCategories(_courses, [_myListCategory]);
          }
          return MyListOfCourses(
            myListOfCourses: myListOfCourses,
            beforeNavigation: (String courseId) =>
                BlocProvider.of<CourseUserInteractionBloc>(context).isCourseLiked(courseId: courseId, userId: _currentUserLatestVersion.id),
          );
        } else {
          return const SizedBox();
        }
      }),
    );
  }
}

EnrollmentClass getClassToGo(List<EnrollmentClass> classes) {
  return classes.firstWhere((element) => element.completedAt == null);
}
