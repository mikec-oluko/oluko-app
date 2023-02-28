import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_bloc.dart';
import 'package:oluko_app/blocs/challenge/upcoming_challenge_bloc.dart';
import 'package:oluko_app/blocs/course/course_friend_recommended_bloc.dart';
import 'package:oluko_app/blocs/course/course_liked_courses_bloc.dart';
import 'package:oluko_app/blocs/course/course_subscription_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_stream_bloc.dart';
import 'package:oluko_app/blocs/profile/profile_bloc.dart';
import 'package:oluko_app/blocs/story_bloc.dart';
import 'package:oluko_app/blocs/subscribed_course_users_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/blocs/user_progress_list_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/list_of_items_to_widget.dart';
import 'package:oluko_app/helpers/profile_helper_functions.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_category.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/dto/user_progress.dart';
import 'package:oluko_app/models/submodels/enrollment_class.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/transformation_journey_uploads.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/user_statistics.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/carousel_section.dart';
import 'package:oluko_app/ui/components/hand_widget.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/stories_header.dart';
import 'package:oluko_app/ui/components/user_profile_information.dart';
import 'package:oluko_app/ui/newDesignComponents/courses_and_people_section_for_home.dart';
import 'package:oluko_app/ui/newDesignComponents/friends_recommended_courses.dart';
import 'package:oluko_app/ui/newDesignComponents/my_list_of_courses_home.dart';
import 'package:oluko_app/ui/newDesignComponents/user_assessments_videos_component.dart';
import 'package:oluko_app/ui/newDesignComponents/user_challenges_component.dart';
import 'package:oluko_app/ui/newDesignComponents/user_cover_image_component.dart';
import 'package:oluko_app/ui/newDesignComponents/user_transformation_journey_section.dart';
import 'package:oluko_app/utils/course_utils.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class HomeNeumorphicLatestDesign extends StatefulWidget {
  final UserResponse currentUser;
  final List<CourseEnrollment> courseEnrollments;
  final AuthSuccess authState;

  const HomeNeumorphicLatestDesign({this.currentUser, this.courseEnrollments, this.authState}) : super();

  @override
  State<HomeNeumorphicLatestDesign> createState() => _HomeNeumorphicLatestDesignState();
}

class _HomeNeumorphicLatestDesignState extends State<HomeNeumorphicLatestDesign> {
  final bool showLogo = true;
  bool showStories = false;
  UserStatistics userStats;
  Map<String, UserProgress> _usersProgress = {};
  int courseIndex = 0;
  List<Course> _courses;
  List<CourseEnrollment> _courseEnrollmentList = [];
  List<ChallengeNavigation> _listOfChallenges = [];
  UpcomingChallengesState _challengesCardsState;
  List<TransformationJourneyUpload> _transformationJourneyContent = [];
  List<TaskSubmission> _assessmentVideosContent = [];

  @override
  void initState() {
    BlocProvider.of<CourseRecommendedByFriendBloc>(context).getStreamOfCoursesRecommendedByFriends(userId: widget.currentUser.id);
    BlocProvider.of<StoryBloc>(context).hasStories(widget.currentUser.id);
    if (widget.courseEnrollments.isNotEmpty) {
      BlocProvider.of<SubscribedCourseUsersBloc>(context).getEnrolled(widget.courseEnrollments[0].course.id, widget.courseEnrollments[0].createdBy);
    }
    BlocProvider.of<LikedCoursesBloc>(context).getStreamOfLikedCourses(userId: widget.currentUser.id);
    BlocProvider.of<TransformationJourneyBloc>(context).getContentByUserId(widget.currentUser.id);
    BlocProvider.of<TaskSubmissionBloc>(context).getTaskSubmissionByUserId(widget.currentUser.id);

    setState(() {
      _courseEnrollmentList = widget.courseEnrollments;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseEnrollmentListStreamBloc, CourseEnrollmentListStreamState>(
      // buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is CourseEnrollmentsByUserStreamSuccess) {
          _courseEnrollmentList = state.courseEnrollments;
          _listOfChallenges = ProfileHelperFunctions.getChallenges(_courseEnrollmentList);
          BlocProvider.of<UpcomingChallengesBloc>(context)
              .getUniqueChallengeCards(userId: widget.currentUser.id, listOfChallenges: _listOfChallenges, userRequested: widget.currentUser);
        }
        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return _stories(widget.authState);
            },
            body: Container(
              color: OlukoNeumorphismColors.appBackgroundColor,
              constraints: const BoxConstraints.expand(),
              child: ListView(
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                clipBehavior: Clip.none,
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  _userCoverAndProfileDetails(),
                  _enrolledCoursesAndPeople(),
                  myListOfCoursesAndFriendsRecommended(),
                  _challengesSection(),
                  _transformationPhotos(),
                  _assessmentVideos(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _stories(AuthSuccess authState) {
    return [
      if (showLogo) getLogo(authState) else const SliverToBoxAdapter(),
      if (GlobalConfiguration().getValue('showStories') == 'true') getStoriesBar(context),
    ];
  }

  Widget _userCoverAndProfileDetails() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: ScreenUtils.smallScreen(context) ? ScreenUtils.height(context) / 1.8 : ScreenUtils.height(context) / 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          UserCoverImageComponent(
            currentAuthUser: widget.currentUser,
            isHomeImage: true,
          ),
          userInformationPanel(),
        ],
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
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 50),
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
      courseIndex: courseIndex > _courseEnrollmentList.length ? _courseEnrollmentList.length : courseIndex,
      onCourseDeleted: (index) {
        setState(() {
          courseIndex = index - 1 < 0
              ? 0
              : index - 1 < _courseEnrollmentList.length
                  ? _courseEnrollmentList.length
                  : index - 1;
        });
      },
      onCourseChange: (index) {
        setState(() {
          courseIndex = index > _courseEnrollmentList.length ? _courseEnrollmentList.length : index;
        });
        BlocProvider.of<SubscribedCourseUsersBloc>(context)
            .getEnrolled(_courseEnrollmentList[courseIndex].course.id, _courseEnrollmentList[courseIndex].createdBy);
      },
      onCourseTap: (index) {
        setState(() {
          courseIndex = index > _courseEnrollmentList.length ? _courseEnrollmentList.length : index;
        });
        Course courseSelected = _courses.where((course) => course.id == _courseEnrollmentList[courseIndex].course.id).first;
        EnrollmentClass firstIncompletedClass = getClassToGo(_courseEnrollmentList[courseIndex].classes);
        ObjectSubmodel classToGo = _courses[_courses.indexOf(courseSelected)].classes.where((element) => element.id == firstIncompletedClass.id).first;
        Navigator.pushNamed(
          context,
          routeLabels[RouteEnum.insideClass],
          arguments: {
            'courseEnrollment': _courseEnrollmentList[courseIndex],
            'classIndex': _courses[_courses.indexOf(courseSelected)].classes.indexOf(classToGo),
            'courseIndex': _courses.indexOf(courseSelected),
            'actualCourse': courseSelected
          },
        );
      },
    );
  }

  Widget _friendsRecommended() {
    return BlocBuilder<CourseRecommendedByFriendBloc, CourseRecommendedByFriendState>(
      builder: (context, state) {
        List<Map<String, List<UserResponse>>> _coursesRecommendedMap = [];
        if (state is CourseRecommendedByFriendSuccess) {
          _coursesRecommendedMap = state.recommendedCourses;
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
                defaultNavigation: false,
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

  // TODO: MOVE AS WIDGET
  SliverAppBar getLogo(AuthSuccess authState) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      stretch: true,
      pinned: true,
      backgroundColor: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
      title: Container(
        color: OlukoNeumorphismColors.olukoNeumorphicBackgroundDark,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              OlukoNeumorphism.mvtLogo,
              scale: 4,
            ),
            HandWidget(authState: authState, onTap: () {}),
          ],
        ),
      ),
    );
  }

// TODO: MOVE AS WIDGET
  Widget getStoriesBar(BuildContext context) {
    return BlocBuilder<StoryBloc, StoryState>(
      builder: (context, hasStories) {
        showStories = hasStories is HasStoriesSuccess && hasStories.hasStories && showLogo;
        return enrolledContent(showStories);
      },
    );
  }

// TODO: MOVE AS WIDGET
  Widget enrolledContent(bool showStories) {
    return SliverToBoxAdapter(
      child: Container(
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

  Positioned userInformationPanel() {
    return Positioned(
      top: OlukoNeumorphism.isNeumorphismDesign ? ScreenUtils.height(context) / 4.5 : ScreenUtils.height(context) / 3.5,
      child: SizedBox(
          width: ScreenUtils.width(context),
          height: ScreenUtils.getAdaptativeHeight(context),
          child: BlocProvider.value(
              value: BlocProvider.of<ProfileBloc>(context),
              child: BlocBuilder<UserStatisticsBloc, UserStatisticsState>(
                builder: (context, state) {
                  if (state is StatisticsSuccess) {
                    userStats = state.userStats;
                  }
                  return UserProfileInformation(
                    userToDisplayInformation: widget.currentUser,
                    actualRoute: ActualProfileRoute.homePage,
                    currentUser: widget.currentUser,
                    userStats: userStats,
                  );
                },
              ))),
    );
  }

  Widget myListOfCoursesAndFriendsRecommended() {
    return BlocBuilder<CourseSubscriptionBloc, CourseSubscriptionState>(builder: (context, courseSubscriptionState) {
      if (courseSubscriptionState is CourseSubscriptionSuccess) {
        _courses = courseSubscriptionState.values;
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
        if (state is CourseLikedListSuccess) {
          CourseCategory _myListCategory = state.myLikedCourses;
          if (_myListCategory != null) {
            myListOfCourses = CourseUtils.mapCoursesByCategories(_courses, [_myListCategory]);
          }
          return MyListOfCourses(myListOfCourses: myListOfCourses);
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
