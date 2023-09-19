import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_assignment_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_interaction_timeline_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_mentored_videos_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_recommendations_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_sent_videos_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_timeline_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_user_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_video_message_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_stream_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/helpers/coach_content_for_timeline_panel.dart';
import 'package:oluko_app/helpers/coach_helper_functions.dart';
import 'package:oluko_app/helpers/coach_recommendation_default.dart';
import 'package:oluko_app/helpers/coach_timeline_content.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/coach_timeline_item.dart';
import 'package:oluko_app/models/coach_user.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/services/global_service.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_loading_full_screen.dart';
import 'package:oluko_app/ui/screens/coach/coach_page_view.dart';

class CoachPageBuilders extends StatefulWidget {
  const CoachPageBuilders({this.userId, this.coachId, this.coachAssignment});
  final String userId;
  final String coachId;
  final CoachAssignment coachAssignment;

  @override
  State<CoachPageBuilders> createState() => _CoachPageBuildersState();
}

final GlobalService _globalService = GlobalService();
CoachAssignment coachAssignment;
UserResponse _currentAuthUser;
CoachUser _coachUser;
Annotation _introductionVideo;
const String _defaultIntroductionVideoId = 'introVideo';
List<CoachTimelineItem> _timelineItemsContent = [];
List<CoachRecommendationDefault> _coachRecommendationList = [];
List<CourseEnrollment> _courseEnrollmentList = [];
List<CoachTimelineGroup> _timelinePanelContent = [];
Assessment _assessment;

class _CoachPageBuildersState extends State<CoachPageBuilders> {
  @override
  void initState() {
    _requestCurrentUserData(context, userId: widget.userId, coachId: widget.coachId ?? widget.coachAssignment.coachId);
    super.initState();
    setState(() {
      coachAssignment = widget.coachAssignment;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthSuccess) {
          _currentAuthUser = authState.user;
          return BlocBuilder<CourseEnrollmentListStreamBloc, CourseEnrollmentListStreamState>(
            builder: (context, courseEnrollmentListState) {
              if (courseEnrollmentListState is CourseEnrollmentsByUserStreamSuccess) {
                _courseEnrollmentList = courseEnrollmentListState.courseEnrollments;
              }
              return coachView();
            },
          );
        } else {
          return const LoadingScreen();
        }
      },
    );
  }

  void _requestCurrentUserData(BuildContext context, {String userId, String coachId}) {
    // BlocProvider.of<CoachTimelineItemsBloc>(context).getStream(userId);
    BlocProvider.of<CoachRecommendationsBloc>(context).getStream(userId, coachId);
    BlocProvider.of<CoachUserBloc>(context).get(widget.coachId ?? widget.coachAssignment.coachId);
    BlocProvider.of<CoachMentoredVideosBloc>(context).getStream(userId, coachId);
    BlocProvider.of<CoachVideoMessageBloc>(context).getStream(userId: userId, coachId: coachId);
    BlocProvider.of<AssessmentBloc>(context).getById(_globalService.getAssessmentId);
    BlocProvider.of<TaskSubmissionBloc>(context).getTaskSubmissionByUserId(userId);
    BlocProvider.of<CoachSentVideosBloc>(context).getSentVideosByUserId(userId);
  }

  Widget coachView() => BlocBuilder<CoachUserBloc, CoachUserState>(
        builder: (context, coachUserState) {
          if (coachUserState is CoachUserSuccess) {
            _coachUser = coachUserState.coach;
          }
          return BlocBuilder<CoachAssignmentBloc, CoachAssignmentState>(
            builder: (context, coachAssignmentState) {
              if (coachAssignmentState is CoachAssignmentResponse) {
                coachAssignment = coachAssignmentState.coachAssignmentResponse;
                _setWelcomeVideo();
                _insertWelcomeVideoOnTimeline(context);
              }
              return BlocBuilder<CoachTimelineItemsBloc, CoachTimelineItemsState>(
                builder: (context, timelineItemsState) {
                  _timelineItemsBuild(timelineItemsState);
                  return BlocBuilder<CoachRecommendationsBloc, CoachRecommendationsState>(
                    builder: (context, coachRecommendationState) {
                      coachRecommendationBuild(coachRecommendationState);
                      _timelineContentBuilding(context);
                      BlocProvider.of<CoachTimelineBloc>(context).emitTimelineTabsUpdate(contentForTimelinePanel: _timelinePanelContent);
                      return BlocListener<AssessmentBloc, AssessmentState>(
                        listener: (context, assessmentState) {
                          if (assessmentState is AssessmentSuccess) {
                            _assessment = assessmentState.assessment;
                            BlocProvider.of<TaskBloc>(context).get(_assessment);
                          }
                        },
                        child: CoachPageView(
                          currentAuthUser: _currentAuthUser,
                          coachUser: _coachUser,
                          coachRecommendationList: _coachRecommendationList,
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );

  void _setWelcomeVideo() {
    if (coachAssignment.video?.url != null) {
      _introductionVideo = CoachHelperFunctions.createWelcomeVideoFromCoachAssignment(
        coachAssignment: coachAssignment,
        userId: widget.userId,
        defaultIntroVideoId: _defaultIntroductionVideoId,
      );
    }
  }

  void coachRecommendationBuild(CoachRecommendationsState coachRecommendationState) {
    if (coachRecommendationState is CoachRecommendationsSuccess) {
      _coachRecommendationList = coachRecommendationState.coachRecommendationList;
    }
    if (coachRecommendationState is CoachRecommendationsDispose) {
      _coachRecommendationList = coachRecommendationState.coachRecommendationListDisposeValue;
    }
    if (coachRecommendationState is CoachRecommendationsUpdate) {
      _coachRecommendationList = CoachHelperFunctions.checkRecommendationUpdate(coachRecommendationState.coachRecommendationContent, _coachRecommendationList);
    }
  }

  void _timelineItemsBuild(CoachTimelineItemsState state) {
    if (state is CoachTimelineItemsSuccess) {
      _timelineItemsContent = state.timelineItems;
    }
    if (state is CoachTimelineItemsUpdate) {
      _timelineItemsContent = CoachHelperFunctions.checkTimelineItemsUpdate(state.timelineItems, _timelineItemsContent);
    }
    if (state is CoachTimelineItemsDispose) {
      // _disposeView(state);
    }
  }

  List<CoachTimelineItem> _coachRecommendationsTimelineItems() {
    return CoachTimelineFunctions.coachRecommendationsTimelineItems(_coachRecommendationList);
  }

  void _timelineContentBuilding(BuildContext context) {
    _timelinePanelContent = CoachTimelineFunctions.getTimelineContentForPanel(
      context,
      timelineContentTabs: _timelinePanelContent,
      timelineItemsFromState: _timelineItemsContent,
      allContent: _coachRecommendationsTimelineItems(),
      listOfCoursesId: _courseEnrollmentList.map((enrolledCourse) => enrolledCourse.course.id).toList(),
    );
  }

  void _insertWelcomeVideoOnTimeline(BuildContext context) => _introductionVideo != null && _introductionVideo.video.url != null
      ? _timelineItemsContent = CoachTimelineFunctions.addWelcomeVideoToTimeline(
          context: context,
          timelineItems: _timelineItemsContent,
          welcomeVideo: _introductionVideo,
        )
      : null;
}
