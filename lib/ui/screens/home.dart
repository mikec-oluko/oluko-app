import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_recommendations_bloc.dart';
import 'package:oluko_app/blocs/course/course_home_bloc.dart';
import 'package:oluko_app/blocs/course/course_subscription_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_stream_bloc.dart';
import 'package:oluko_app/blocs/notification_settings_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/ui/screens/home_content.dart';
import 'package:oluko_app/ui/screens/home_neumorphic_content.dart';
import 'package:oluko_app/ui/screens/home_neumorphic_latest_design.dart';

class Home extends StatefulWidget {
  Home({this.classIndex, this.index, Key key}) : super(key: key);

  final int index;
  final int classIndex;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User _user;
  List<CourseEnrollment> _courseEnrollments;
  List<Course> _courses;
  AuthSuccess _authState;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthSuccess) {
        _authState ??= authState;
        _user = authState.firebaseUser;
        BlocProvider.of<CourseEnrollmentListStreamBloc>(context).getStream(_user.uid);
        BlocProvider.of<NotificationSettingsBloc>(context).get(_user.uid);
        BlocProvider.of<CoachRecommendationsBloc>(context).getStreamFromUser(_user.uid);
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
            BlocProvider.of<CourseHomeBloc>(context).getByCourseEnrollments(_courseEnrollments);
            BlocProvider.of<UserStatisticsBloc>(context).getUserStatistics(_user.uid);
            BlocProvider.of<CourseSubscriptionBloc>(context).getStream();
            return OlukoNeumorphism.isNeumorphismDesign
                // ? HomeNeumorphicContent(_courseEnrollments, _authState, _courses, _user, index: widget.index)
                ? HomeNeumorphicLatestDesign(
                    currentUserId: _user.uid,
                    courseEnrollments: _courseEnrollments,
                  )
                : HomeContent(widget.classIndex, widget.index, _courseEnrollments, _authState, _courses, _user);
          } else {
            return Container(color: OlukoColors.black, child: const Center(child: CircularProgressIndicator()));
          }
        });
      } else {
        return Container(color: OlukoColors.black, child: const Center(child: CircularProgressIndicator()));
      }
    });
  }
}
