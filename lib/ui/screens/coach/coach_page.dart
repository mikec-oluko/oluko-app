import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_assignment_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_profile_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_sent_videos_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_bloc.dart';
import 'package:oluko_app/blocs/movement_submission_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_segment_content.dart';
import 'package:oluko_app/helpers/coach_segment_info.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/list_of_items_to_widget.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/movement_submission.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/user_statistics.dart';
import 'package:oluko_app/ui/components/coach_app_bar.dart';
import 'package:oluko_app/ui/components/coach_carousel_section.dart';
import 'package:oluko_app/ui/components/coach_content_preview_content.dart';
import 'package:oluko_app/ui/components/coach_content_section_card.dart';
import 'package:oluko_app/ui/components/coach_horizontal_carousel_component.dart';
import 'package:oluko_app/ui/components/coach_sliding_up_panel.dart';
import 'package:oluko_app/ui/components/coach_user_progress_card.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/components/video_player.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CoachPage extends StatefulWidget {
  const CoachPage({this.coachId, this.coachAssignment});
  final String coachId;
  final CoachAssignment coachAssignment;

  @override
  _CoachPageState createState() => _CoachPageState();
}

List<Challenge> _activeChallenges = [];
List<CourseEnrollment> _courseEnrollmentList = [];
UserResponse _currentAuthUser;
UserResponse _coachUser;
List<InfoForSegments> _toDoSegments = [];
List<CoachSegmentContent> actualSegmentsToDisplay = [];
List<TaskSubmission> _assessmentVideosContent = [];
List<SegmentSubmission> _sentVideosContent = [];
List<MovementSubmission> _movementSubmission = [];
UserStatistics _userStats;
Assessment _assessment;
List<Task> _tasks = [];

class _CoachPageState extends State<CoachPage> {
  @override
  void initState() {
    // TODO: implement initState
    BlocProvider.of<CoachProfileBloc>(context).getCoachProfile(widget.coachId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          _currentAuthUser = state.user;
          requestCurrentUserData(context);
          return BlocBuilder<CoachProfileBloc, CoachProfileState>(
            builder: (context, state) {
              if (state is CoachProfileDataSuccess) {
                _coachUser = state.coachProfile;
              }

              return Scaffold(
                appBar: CoachAppBar(
                  coachUser: _coachUser,
                ),
                body: BlocBuilder<CourseEnrollmentListBloc, CourseEnrollmentListState>(
                  builder: (context, state) {
                    if (state is CourseEnrollmentsByUserSuccess) {
                      _courseEnrollmentList = state.courseEnrollments;
                    }
                    return CoachSlidingUpPanel(
                      content: coachViewPageContent(context),
                      courseEnrollmentList: _courseEnrollmentList,
                    );
                  },
                ),
              );
            },
          );
        } else {
          return Container(
            color: OlukoColors.black,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: OlukoCircularProgressIndicator(),
          );
        }
      },
    );
  }

  void requestCurrentUserData(BuildContext context) {
    BlocProvider.of<UserStatisticsBloc>(context).getUserStatistics(_currentAuthUser.id);

    BlocProvider.of<CourseEnrollmentListBloc>(context).getCourseEnrollmentsByUserId(_currentAuthUser.id);

    BlocProvider.of<CourseEnrollmentBloc>(context).getChallengesForUser(_currentAuthUser.id);

    BlocProvider.of<TaskSubmissionBloc>(context).getTaskSubmissionByUserId(_currentAuthUser.id);

    BlocProvider.of<CoachSentVideosBloc>(context).getSentVideosByUserId(_currentAuthUser.id);

    BlocProvider.of<AssessmentBloc>(context).getById('emnsmBgZ13UBRqTS26Qd');
  }

  Widget coachViewPageContent(BuildContext context) {
    return BlocBuilder<AssessmentBloc, AssessmentState>(
      builder: (context, state) {
        if (state is AssessmentSuccess) {
          _assessment = state.assessment;
          BlocProvider.of<TaskBloc>(context).get(_assessment);
          return ListView(
            children: [
              CoachCarouselSliderSection(
                contentForCarousel: listOfContentForUser(carousel: true),
                introductionCompleted: widget.coachAssignment.introductionCompleted,
                introductionVideo: _assessment.video,
                onVideoFinished: () =>
                    BlocProvider.of<CoachAssignmentBloc>(context).updateIntroductionVideoState(widget.coachAssignment),
              ),
              userProgressSection(),
              CoachHorizontalCarousel(contentToDisplay: listOfContentForUser(carousel: false), isForVideoContent: true),
              carouselToDoSection(context),
              assessmentSection(context),
              const SizedBox(
                height: 200,
              )
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  BlocBuilder<UserStatisticsBloc, UserStatisticsState> userProgressSection() {
    return BlocBuilder<UserStatisticsBloc, UserStatisticsState>(builder: (context, state) {
      if (state is StatisticsSuccess) {
        _userStats = state.userStats;
      }
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CoachUserProgressCard(
            userStats: _userStats,
          ));
    });
  }

  SizedBox carouselToDoSection(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            OlukoLocalizations.of(context).find('toDo'),
            style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
          ),
          toDoSection(context),
        ],
      ),
    );
  }

  Widget toDoSection(BuildContext context) {
    return BlocBuilder<CourseEnrollmentListBloc, CourseEnrollmentListState>(
      builder: (context, state) {
        if (state is CourseEnrollmentsByUserSuccess) {
          _courseEnrollmentList = state.courseEnrollments;
          _toDoSegments = TransformListOfItemsToWidget.segments(_courseEnrollmentList);
          actualSegmentsToDisplay = TransformListOfItemsToWidget.createSegmentContentInforamtion(_toDoSegments);
        }
        return BlocBuilder<CourseEnrollmentBloc, CourseEnrollmentState>(
          builder: (context, state) {
            if (state is GetCourseEnrollmentChallenge) {
              if (_activeChallenges.isNotEmpty) {
                _activeChallenges = state.challenges;
              }
            }
            return CoachHorizontalCarousel(contentToDisplay: toDoContent());
          },
        );
      },
    );
  }

  List<Widget> toDoContent() => TransformListOfItemsToWidget.coachChallengesAndSegments(
      challenges: _activeChallenges, segments: actualSegmentsToDisplay);

  Widget assessmentSection(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskSuccess) {
          _tasks = state.values;
        }
        return CoachHorizontalCarousel(
          contentToDisplay:
              TransformListOfItemsToWidget.getAssessmentCards(tasks: _tasks, tasksSubmitted: _assessmentVideosContent),
          isAssessmentContent: true,
        );
      },
    );
  }

  List<Widget> listOfContentForUser({bool carousel}) {
    if (carousel) {
      return [
        mentoredVideos(isForCarousel: carousel),
        sentVideos(isForCarousel: carousel),
        CoachContentSectionCard(
            title: OlukoLocalizations.of(context).find('recomendedVideos'), isForCarousel: carousel),
        CoachContentSectionCard(title: OlukoLocalizations.of(context).find('voiceMessages'), isForCarousel: carousel),
      ];
    }
    const separatorBox = SizedBox(
      width: 5,
    );
    return [
      mentoredVideos(isForCarousel: carousel),
      separatorBox,
      sentVideos(isForCarousel: carousel),
      separatorBox,
      CoachContentSectionCard(title: OlukoLocalizations.of(context).find('recomendedVideos'), isForCarousel: carousel),
      separatorBox,
      CoachContentSectionCard(title: OlukoLocalizations.of(context).find('voiceMessages'), isForCarousel: carousel),
    ];
  }

  BlocBuilder<CoachSentVideosBloc, CoachSentVideosState> sentVideos({bool isForCarousel}) {
    return BlocBuilder<CoachSentVideosBloc, CoachSentVideosState>(
      builder: (context, state) {
        if (state is CoachSentVideosSuccess) {
          _sentVideosContent = state.sentVideos;
          _sentVideosContent.forEach((segmentSubmission) {
            BlocProvider.of<MovementSubmissionBloc>(context).get(segmentSubmission);
          });
        }
        return BlocBuilder<MovementSubmissionBloc, MovementSubmissionState>(builder: (context, state) {
          if (state is GetMovementSubmissionSuccess) {
            if (_movementSubmission.isEmpty) {
              _movementSubmission.addAll(state.movementSubmissions);
              // _movementSubmission = state.movementSubmissions;
            }
          }

          return _movementSubmission.length != null && _movementSubmission.isNotEmpty
              ? CoachContentPreviewContent(
                  contentFor: CoachContentSection.sentVideos,
                  titleForSection: OlukoLocalizations.of(context).find('sentVideos'),
                  videoContent: _movementSubmission,
                  isForCarousel: isForCarousel)
              : CoachContentSectionCard(
                  title: OlukoLocalizations.of(context).find('sentVideos'),
                  isForCarousel: isForCarousel,
                  needTitle: false);
        });
      },
    );
  }

  BlocBuilder<TaskSubmissionBloc, TaskSubmissionState> mentoredVideos({bool isForCarousel}) {
    return BlocBuilder<TaskSubmissionBloc, TaskSubmissionState>(builder: (context, state) {
      if (state is GetUserTaskSubmissionSuccess) {
        // _assessmentVideosContent = [];
        _assessmentVideosContent = state.taskSubmissions;
      }
      return
          //  _assessmentVideosContent.length != null && _assessmentVideosContent.isNotEmpty
          //     ? CoachContentPreviewContent(
          //         contentFor: CoachContentSection.mentoredVideos,
          //         titleForSection: OlukoLocalizations.of(context).find('mentoredVideos'),
          //         videoContent: _movementSubmission,
          //         isForCarousel: isForCarousel)
          //     :
          CoachContentSectionCard(
              title: OlukoLocalizations.of(context).find('mentoredVideos'),
              isForCarousel: isForCarousel,
              needTitle: false);
    });
  }
}
