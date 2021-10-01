import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_assignment_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_interaction_timeline_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_mentored_videos_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_profile_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_sent_videos_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_content_for_timeline_panel.dart';
import 'package:oluko_app/helpers/coach_segment_content.dart';
import 'package:oluko_app/helpers/coach_segment_info.dart';
import 'package:oluko_app/helpers/coach_timeline_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/list_of_items_to_widget.dart';
import 'package:oluko_app/models/annotations.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/coach_timeline_item.dart';
import 'package:oluko_app/models/course_enrollment.dart';
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
import 'package:oluko_app/utils/oluko_localizations.dart';

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
List<Annotation> _annotationVideosContent = [];
List<CoachTimelineItem> _timelineItemsContent = [];
UserStatistics _userStats;
Assessment _assessment;
List<Task> _tasks = [];

class _CoachPageState extends State<CoachPage> {
  @override
  void initState() {
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
                    return BlocBuilder<CoachTimelineItemsBloc, CoachTimelineItemsState>(
                      builder: (context, state) {
                        List<CoachTimelineGroup> timelinePanelContent = [];
                        List<String> listOfCourseId = [];
                        List<CoachTimelineItem> contentSameCourse = [];
                        List<CoachTimelineItem> contentEachCourse = [];

                        if (state is CoachTimelineItemsSuccess) {
                          _timelineItemsContent = state.timelineItems;
                          timelinePanelContent = buildContentForTimelinePanel(listOfCourseId, contentSameCourse,
                              contentEachCourse, timelinePanelContent, _timelineItemsContent);
                        }
                        return timelinePanelContent.isEmpty
                            ? Container(color: OlukoColors.black, child: OlukoCircularProgressIndicator())
                            : CoachSlidingUpPanel(
                                content: coachViewPageContent(context),
                                timelineItemsContent: timelinePanelContent,
                              );
                      },
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
    BlocProvider.of<CoachTimelineItemsBloc>(context).getTimelineItemsForUser(_currentAuthUser.id);

    BlocProvider.of<UserStatisticsBloc>(context).getUserStatistics(_currentAuthUser.id);

    BlocProvider.of<CourseEnrollmentListBloc>(context).getCourseEnrollmentsByUserId(_currentAuthUser.id);

    BlocProvider.of<CourseEnrollmentBloc>(context).getChallengesForUser(_currentAuthUser.id);

    BlocProvider.of<CoachMentoredVideosBloc>(context).getMentoredVideosByUserId(_currentAuthUser.id);

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
      child: toDoSection(context),
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  OlukoLocalizations.of(context).find('toDo'),
                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                ),
                CoachHorizontalCarousel(contentToDisplay: toDoContent()),
              ],
            );
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
    return BlocBuilder<CoachSentVideosBloc, CoachSentVideosState>(builder: (context, state) {
      if (state is CoachSentVideosSuccess) {
        _sentVideosContent = state.sentVideos;
      }

      return _sentVideosContent.length != null && _sentVideosContent.isNotEmpty
          ? CoachContentPreviewContent(
              contentFor: CoachContentSection.sentVideos,
              titleForSection: OlukoLocalizations.get(context, 'sentVideos'),
              segmentSubmissionContent: _sentVideosContent,
              isForCarousel: isForCarousel)
          : CoachContentSectionCard(
              title: OlukoLocalizations.get(context, 'sentVideos'),
              isForCarousel: isForCarousel,
            );
    });
  }

  BlocBuilder<CoachMentoredVideosBloc, CoachMentoredVideosState> mentoredVideos({bool isForCarousel}) {
    return BlocBuilder<CoachMentoredVideosBloc, CoachMentoredVideosState>(builder: (context, state) {
      if (state is CoachMentoredVideosSuccess) {
        _annotationVideosContent = state.mentoredVideos;
      }
      return _annotationVideosContent != null && _annotationVideosContent.isNotEmpty
          ? CoachContentPreviewContent(
              contentFor: CoachContentSection.mentoredVideos,
              titleForSection: OlukoLocalizations.get(context, 'mentoredVideos'),
              coachAnnotationContent: _annotationVideosContent,
              isForCarousel: isForCarousel)
          : CoachContentSectionCard(
              title: OlukoLocalizations.get(context, 'mentoredVideos'),
              isForCarousel: isForCarousel,
            );
    });
  }
}
