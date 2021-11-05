import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/challenge_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_assignment_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_interaction_timeline_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_mentored_videos_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_recommendations_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_request_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_sent_videos_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_user_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_content_for_timeline_panel.dart';
import 'package:oluko_app/helpers/coach_notification_content.dart';
import 'package:oluko_app/helpers/coach_recommendation_default.dart';
import 'package:oluko_app/helpers/coach_segment_content.dart';
import 'package:oluko_app/helpers/coach_segment_info.dart';
import 'package:oluko_app/helpers/coach_timeline_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/list_of_items_to_widget.dart';
import 'package:oluko_app/models/annotations.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/coach_timeline_item.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enums/status_enum.dart';
import 'package:oluko_app/models/recommendation.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/user_statistics.dart';
import 'package:oluko_app/ui/components/coach_app_bar.dart';
import 'package:oluko_app/ui/components/coach_carousel_section.dart';
import 'package:oluko_app/ui/components/coach_content_preview_content.dart';
import 'package:oluko_app/ui/components/coach_content_section_card.dart';
import 'package:oluko_app/ui/components/coach_horizontal_carousel_component.dart';
import 'package:oluko_app/ui/components/coach_notification_panel_content_card.dart';
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

UserResponse _currentAuthUser;
UserResponse _coachUser;
UserStatistics _userStats;
Assessment _assessment;
List<CoachRequest> _coachRequestList;
Annotation _introductionVideo;
List<CourseEnrollment> _courseEnrollmentList = [];
List<Challenge> _activeChallenges = [];
List<Annotation> _annotationVideosContent = [];
List<Annotation> _annotationUpdateListofContent = [];
List<SegmentSubmission> _sentVideosContent = [];
List<InfoForSegments> _toDoSegments = [];
List<CoachSegmentContent> _requiredSegments = [];
List<TaskSubmission> _assessmentVideosContent = [];
List<Task> _tasks = [];
List<CoachRecommendationDefault> _coachRecommendations = [];
List<CoachTimelineItem> _timelineItemsContent = [];
List<CoachTimelineItem> _coachRecommendationTimelineContent = [];
List<CoachTimelineItem> _sentVideosTimelineContent = [];
List<CoachTimelineItem> _mentoredVideoTimelineContent = [];
List<CoachTimelineItem> _allContent = [];
List<CoachTimelineGroup> _timelinePanelContent = [];
List<CoachSegmentContent> allSegments = [];

String _defaultIdForAllContentTimeline = '0';
const String _defaultIntroductionVideoId = 'introVideo';

class _CoachPageState extends State<CoachPage> {
  @override
  void initState() {
    BlocProvider.of<CoachUserBloc>(context).get(widget.coachAssignment.coachId);
    if (widget.coachAssignment.introductionVideo != null) {
      setState(() {
        _introductionVideo = Annotation(
            createdAt: Timestamp.now(),
            id: _defaultIntroductionVideoId,
            favorite: false,
            video: Video(url: widget.coachAssignment.introductionVideo, aspectRatio: 0.60),
            videoHLS: widget.coachAssignment.introductionVideo);
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    BlocProvider.of<CoachMentoredVideosBloc>(context).dispose();
    setState(() {
      clearContent([
        _requiredSegments,
        _timelinePanelContent,
        _mentoredVideoTimelineContent,
        _allContent,
        _sentVideosTimelineContent,
        _timelineItemsContent,
        _sentVideosContent,
        _assessmentVideosContent,
        _annotationVideosContent
      ]);
    });
    super.dispose();
  }

  clearContent(List<List<dynamic>> listToClear) {
    listToClear.forEach((list) => list.clear());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          _currentAuthUser = state.user;
          requestCurrentUserData(context);
          return BlocBuilder<CoachUserBloc, CoachUserState>(
            builder: (context, state) {
              if (state is CoachUserSuccess) {
                _coachUser = state.coach;
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
                    return BlocConsumer<CoachMentoredVideosBloc, CoachMentoredVideosState>(
                      listenWhen: (CoachMentoredVideosState previous, CoachMentoredVideosState current) =>
                          current is CoachMentoredVideosUpdate,
                      listener: (context, state) {
                        if (state is CoachMentoredVideosUpdate) {
                          _annotationUpdateListofContent = state.mentoredVideos;
                          checkAnnotationUpdate(_annotationUpdateListofContent);
                        }
                      },
                      builder: (context, state) {
                        if (state is CoachMentoredVideosSuccess) {
                          _annotationVideosContent =
                              state.mentoredVideos.where((mentoredVideo) => mentoredVideo.video != null).toList();
                        }
                        return BlocBuilder<CoachSentVideosBloc, CoachSentVideosState>(
                          builder: (context, state) {
                            if (state is CoachSentVideosSuccess) {
                              _sentVideosContent =
                                  state.sentVideos.where((sentVideo) => sentVideo.video != null).toList();
                            }
                            return BlocBuilder<CoachTimelineItemsBloc, CoachTimelineItemsState>(
                              builder: (context, timelineState) {
                                return BlocBuilder<CoachRecommendationsBloc, CoachRecommendationsState>(
                                  builder: (context, state) {
                                    if (state is CoachRecommendationsSuccess) {
                                      _coachRecommendations = state.coachRecommendationList;
                                    }
                                    if (timelineState is CoachTimelineItemsSuccess) {
                                      _timelineItemsContent = timelineState.timelineItems;
                                      timelineContentBuilding(context);
                                    }
                                    return _timelinePanelContent.isEmpty
                                        ? Container(color: OlukoColors.black, child: OlukoCircularProgressIndicator())
                                        : CoachSlidingUpPanel(
                                            content: coachViewPageContent(context),
                                            timelineItemsContent: _timelinePanelContent,
                                          );
                                  },
                                );
                              },
                            );
                          },
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

  void buildSentVideosForTimeline() {
    CoachTimelineFunctions.getTimelineVideoContent(
        segmentSubmittedContent: _sentVideosContent, sentVideos: _sentVideosTimelineContent, context: context);
  }

  void buildAnnotationsForTimeline() {
    CoachTimelineFunctions.getTimelineVideoContent(
        annotationContent: _annotationVideosContent, mentoredVideos: _mentoredVideoTimelineContent, context: context);
    addCoachAssignmentVideo();
  }

  void checkAnnotationUpdate(List<Annotation> annotationUpdateListofContent) {
    annotationUpdateListofContent.forEach((updatedOrNewAnnotation) {
      List<Annotation> repeatedAnnotation =
          _annotationVideosContent.where((element) => element.id == updatedOrNewAnnotation.id).toList();
      if (repeatedAnnotation.isEmpty) {
        _annotationVideosContent.add(updatedOrNewAnnotation);
      } else {
        if (repeatedAnnotation.first != updatedOrNewAnnotation) {
          _annotationVideosContent[_annotationVideosContent
              .indexWhere((element) => element.id == updatedOrNewAnnotation.id)] = updatedOrNewAnnotation;
        }
      }
    });
  }

  void addCoachAssignmentVideo() {
    if (_annotationVideosContent != null && _introductionVideo != null) {
      if (_annotationVideosContent
          .where((annotation) => annotation.id == _defaultIntroductionVideoId)
          .toList()
          .isEmpty) {
        _annotationVideosContent.insert(0, _introductionVideo);
      }
    }
  }

  void timelineContentBuilding(BuildContext context) {
    buildSentVideosForTimeline();
    buildAnnotationsForTimeline();

    //TODO: CHECK CONTENT BEFORE ADD
    _coachRecommendations.forEach((recommendation) => _coachRecommendationTimelineContent
        .add(CoachTimelineFunctions.createAnCoachTimelineItem(recommendationItem: recommendation)));
    _allContent.addAll(_coachRecommendationTimelineContent);

    _timelinePanelContent = CoachTimelineFunctions.buildContentForTimelinePanel(_timelineItemsContent);
    _timelinePanelContent.forEach((element) {
      _allContent.addAll(element.timelineElements);
    });

    CoachTimelineGroup allTabContent = CoachTimelineGroup(
        courseId: _defaultIdForAllContentTimeline,
        courseName: OlukoLocalizations.get(context, 'all'),
        timelineElements: _allContent);

    _allContent.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
    _timelinePanelContent.insert(0, allTabContent);
  }

  void requestCurrentUserData(BuildContext context) {
    BlocProvider.of<CoachTimelineItemsBloc>(context).getTimelineItemsForUser(_currentAuthUser.id);

    BlocProvider.of<UserStatisticsBloc>(context).getUserStatistics(_currentAuthUser.id);

    BlocProvider.of<CourseEnrollmentListBloc>(context).getCourseEnrollmentsByUserId(_currentAuthUser.id);

    BlocProvider.of<ChallengeBloc>(context).get(_currentAuthUser.id);

    BlocProvider.of<CoachRequestBloc>(context).get(_currentAuthUser.id);

    // BlocProvider.of<CoachMentoredVideosBloc>(context).getMentoredVideosByUserId(
    //     _currentAuthUser.id, widget.coachAssignment.coachId);

    BlocProvider.of<CoachMentoredVideosBloc>(context).getStream(_currentAuthUser.id, widget.coachAssignment.coachId);

    BlocProvider.of<CoachSentVideosBloc>(context).getSentVideosByUserId(_currentAuthUser.id);

    BlocProvider.of<AssessmentBloc>(context).getById('emnsmBgZ13UBRqTS26Qd');

    BlocProvider.of<TaskSubmissionBloc>(context).getTaskSubmissionByUserId(_currentAuthUser.id);

    BlocProvider.of<CoachRecommendationsBloc>(context)
        .getCoachRecommendations(_currentAuthUser.id, widget.coachAssignment.coachId);
  }

  Widget coachViewPageContent(BuildContext context) {
    return BlocBuilder<CourseEnrollmentListBloc, CourseEnrollmentListState>(
      builder: (context, state) {
        if (state is CourseEnrollmentsByUserSuccess) {
          _courseEnrollmentList = state.courseEnrollments;
          _toDoSegments = TransformListOfItemsToWidget.segments(_courseEnrollmentList);
          allSegments = TransformListOfItemsToWidget.createSegmentContentInforamtion(_toDoSegments);
        }
        return BlocBuilder<ChallengeBloc, ChallengeState>(
          builder: (context, state) {
            if (state is GetChallengeSuccess) {
              if (_activeChallenges.isNotEmpty) {
                _activeChallenges = state.challenges;
              }
            }
            return BlocBuilder<CoachRequestBloc, CoachRequestState>(
              builder: (context, state) {
                if (state is CoachRequestSuccess) {
                  _coachRequestList = state.values;
                  getRequiredSegments(allSegments);
                }
                return BlocBuilder<AssessmentBloc, AssessmentState>(
                  builder: (context, state) {
                    if (state is AssessmentSuccess) {
                      _assessment = state.assessment;
                      BlocProvider.of<TaskBloc>(context).get(_assessment);
                      final carouselNotificationWidgetList = carouselNotificationWidget(context);
                      return ListView(
                        children: [
                          if (carouselNotificationWidgetList.isNotEmpty && widget.coachAssignment.introductionCompleted)
                            CoachCarouselSliderSection(
                              contentForCarousel: carouselNotificationWidgetList,
                              introductionCompleted: widget.coachAssignment.introductionCompleted,
                              introductionVideo: _assessment.video,
                              onVideoFinished: () => BlocProvider.of<CoachAssignmentBloc>(context)
                                  .updateIntroductionVideoState(widget.coachAssignment),
                            )
                          else if (!widget.coachAssignment.introductionCompleted)
                            CoachCarouselSliderSection(
                              contentForCarousel: carouselNotificationWidgetList,
                              introductionCompleted: widget.coachAssignment.introductionCompleted,
                              introductionVideo: _assessment.video,
                              onVideoFinished: () => BlocProvider.of<CoachAssignmentBloc>(context)
                                  .updateIntroductionVideoState(widget.coachAssignment),
                            )
                          else
                            SizedBox.shrink(),
                          userProgressSection(carouselNotificationWidgetList.isEmpty),
                          CoachHorizontalCarousel(contentToDisplay: listOfContentForUser(), isForVideoContent: true),
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
              },
            );
          },
        );
      },
    );
  }

  List<Widget> carouselNotificationWidget(BuildContext context) {
    List<Widget> carouselContent = [];
    List<CoachNotificationContent> contentForNotificationPanel = [];

    if (_coachRecommendations.isNotEmpty) {
      contentForNotificationPanel = CoachTimelineFunctions.coachRecommendationsForInteraction(
          coachRecommendations: _coachRecommendations, context: context);
      notificationsWidget(contentForNotificationPanel, carouselContent);
    }

    if (_annotationVideosContent.isNotEmpty) {
      contentForNotificationPanel = CoachTimelineFunctions.mentoredVideoForInteraction(
          annotationContent: _annotationVideosContent, context: context);
      notificationsWidget(contentForNotificationPanel, carouselContent);
    }

    if (_requiredSegments.isNotEmpty) {
      contentForNotificationPanel =
          CoachTimelineFunctions.requiredSegmentsForInteraction(requiredSegments: _requiredSegments, context: context);
      notificationsWidget(contentForNotificationPanel, carouselContent);
    }
    return carouselContent;
  }

  void notificationsWidget(List<CoachNotificationContent> contentForNotificationPanel, List<Widget> carouselContent) {
    contentForNotificationPanel.forEach((notificationContent) {
      carouselContent.add(CoachNotificationPanelContentCard(content: notificationContent));
    });
  }

  BlocBuilder<UserStatisticsBloc, UserStatisticsState> userProgressSection(bool startExpanded) {
    return BlocBuilder<UserStatisticsBloc, UserStatisticsState>(builder: (context, state) {
      if (state is StatisticsSuccess) {
        _userStats = state.userStats;
      }
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CoachUserProgressCard(
            userStats: _userStats,
            startExpanded: startExpanded,
          ));
    });
  }

  SizedBox carouselToDoSection(BuildContext context) {
    return SizedBox(
      child: toDoSection(context),
    );
  }

  Widget toDoSection(BuildContext context) {
    return toDoContent().isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                OlukoLocalizations.get(context, 'toDo'),
                style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
              ),
              CoachHorizontalCarousel(contentToDisplay: toDoContent()),
            ],
          )
        : SizedBox.shrink();
  }

  void getRequiredSegments(List<CoachSegmentContent> allSegments) {
    if (_coachRequestList.isNotEmpty) {
      _coachRequestList.forEach((coachRequestItem) {
        allSegments.forEach((segmentItem) {
          if (segmentItem.segmentId == coachRequestItem.segmentId) {
            if (_requiredSegments
                .where((requiredSegmentItem) =>
                    requiredSegmentItem.segmentId == coachRequestItem.segmentId &&
                    coachRequestItem.status == StatusEnum.requested)
                .isEmpty) {
              segmentItem.coachRequest = coachRequestItem;
              segmentItem.createdAt = coachRequestItem.createdAt;
              if (_requiredSegments
                  .where((element) =>
                      element.segmentId == segmentItem.segmentId &&
                      element.coachRequest.courseEnrollmentId == segmentItem.coachRequest.courseEnrollmentId)
                  .isEmpty) {
                _requiredSegments.add(segmentItem);
              }
            }
          }
        });
      });
    }
  }

  List<Widget> toDoContent() => TransformListOfItemsToWidget.coachChallengesAndSegments(
      challenges: _activeChallenges, segments: _requiredSegments);

  Widget assessmentSection(BuildContext context) {
    return BlocBuilder<TaskSubmissionBloc, TaskSubmissionState>(
      builder: (context, state) {
        if (state is GetUserTaskSubmissionSuccess) {
          _assessmentVideosContent = state.taskSubmissions;
        }
        return BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskSuccess) {
              _tasks = state.values;
            }
            return CoachHorizontalCarousel(
              contentToDisplay: TransformListOfItemsToWidget.getAssessmentCards(
                  tasks: _tasks, tasksSubmitted: _assessmentVideosContent),
              isAssessmentContent: true,
            );
          },
        );
      },
    );
  }

  List<Widget> listOfContentForUser() {
    const separatorBox = SizedBox(
      width: 5,
    );
    return [
      mentoredVideos(),
      separatorBox,
      sentVideos(),
      separatorBox,
      CoachContentSectionCard(title: OlukoLocalizations.get(context, 'recomendedVideos')),
      separatorBox,
      CoachContentSectionCard(title: OlukoLocalizations.get(context, 'voiceMessages')),
    ];
  }

  Widget sentVideos() {
    return _sentVideosContent.length != null && _sentVideosContent.isNotEmpty
        ? CoachContentPreviewContent(
            contentFor: CoachContentSection.sentVideos,
            titleForSection: OlukoLocalizations.get(context, 'sentVideos'),
            segmentSubmissionContent: _sentVideosContent)
        : CoachContentSectionCard(
            title: OlukoLocalizations.get(context, 'sentVideos'),
          );
  }

  Widget mentoredVideos({bool isForCarousel}) {
    return _annotationVideosContent != null && _annotationVideosContent.isNotEmpty
        ? CoachContentPreviewContent(
            contentFor: CoachContentSection.mentoredVideos,
            titleForSection: OlukoLocalizations.get(context, 'mentoredVideos'),
            coachAnnotationContent: _annotationVideosContent)
        : CoachContentSectionCard(title: OlukoLocalizations.get(context, 'mentoredVideos'));
  }
}
