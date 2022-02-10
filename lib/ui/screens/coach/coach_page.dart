import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_assignment_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_interaction_timeline_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_introduction_video_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_mentored_videos_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_recommendations_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_request_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_request_stream_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_review_pending_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_sent_videos_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_timeline_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_user_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_stream_bloc.dart';
// import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_stream_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/coach_content_for_timeline_panel.dart';
import 'package:oluko_app/helpers/coach_helper_functions.dart';
import 'package:oluko_app/helpers/coach_notification_content.dart';
import 'package:oluko_app/helpers/coach_recommendation_default.dart';
import 'package:oluko_app/helpers/coach_segment_content.dart';
import 'package:oluko_app/helpers/coach_segment_info.dart';
import 'package:oluko_app/helpers/coach_timeline_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/list_of_items_to_widget.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/coach_timeline_item.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enums/status_enum.dart';
import 'package:oluko_app/models/recommendation_media.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/user_statistics.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/coach_app_bar.dart';
import 'package:oluko_app/ui/components/coach_carousel_section.dart';
import 'package:oluko_app/ui/components/coach_content_preview_content.dart';
import 'package:oluko_app/ui/components/coach_content_section_card.dart';
import 'package:oluko_app/ui/components/coach_horizontal_carousel_component.dart';
import 'package:oluko_app/ui/components/coach_recommended_content_preview_stack.dart';
import 'package:oluko_app/ui/components/coach_sliding_up_panel.dart';
import 'package:oluko_app/ui/components/coach_user_progress_card.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';

class CoachPage extends StatefulWidget {
  const CoachPage({this.userId, this.coachId, this.coachAssignment});
  final String userId;
  final String coachId;
  final CoachAssignment coachAssignment;

  @override
  _CoachPageState createState() => _CoachPageState();
}

UserResponse _currentAuthUser;
UserResponse _coachUser;
UserStatistics _userStatistics;
Assessment _assessment;
List<CoachRequest> _coachRequestList;
Annotation _introductionVideo;
const String _defaultIdForAllContentTimeline = '0';
const String _defaultIntroductionVideoId = 'introVideo';
const bool hideAssessmentsTab = true;
List<CoachRequest> _coachRequestUpdateList = [];
List<CourseEnrollment> _courseEnrollmentList = [];
List<Annotation> _annotationVideosContent = [];
List<SegmentSubmission> _sentVideosContent = [];
List<InfoForSegments> _segmentsFromCourseEnrollmentClasses = [];
List<CoachSegmentContent> _requiredSegmentList = [];
List<TaskSubmission> _assessmentVideosContent = [];
List<Task> _tasks = [];
List<CoachRecommendationDefault> _coachRecommendations = [];
List<CoachTimelineItem> _timelineItemsContent = [];
List<CoachTimelineItem> _coachRecommendationTimelineContent = [];
List<CoachTimelineItem> _sentVideosTimelineContent = [];
List<CoachTimelineItem> _mentoredVideoTimelineContent = [];
List<CoachTimelineItem> _allContent = [];
List<CoachTimelineGroup> _timelinePanelContent = [];
List<CoachSegmentContent> _allSegmentsForUser = [];
List<SegmentSubmission> segmentsWithReview = [];

class _CoachPageState extends State<CoachPage> {
  @override
  void initState() {
    BlocProvider.of<CoachUserBloc>(context).get(widget.coachAssignment.coachId);
    setState(() {
      _introductionVideo = CoachHelperFunctions.createWelcomeVideoFromCoachAssignment(
        coachAssignment: widget.coachAssignment,
        userId: widget.userId,
        defaultIntroVideoId: _defaultIntroductionVideoId,
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    _introductionVideo = null;
    super.dispose();
  }

  static const paddingTopForElements = EdgeInsets.only(top: OlukoNeumorphism.isNeumorphismDesign ? 20 : 0);

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
                extendBody: true,
                appBar: CoachAppBar(
                  coachUser: _coachUser,
                  onNavigation: () => !widget.coachAssignment.introductionCompleted
                      ? BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation()
                      : () {},
                ),
                body: BlocBuilder<CourseEnrollmentListStreamBloc, CourseEnrollmentListStreamState>(
                  builder: (context, courseEnrollmentState) {
                    if (courseEnrollmentState is CourseEnrollmentsByUserStreamSuccess) {
                      _courseEnrollmentList = courseEnrollmentState.courseEnrollments;
                      _segmentsFromCourseEnrollmentClasses = TransformListOfItemsToWidget.segments(_courseEnrollmentList);
                      _allSegmentsForUser =
                          TransformListOfItemsToWidget.createSegmentContentInforamtion(_segmentsFromCourseEnrollmentClasses);
                    }
                    return BlocConsumer<CoachMentoredVideosBloc, CoachMentoredVideosState>(
                      listenWhen: (CoachMentoredVideosState previous, CoachMentoredVideosState current) =>
                          current is CoachMentoredVideosUpdate,
                      listener: (context, mentoredVideoListenerState) {
                        if (mentoredVideoListenerState is CoachMentoredVideosUpdate) {
                          _annotationVideosContent = CoachHelperFunctions.checkAnnotationUpdate(
                              mentoredVideoListenerState.mentoredVideos, _annotationVideosContent);
                        }
                      },
                      builder: (context, mentoredVideosListenerBuilderState) {
                        if (mentoredVideosListenerBuilderState is CoachMentoredVideosSuccess) {
                          _annotationVideosContent = mentoredVideosListenerBuilderState.mentoredVideos
                              .where((mentoredVideo) => mentoredVideo.video != null)
                              .toList();
                        }
                        if (mentoredVideosListenerBuilderState is CoachMentoredVideosDispose) {
                          _annotationVideosContent = mentoredVideosListenerBuilderState.mentoredVideosDisposeValue;
                          segmentsWithReview.clear();
                        }
                        return BlocBuilder<CoachSentVideosBloc, CoachSentVideosState>(
                          builder: (context, sentVideosState) {
                            if (sentVideosState is CoachSentVideosDispose) {
                              _sentVideosContent = sentVideosState.sentVideosDisposeValue;
                            }
                            if (sentVideosState is CoachSentVideosSuccess) {
                              _sentVideosContent = sentVideosState.sentVideos
                                  .where((sentVideo) => sentVideo.video != null && sentVideo.coachId == _coachUser.id)
                                  .toList();

                              _sentVideosContent.forEach((sentVideo) {
                                segmentsWithReview = CoachHelperFunctions.checkPendingReviewsForSentVideos(
                                    sentVideo: sentVideo,
                                    annotationVideosContent: _annotationVideosContent,
                                    segmentsWithReview: segmentsWithReview);
                              });
                              updateReviewPendingOnCoachAppBar(context);
                            }
                            return BlocConsumer<CoachTimelineItemsBloc, CoachTimelineItemsState>(
                              listenWhen: (CoachTimelineItemsState previous, CoachTimelineItemsState current) =>
                                  current is CoachTimelineItemsUpdate,
                              listener: (context, timelineItemsUpdateListener) {
                                if (timelineItemsUpdateListener is CoachTimelineItemsUpdate) {
                                  _timelineItemsContent = CoachHelperFunctions.checkTimelineItemsUpdate(
                                      timelineItemsUpdateListener.timelineItems, _timelineItemsContent);
                                }
                              },
                              builder: (context, timelineState) {
                                if (timelineState is CoachTimelineItemsDispose) {
                                  _timelineItemsContent = timelineState.timelineItemsDisposeValue;
                                  _allContent.clear();
                                  _coachRecommendationTimelineContent.clear();
                                  _mentoredVideoTimelineContent.clear();
                                  _coachRecommendationTimelineContent.clear();
                                  _timelinePanelContent.clear();
                                  _introductionVideo ??
                                      CoachHelperFunctions.createWelcomeVideoFromCoachAssignment(
                                          coachAssignment: widget.coachAssignment, userId: widget.userId);
                                }
                                if (timelineState is CoachTimelineItemsSuccess) {
                                  _timelineItemsContent = timelineState.timelineItems;
                                }
                                return BlocConsumer<CoachRecommendationsBloc, CoachRecommendationsState>(
                                  listenWhen: (CoachRecommendationsState previous, CoachRecommendationsState current) =>
                                      current is CoachRecommendationsUpdate,
                                  listener: (context, state) {
                                    if (state is CoachRecommendationsDispose) {
                                      _coachRecommendations = state.coachRecommendationListDisposeValue;
                                    }
                                    if (state is CoachRecommendationsUpdate) {
                                      _coachRecommendations = CoachHelperFunctions.checkRecommendationUpdate(
                                          state.coachRecommendationContent, _coachRecommendations);
                                      coachRecommendationsTimelineItems();
                                    }
                                  },
                                  builder: (context, state) {
                                    if (state is CoachRecommendationsSuccess) {
                                      _coachRecommendations = state.coachRecommendationList;

                                      coachRecommendationsTimelineItems();
                                    }
                                    timelineContentBuilding(context);
                                    if (_timelinePanelContent == null) {
                                      return Container(
                                          color: OlukoNeumorphismColors.appBackgroundColor, child: OlukoCircularProgressIndicator());
                                    } else {
                                      BlocProvider.of<CoachTimelineBloc>(context)
                                          .emitTimelineTabsUpdate(contentForTimelinePanel: _timelinePanelContent);
                                      return CoachSlidingUpPanel(
                                          content: coachViewPageContent(context),
                                          timelineItemsContent: _timelinePanelContent,
                                          isIntroductionVideoComplete: widget.coachAssignment.introductionCompleted);
                                    }
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
            color: OlukoNeumorphismColors.appBackgroundColor,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: OlukoCircularProgressIndicator(),
          );
        }
      },
    );
  }

  void updateReviewPendingOnCoachAppBar(BuildContext context) {
    BlocProvider.of<CoachReviewPendingBloc>(context).updateReviewPendingMessage(
      _sentVideosContent != null && segmentsWithReview != null ? _sentVideosContent.length - segmentsWithReview.length : 0,
    );
  }

  void requestCurrentUserData(BuildContext context) {
    BlocProvider.of<AssessmentBloc>(context).getById('emnsmBgZ13UBRqTS26Qd');
    BlocProvider.of<TaskSubmissionBloc>(context).getTaskSubmissionByUserId(_currentAuthUser.id);
    BlocProvider.of<CoachRequestStreamBloc>(context).getStream(_currentAuthUser.id, widget.coachAssignment.coachId);
    BlocProvider.of<CoachRecommendationsBloc>(context).getStream(_currentAuthUser.id, widget.coachAssignment.coachId);
    BlocProvider.of<CoachMentoredVideosBloc>(context).getStream(_currentAuthUser.id, widget.coachAssignment.coachId);
    BlocProvider.of<CoachTimelineItemsBloc>(context).getStream(_currentAuthUser.id);
    BlocProvider.of<UserStatisticsBloc>(context).getUserStatistics(_currentAuthUser.id);
    BlocProvider.of<CoachSentVideosBloc>(context).getSentVideosByUserId(_currentAuthUser.id);
  }

  Widget coachViewPageContent(BuildContext context) {
    return BlocConsumer<CoachRequestStreamBloc, CoachRequestStreamState>(
      listenWhen: (CoachRequestStreamState previous, CoachRequestStreamState current) => current is GetCoachRequestStreamUpdate,
      listener: (context, state) {
        if (state is GetCoachRequestStreamDispose) {
          _coachRequestUpdateList = state.coachRequestDisposeValue;
        }
        if (state is GetCoachRequestStreamUpdate) {
          _coachRequestUpdateList = state.values;
          _coachRequestList = CoachHelperFunctions.checkCoachRequestUpdate(_coachRequestUpdateList, _coachRequestList);
          getCoachRequiredSegments(_allSegmentsForUser);
        }
      },
      builder: (context, state) {
        if (state is CoachRequestStreamSuccess) {
          _coachRequestList = state.values;
          getCoachRequiredSegments(_allSegmentsForUser);
        }
        return BlocBuilder<AssessmentBloc, AssessmentState>(
          builder: (context, state) {
            if (state is AssessmentSuccess) {
              _assessment = state.assessment;
              BlocProvider.of<TaskBloc>(context).get(_assessment);
              final carouselNotificationWidgetList = carouselNotificationWidget(context);
              final coachCarouselSliderSection = CoachCarouselSliderSection(
                contentForCarousel: carouselNotificationWidgetList,
                introductionCompleted: widget.coachAssignment.introductionCompleted,
                introductionVideo: _assessment.video,
                onVideoFinished: () => BlocProvider.of<CoachAssignmentBloc>(context).updateIntroductionVideoState(widget.coachAssignment),
              );

              return Container(
                color: OlukoNeumorphismColors.appBackgroundColor,
                child: ListView(
                  children: [
                    if (carouselNotificationWidgetList.isNotEmpty && widget.coachAssignment.introductionCompleted)
                      Padding(
                        padding: paddingTopForElements,
                        child: coachCarouselSliderSection,
                      )
                    else if (!widget.coachAssignment.introductionCompleted)
                      Padding(
                        padding: paddingTopForElements,
                        child: coachCarouselSliderSection,
                      )
                    else
                      const SizedBox.shrink(),
                    if (widget.coachAssignment.introductionCompleted)
                      carouselNotificationWidgetList.isNotEmpty && widget.coachAssignment.introductionCompleted
                          ? Padding(
                              padding: paddingTopForElements,
                              child: userProgressSection(false),
                            )
                          : Padding(
                              padding: paddingTopForElements,
                              child: userProgressSection(
                                  carouselNotificationWidgetList.isEmpty && widget.coachAssignment.introductionCompleted),
                            )
                    else
                      const SizedBox.shrink(),
                    Padding(
                      padding: paddingTopForElements,
                      child: CoachHorizontalCarousel(contentToDisplay: listOfContentForUser(), isForVideoContent: true),
                    ),
                    Padding(
                      padding: paddingTopForElements,
                      child: carouselToDoSection(context),
                    ),
                    if (hideAssessmentsTab) const SizedBox.shrink() else assessmentSection(context),
                    SizedBox(
                      height: hideAssessmentsTab ? 220 : 200,
                    )
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }

  BlocBuilder<UserStatisticsBloc, UserStatisticsState> userProgressSection(bool startExpanded) {
    return BlocBuilder<UserStatisticsBloc, UserStatisticsState>(builder: (context, state) {
      if (state is StatisticsSuccess) {
        _userStatistics = state.userStats;
      }
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CoachUserProgressCard(
            userStats: _userStatistics,
            startExpanded: startExpanded,
          ));
    });
  }

  List<Widget> listOfContentForUser() {
    const _separatorBox = SizedBox(
      width: 10,
    );
    return [
      CoachHelperFunctions.mentoredVideosSection(
          context: context,
          annotation: _annotationVideosContent,
          introFinished: widget.coachAssignment.introductionCompleted,
          onNavigation: () => BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation()),
      _separatorBox,
      CoachHelperFunctions.sentVideosSection(
          context: context,
          sentVideosContent: _sentVideosContent,
          introductionCompleted: widget.coachAssignment.introductionCompleted,
          onNavigation: () => BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation()),
      _separatorBox,
      recommendedVideosSection(),
      _separatorBox,
      recommendedCoursesSection(),
      _separatorBox,
      recommendedMovementsSection(),
      _separatorBox,
      CoachContentSectionCard(title: OlukoLocalizations.get(context, 'voiceMessages')),
    ];
  }

  SizedBox carouselToDoSection(BuildContext context) => SizedBox(child: toDoSection(context));

  Widget toDoSection(BuildContext context) {
    return toDoContent().isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: OlukoNeumorphism.isNeumorphismDesign ? 20 : 0),
                child: Text(
                  OlukoLocalizations.get(context, 'upcoming'),
                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.white, custoFontWeight: FontWeight.w500),
                ),
              ),
              if (OlukoNeumorphism.isNeumorphismDesign)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      // physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: [Wrap(children: toDoContent())]),
                )
              else
                CoachHorizontalCarousel(contentToDisplay: toDoContent()),
            ],
          )
        : const SizedBox.shrink();
  }

  List<Widget> toDoContent() => TransformListOfItemsToWidget.coachChallengesAndSegments(
      segments: _allSegmentsForUser.where((segment) => segment.isChallenge && segment.completedAt == null).toList());

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
            return OlukoNeumorphism.isNeumorphismDesign
                ? Padding(
                    padding: paddingTopForElements.copyWith(left: 20, right: 20),
                    child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        // physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        children: [
                          Wrap(
                              alignment: WrapAlignment.center,
                              children: TransformListOfItemsToWidget.getAssessmentCards(
                                  tasks: _tasks,
                                  tasksSubmitted: _assessmentVideosContent,
                                  introductionVideoDone: widget.coachAssignment.introductionCompleted))
                        ]),
                  )
                : CoachHorizontalCarousel(
                    contentToDisplay: TransformListOfItemsToWidget.getAssessmentCards(
                        tasks: _tasks,
                        tasksSubmitted: _assessmentVideosContent,
                        introductionVideoDone: widget.coachAssignment.introductionCompleted),
                    isAssessmentContent: true,
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
      contentForNotificationPanel =
          CoachTimelineFunctions.coachRecommendationsForInteraction(coachRecommendations: _coachRecommendations, context: context);
      carouselContent = CoachHelperFunctions.notificationsWidget(
          contentForNotificationPanel, carouselContent, widget.coachId, widget.coachAssignment.userId);
    }

    if (_annotationVideosContent.isNotEmpty) {
      contentForNotificationPanel =
          CoachTimelineFunctions.mentoredVideoForInteraction(annotationContent: _annotationVideosContent, context: context);
      carouselContent = CoachHelperFunctions.notificationsWidget(
          contentForNotificationPanel, carouselContent, widget.coachId, widget.coachAssignment.userId);
    }

    if (_requiredSegmentList.isNotEmpty) {
      contentForNotificationPanel =
          CoachTimelineFunctions.requiredSegmentsForInteraction(requiredSegments: _requiredSegmentList, context: context);
      carouselContent = CoachHelperFunctions.notificationsWidget(
          contentForNotificationPanel, carouselContent, widget.coachId, widget.coachAssignment.userId);
    }
    return carouselContent;
  }

  //when triggers no working
  void buildSentVideosForTimeline() {
    CoachTimelineFunctions.getTimelineVideoContent(
        segmentSubmittedContent: _sentVideosContent,
        sentVideos: _sentVideosTimelineContent,
        courseEnrollmentList: _courseEnrollmentList,
        context: context);
  }

  //when triggers no working
  void buildAnnotationsForTimeline() {
    CoachTimelineFunctions.getTimelineVideoContent(
      annotationContent: _annotationVideosContent,
      mentoredVideos: _mentoredVideoTimelineContent,
      courseEnrollmentList: _courseEnrollmentList,
      context: context,
    );
    addCoachAssignmentVideo();
  }

  void addCoachAssignmentVideo() {
    if (_annotationVideosContent != null && _introductionVideo != null) {
      if (_annotationVideosContent.where((annotation) => annotation.id == _defaultIntroductionVideoId).toList().isEmpty) {
        _annotationVideosContent.insert(0, _introductionVideo);
      }
    }
  }

  void timelineContentBuilding(BuildContext context) {
    mentoredVideosTimeline();
    sentVideosTimeline();

    _timelinePanelContent = CoachTimelineFunctions.buildContentForTimelinePanel(
        timelineItemsContent: _timelineItemsContent,
        enrolledCourseIdList: _courseEnrollmentList.map((enrolledCourse) => enrolledCourse.course.id).toList());

    _timelinePanelContent.forEach((timelinePanelElement) {
      timelinePanelElement.timelineElements.forEach((timelineContentItem) {
        if (_allContent.where((allContentItem) => allContentItem.contentThumbnail == timelineContentItem.contentThumbnail).isEmpty) {
          _allContent.add(timelineContentItem);
        }
      });
    });
    CoachTimelineGroup allTabContent = CoachTimelineGroup(
        courseId: _defaultIdForAllContentTimeline, courseName: OlukoLocalizations.get(context, 'all'), timelineElements: _allContent);

    timelinePanelUpdateTabsAndContent(allTabContent);
  }

  void timelinePanelUpdateTabsAndContent(CoachTimelineGroup allTabContent) {
    if (_timelinePanelContent != null && _timelinePanelContent.isNotEmpty) {
      final indexForAllTab = _timelinePanelContent.indexWhere((panelItem) => panelItem.courseId == allTabContent.courseId);
      if (indexForAllTab != -1) {
        allTabContent.timelineElements.forEach((allTabNewContent) {
          addContentToTimeline(timelineGroup: _timelinePanelContent[indexForAllTab], newContent: allTabNewContent);
        });
        _timelinePanelContent.insert(0, _timelinePanelContent[indexForAllTab]);
        _timelinePanelContent.removeAt(indexForAllTab + 1);
      } else {
        if (_timelinePanelContent[0] != null && _timelinePanelContent[0].courseId == allTabContent.courseId) {
          allTabContent.timelineElements.forEach((allTabNewContent) {
            addContentToTimeline(timelineGroup: _timelinePanelContent[0], newContent: allTabNewContent);
          });
        } else {
          allTabContent.timelineElements.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
          _timelinePanelContent.insert(0, allTabContent);
        }
      }
    } else {
      allTabContent.timelineElements.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
      _timelinePanelContent.insert(0, allTabContent);
    }
  }

  void sentVideosTimeline() {
    _sentVideosTimelineContent.forEach((sentVideo) {
      if (_allContent.where((allContentItem) => allContentItem.contentThumbnail == sentVideo.contentThumbnail).isEmpty) {
        _allContent.add(sentVideo);
      }
      if (_timelineItemsContent.where((timelineItem) => timelineItem.contentThumbnail == sentVideo.contentThumbnail).isEmpty) {
        _timelineItemsContent.add(sentVideo);
      }
    });
    _sentVideosContent.isNotEmpty ? buildSentVideosForTimeline() : null;
  }

  void mentoredVideosTimeline() {
    _mentoredVideoTimelineContent.forEach((mentoredVideo) {
      if (_allContent.where((allContentItem) => allContentItem.contentThumbnail == mentoredVideo.contentThumbnail).isEmpty) {
        _allContent.add(mentoredVideo);
      }
      if (_timelineItemsContent.where((timelineItem) => timelineItem.contentThumbnail == mentoredVideo.contentThumbnail).isEmpty) {
        _timelineItemsContent.add(mentoredVideo);
      }
    });
    buildAnnotationsForTimeline();
  }

  void coachRecommendationsTimelineItems() {
    _coachRecommendations.isNotEmpty
        ? _coachRecommendations.forEach((recommendation) =>
            _coachRecommendationTimelineContent.add(CoachTimelineFunctions.createAnCoachTimelineItem(recommendationItem: recommendation)))
        : null;
    _coachRecommendationTimelineContent.isNotEmpty
        ? _coachRecommendationTimelineContent.forEach((recomendationTimelineItem) {
            if (_allContent.where((contentElement) => contentElement.contentName == recomendationTimelineItem.contentName).isEmpty) {
              _allContent.add(recomendationTimelineItem);
            }
          })
        : null;
  }

  void addContentToTimeline({CoachTimelineGroup timelineGroup, CoachTimelineItem newContent}) {
    if (timelineGroup.timelineElements.where((timelineElement) => timelineElement.contentName == newContent.contentName).isEmpty) {
      timelineGroup.timelineElements.add(newContent);
      timelineGroup.timelineElements.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
    }
  }

  void getCoachRequiredSegments(List<CoachSegmentContent> allSegments) {
    if (_coachRequestList.isNotEmpty) {
      _coachRequestList.forEach((coachRequestItem) {
        allSegments.forEach((segmentItem) {
          if (segmentItem.segmentId == coachRequestItem.segmentId) {
            if (_requiredSegmentList
                .where((requiredSegmentItem) =>
                    requiredSegmentItem.segmentId == coachRequestItem.segmentId && coachRequestItem.status == StatusEnum.requested)
                .isEmpty) {
              segmentItem.coachRequest = coachRequestItem;
              segmentItem.createdAt = coachRequestItem.createdAt;
              if (_requiredSegmentList
                  .where((element) =>
                      element.segmentId == segmentItem.segmentId &&
                      element.coachRequest.courseEnrollmentId == segmentItem.coachRequest.courseEnrollmentId)
                  .isEmpty) {
                _requiredSegmentList.add(segmentItem);
              }
            }
          }
        });
      });
    }
  }

  Widget recommendedVideosSection({bool isForCarousel}) {
    return ((_coachRecommendations != null && _coachRecommendations.isNotEmpty) &&
            _coachRecommendations
                .where((coachRecommendation) =>
                    TimelineContentOption.getTimelineOption(coachRecommendation.contentTypeIndex as int) ==
                    TimelineInteractionType.recommendedVideo)
                .isNotEmpty)
        ? CoachContentPreviewComponent(
            contentFor: CoachContentSection.recomendedVideos,
            titleForSection: OlukoLocalizations.get(context, 'recommendedVideos'),
            recommendedVideoContent: getRecommendedVideosContent(),
            onNavigation: () => !widget.coachAssignment.introductionCompleted
                ? BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation()
                : () {})
        : CoachContentSectionCard(title: OlukoLocalizations.get(context, 'recommendedVideos'));
  }

  Widget recommendedCoursesSection({bool isForCarousel}) {
    Widget widgetToReturn = CoachContentSectionCard(title: OlukoLocalizations.of(context).find('recommendedCourses'));
    List<CoachRecommendationDefault> coursesRecommended = [];
    if (_coachRecommendations != null && _coachRecommendations.isNotEmpty) {
      coursesRecommended =
          CoachHelperFunctions.getRecommendedContentByType(_coachRecommendations, TimelineInteractionType.course, coursesRecommended);
      if (coursesRecommended.isNotEmpty) {
        widgetToReturn = GestureDetector(
            onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.coachRecommendedContentGallery], arguments: {
                  'recommendedContent': coursesRecommended,
                  'titleForAppBar': OlukoLocalizations.of(context).find('recommendedCourses')
                }),
            child: CoachRecommendedContentPreviewStack(
              recommendationsList: coursesRecommended,
              titleForSection: OlukoLocalizations.of(context).find('recommendedCourses'),
            ));
      }
    }
    return widgetToReturn;
  }

  Widget recommendedMovementsSection({bool isForCarousel}) {
    Widget widgetToReturn = CoachContentSectionCard(title: OlukoLocalizations.of(context).find('recommendedMovements'));
    List<CoachRecommendationDefault> movementsRecommended = [];
    if (_coachRecommendations != null && _coachRecommendations.isNotEmpty) {
      movementsRecommended =
          CoachHelperFunctions.getRecommendedContentByType(_coachRecommendations, TimelineInteractionType.movement, movementsRecommended);
      if (movementsRecommended.isNotEmpty) {
        widgetToReturn = GestureDetector(
            onTap: () => Navigator.pushNamed(context, routeLabels[RouteEnum.coachRecommendedContentGallery], arguments: {
                  'recommendedContent': movementsRecommended,
                  'titleForAppBar': OlukoLocalizations.of(context).find('recommendedMovements')
                }),
            child: CoachRecommendedContentPreviewStack(
              recommendationsList: movementsRecommended,
              titleForSection: OlukoLocalizations.of(context).find('recommendedMovements'),
            ));
      }
    }
    return widgetToReturn;
  }

  List<RecommendationMedia> getRecommendedVideosContent() {
    List<RecommendationMedia> recommendationVideos = [];
    for (CoachRecommendationDefault recommendation in _coachRecommendations) {
      if (TimelineContentOption.getTimelineOption(recommendation.contentTypeIndex as int) == TimelineInteractionType.recommendedVideo) {
        recommendationVideos.add(recommendation.recommendationMedia);
      }
    }
    return recommendationVideos;
  }
}
