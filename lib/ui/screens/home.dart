import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_bloc.dart';
import 'package:oluko_app/blocs/challenge/upcoming_challenge_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_recommendations_bloc.dart';
import 'package:oluko_app/blocs/course/course_friend_recommended_bloc.dart';
import 'package:oluko_app/blocs/course/course_home_bloc.dart';
import 'package:oluko_app/blocs/course/course_liked_courses_bloc.dart';
import 'package:oluko_app/blocs/course/course_subscription_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_stream_bloc.dart';
import 'package:oluko_app/blocs/gallery_video_bloc.dart';
import 'package:oluko_app/blocs/notification_settings_bloc.dart';
import 'package:oluko_app/blocs/story_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/blocs/transformation_journey_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/helpers/profile_helper_functions.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/services/global_service.dart';
import 'package:oluko_app/ui/screens/home_content.dart';
import 'package:oluko_app/ui/screens/home_neumorphic_content.dart';
import 'package:oluko_app/ui/screens/home_neumorphic_latest_design.dart';
import 'package:oluko_app/ui/screens/welcome_video_first_time_login.dart';

class Home extends StatefulWidget {
  Home({this.classIndex, this.index, Key key}) : super(key: key);
  final int index;
  final int classIndex;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  UserResponse _user;
  List<CourseEnrollment> _courseEnrollments;
  List<Course> _courses;
  AuthSuccess _authState;
  GlobalService _globalService = GlobalService();
  List<ChallengeNavigation> _listOfChallenges = [];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        _authState ??= authState;
        _user = authState.user;
        BlocProvider.of<StoryBloc>(context).hasStories(_user.id);
        BlocProvider.of<CourseRecommendedByFriendBloc>(context).getStreamOfCoursesRecommendedByFriends(userId: _user.id);
        BlocProvider.of<LikedCoursesBloc>(context).getStreamOfLikedCourses(userId: _user.id);
        BlocProvider.of<CourseEnrollmentListStreamBloc>(context).getStream(_user.id);
        BlocProvider.of<ChallengeStreamBloc>(context).getStream(_user.id);
        BlocProvider.of<NotificationSettingsBloc>(context).get(_user.id);
        BlocProvider.of<CoachRecommendationsBloc>(context).getStreamFromUser(_user.id);
        BlocProvider.of<GalleryVideoBloc>(context).getFirstImageFromGalley();
        return BlocBuilder<CourseEnrollmentListStreamBloc, CourseEnrollmentListStreamState>(buildWhen: (previous, current) {
          if (previous is CourseEnrollmentsByUserStreamSuccess && current is CourseEnrollmentsByUserStreamSuccess) {
            if (previous.courseEnrollments.length == current.courseEnrollments.length) {
              return false;
            }
          }
          return true;
        }, builder: (context, courseEnrollmentListStreamState) {
          if (courseEnrollmentListStreamState is CourseEnrollmentsByUserStreamSuccess) {
            _courseEnrollments = courseEnrollmentListStreamState.courseEnrollments /*.where((courseEnroll) => courseEnroll.isUnenrolled != true).toList()*/;
            _listOfChallenges = ProfileHelperFunctions.getChallenges(_courseEnrollments);
            BlocProvider.of<UpcomingChallengesBloc>(context)
                .getUniqueChallengeCards(userId: _user.id, listOfChallenges: _listOfChallenges, userRequested: _user);
            BlocProvider.of<CourseHomeBloc>(context).getByCourseEnrollments(_courseEnrollments);
            BlocProvider.of<UserStatisticsBloc>(context).getUserStatistics(_user.id);
            BlocProvider.of<CourseSubscriptionBloc>(context).getStream();
            BlocProvider.of<TransformationJourneyBloc>(context).getContentByUserId(_user.id);
            BlocProvider.of<TaskSubmissionBloc>(context).getTaskSubmissionByUserId(_user.id);
            return OlukoNeumorphism.isNeumorphismDesign
                // ? HomeNeumorphicContent(_courseEnrollments, _authState, _courses, _user, index: widget.index)
                ?
                // _globalService.showWelcomeVideoInHome
                //     ? const WelcomeVideoFirstTimeLogin()
                //     :
                HomeNeumorphicLatestDesign(
                    currentUser: authState.user,
                    authState: authState,
                    courseEnrollments: _courseEnrollments,
                  )
                : HomeContent(widget.classIndex, widget.index, _courseEnrollments, _authState, _courses, _user);
          } else {
            return Container(color: OlukoNeumorphismColors.appBackgroundColor, child: const Center(child: CircularProgressIndicator()));
          }
        });
      } else {
        return Container(color: OlukoNeumorphismColors.appBackgroundColor, child: const Center(child: CircularProgressIndicator()));
      }
    });
  }
}
