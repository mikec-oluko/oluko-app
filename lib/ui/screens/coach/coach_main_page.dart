import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_assignment_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_interaction_timeline_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_mentored_videos_bloc.dart';
import 'package:oluko_app/blocs/introduction_media_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_assignment_status.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/services/global_service.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/screens/assessments/assessment_videos.dart';
import 'package:oluko_app/ui/screens/coach/coach_page_builders.dart';
import 'coach_no_assigned_timer_page.dart';
import 'coach_no_coach_page.dart';
import 'coach_page.dart';

class CoachMainPage extends StatefulWidget {
  const CoachMainPage();

  @override
  _CoachMainPageState createState() => _CoachMainPageState();
}

class _CoachMainPageState extends State<CoachMainPage> {
  UserResponse _currentUser;
  CoachAssignment _coachAssignment;
  GlobalService _globalService = GlobalService();

  @override
  void initState() {
    BlocProvider.of<AuthBloc>(context).checkCurrentUser();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _globalService.comesFromCoach = true;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          _currentUser = state.user;
          BlocProvider.of<CoachAssignmentBloc>(context).getCoachAssignmentStatusStream(_currentUser.id);
          BlocProvider.of<IntroductionMediaBloc>(context).getVideo(IntroductionMediaTypeEnum.coachTabCorePlan);
          BlocProvider.of<CoachTimelineItemsBloc>(context).getStream(_currentUser.id);
        }
        return _currentUser.currentPlan >= 1
            ? BlocBuilder<CoachAssignmentBloc, CoachAssignmentState>(
                builder: (context, state) {
                  if (state is CoachAssignmentResponseDispose) {
                    _coachAssignment = state.coachAssignmentDisposeValue;
                  }
                  if (state is CoachAssignmentResponse) {
                    _coachAssignment = state.coachAssignmentResponse;
                    if (_coachAssignment != null && (_coachAssignment.coachId != null && _coachAssignment.coachReference != null)) {
                      if (_coachAssignment.userId == _currentUser.id) {
                        if (CoachAssignmentStatus.getCoachAssignmentStatus(_coachAssignment.coachAssignmentStatus as int) ==
                            CoachAssignmentStatusEnum.approved) {
                          BlocProvider.of<IntroductionMediaBloc>(context)
                              .getVideo(IntroductionMediaTypeEnum.coachTabWelcomeVideo, useStreamVideo: GlobalService().appUseVideoHls);
                          return CoachPageBuilders(userId: _currentUser.id, coachId: _coachAssignment.coachId, coachAssignment: _coachAssignment);
                          // return CoachPage(userId: _currentUser.id, coachId: _coachAssignment.coachId, coachAssignment: _coachAssignment);
                        } else {
                          return CoachAssignedCountDown(
                            currentUser: _currentUser,
                            coachAssignment: _coachAssignment,
                          );
                        }
                      } else {
                        return Container(color: OlukoColors.black, child: OlukoCircularProgressIndicator());
                      }
                    } else {
                      return _currentUser.assessmentsCompletedAt != null && _currentUser.assessmentsCompletedAt is Timestamp
                          ? _coachAssignment == null
                              ? CoachAssignedCountDown(
                                  currentUser: _currentUser,
                                  coachAssignment: _coachAssignment,
                                )
                              : _noCoachPage()
                          : AssessmentVideos(isFirstTime: false, isForCoachPage: true, assessmentsDone: _currentUser.assessmentsCompletedAt != null);
                    }
                  } else {
                    return Container(color: OlukoColors.black, child: OlukoCircularProgressIndicator());
                  }
                },
              )
            : _noCoachPage();
      },
    );
  }

  BlocBuilder<IntroductionMediaBloc, IntroductionMediaState> _noCoachPage() {
    return BlocBuilder<IntroductionMediaBloc, IntroductionMediaState>(
      builder: (context, state) {
        if (state is Success && state.mediaURL != null) {
          return NoCoachPage(
            introductionVideo: state.mediaURL,
          );
        } else {
          return SizedBox();
        }
      },
    );
  }
}
