import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:oluko_app/blocs/coach/coach_review_pending_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_sent_videos_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_timeline_bloc.dart';
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
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/coach_timeline_item.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enums/status_enum.dart';
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
List<CoachRequest> _coachRequestUpdateList = [];
Annotation _introductionVideo;
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
String _defaultIdForAllContentTimeline = '0';
const String _defaultIntroductionVideoId = 'introVideo';
bool hideAssessmentsTab = true;

class _CoachPageState extends State<CoachPage> {
  @override
  void initState() {
    BlocProvider.of<CoachUserBloc>(context).get(widget.coachAssignment.coachId);
    setState(() {
      createWelcomeVideo();
    });
    super.initState();
  }

  void createWelcomeVideo() {
    if (widget.coachAssignment.videoHLS != null
        ? true
        : (widget.coachAssignment.video?.url != null ? true : widget.coachAssignment.introductionVideo != null)) {
      // setState(() {
      widget.coachAssignment.userId == widget.userId
          ? _introductionVideo = Annotation(
              coachId: widget.coachAssignment.coachId,
              userId: widget.coachAssignment.userId,
              id: _defaultIntroductionVideoId,
              favorite: widget.coachAssignment.isFavorite,
              createdAt: widget.coachAssignment.createdAt ?? Timestamp.now(),
              video: Video(
                  url: widget.coachAssignment.videoHLS ??
                      (widget.coachAssignment.video != null ? widget.coachAssignment.video.url : widget.coachAssignment.introductionVideo),
                  aspectRatio: widget.coachAssignment.video != null ? widget.coachAssignment.video.aspectRatio ?? 0.60 : 0.60),
              videoHLS: widget.coachAssignment.videoHLS ??
                  (widget.coachAssignment.video != null ? widget.coachAssignment.video.url : widget.coachAssignment.introductionVideo),
            )
          : null;
      // });
    }
  }

  @override
  void dispose() {
    _introductionVideo = null;
    super.dispose();
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
                  onNavigation: () => !widget.coachAssignment.introductionCompleted
                      ? BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation()
                      : () {},
                ),
                body: BlocBuilder<CourseEnrollmentListBloc, CourseEnrollmentListState>(
                  builder: (context, state) {
                    if (state is CourseEnrollmentsByUserSuccess) {
                      _courseEnrollmentList = state.courseEnrollments.where((courseEnroll) => courseEnroll.isUnenrolled != true).toList();
                    }
                    return BlocConsumer<CoachMentoredVideosBloc, CoachMentoredVideosState>(
                      listenWhen: (CoachMentoredVideosState previous, CoachMentoredVideosState current) =>
                          current is CoachMentoredVideosUpdate,
                      listener: (context, state) {
                        if (state is CoachMentoredVideosUpdate) {
                          checkAnnotationUpdate(state.mentoredVideos);
                        }
                      },
                      builder: (context, state) {
                        if (state is CoachMentoredVideosSuccess) {
                          if (_annotationVideosContent.isEmpty) {
                            _annotationVideosContent = state.mentoredVideos.where((mentoredVideo) => mentoredVideo.video != null).toList();
                          } else {
                            state.mentoredVideos.forEach((mentoredVideo) {
                              final sameElement =
                                  _annotationVideosContent.where((contentElement) => contentElement.id == mentoredVideo.id).toList();
                              if (sameElement.isNotEmpty) {
                                if (_annotationVideosContent[_annotationVideosContent.indexOf(sameElement.first)] != mentoredVideo) {
                                  _annotationVideosContent[_annotationVideosContent.indexOf(sameElement.first)] = mentoredVideo;
                                }
                              } else {
                                _annotationVideosContent.add(mentoredVideo);
                              }
                            });
                          }
                        }
                        if (state is CoachMentoredVideosDefault) {
                          _annotationVideosContent = state.defaultContent;
                          segmentsWithReview.clear();
                        }
                        return BlocBuilder<CoachSentVideosBloc, CoachSentVideosState>(
                          builder: (context, state) {
                            if (state is CoachSentVideosDefault) {
                              _sentVideosContent = state.sentVideos;
                            }
                            if (state is CoachSentVideosSuccess) {
                              _sentVideosContent = state.sentVideos
                                  .where((sentVideo) => sentVideo.video != null && sentVideo.coachId == _coachUser.id)
                                  .toList();

                              _sentVideosContent.forEach((sentVideo) {
                                checkPendingReviewsForSentVideos(sentVideo);
                              });
                              BlocProvider.of<CoachReviewPendingBloc>(context).updateReviewPendingMessage(
                                  _sentVideosContent != null && segmentsWithReview != null
                                      ? _sentVideosContent.length - segmentsWithReview.length
                                      : 0);
                            }
                            return BlocConsumer<CoachTimelineItemsBloc, CoachTimelineItemsState>(
                              listenWhen: (CoachTimelineItemsState previous, CoachTimelineItemsState current) =>
                                  current is CoachTimelineItemsUpdate,
                              listener: (context, state) {
                                if (state is CoachTimelineItemsUpdate) {
                                  checkTimelineItemsUpdate(state.timelineItems);
                                }
                              },
                              builder: (context, timelineState) {
                                if (timelineState is CoachTimelineItemsDefault) {
                                  _timelineItemsContent = timelineState.timelineItemsDefault;
                                  _allContent.clear();
                                  _coachRecommendationTimelineContent.clear();
                                  _mentoredVideoTimelineContent.clear();
                                  _coachRecommendationTimelineContent.clear();
                                  _timelinePanelContent.clear();
                                  _introductionVideo == null ? createWelcomeVideo() : _introductionVideo = null;
                                }
                                if (timelineState is CoachTimelineItemsSuccess) {
                                  _timelineItemsContent = timelineState.timelineItems;
                                }
                                return BlocConsumer<CoachRecommendationsBloc, CoachRecommendationsState>(
                                  listenWhen: (CoachRecommendationsState previous, CoachRecommendationsState current) =>
                                      current is CoachRecommendationsUpdate,
                                  listener: (context, state) {
                                    if (state is CoachRecommendationsDefaultValue) {
                                      _coachRecommendations = state.coachRecommendationListDefaultValue;
                                    }
                                    if (state is CoachRecommendationsUpdate) {
                                      checkRecommendationUpdate(state.coachRecommendationContent);
                                    }
                                  },
                                  builder: (context, state) {
                                    if (state is CoachRecommendationsSuccess) {
                                      _coachRecommendations = state.coachRecommendationList;
                                    }
                                    timelineContentBuilding(context);
                                    if (_timelinePanelContent == null) {
                                      return Container(color: OlukoColors.black, child: OlukoCircularProgressIndicator());
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
            color: OlukoColors.black,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: OlukoCircularProgressIndicator(),
          );
        }
      },
    );
  }

  void checkPendingReviewsForSentVideos(SegmentSubmission sentVideo) {
    _annotationVideosContent.forEach((annotation) {
      if (annotation.segmentSubmissionId == sentVideo.id) {
        if (segmentsWithReview
            .where((reviewSegment) => reviewSegment.id == sentVideo.segmentId && reviewSegment.coachId == sentVideo.coachId)
            .toList()
            .isEmpty) {
          if (segmentsWithReview.where((reviewedSegment) => reviewedSegment.id == sentVideo.id).toList().isEmpty) {
            segmentsWithReview.add(sentVideo);
          }
        }
      }
    });
  }

  void requestCurrentUserData(BuildContext context) {
    BlocProvider.of<AssessmentBloc>(context).getById('emnsmBgZ13UBRqTS26Qd');
    BlocProvider.of<TaskSubmissionBloc>(context).getTaskSubmissionByUserId(_currentAuthUser.id);
    BlocProvider.of<CoachRequestBloc>(context).getStream(_currentAuthUser.id, widget.coachAssignment.coachId);
    BlocProvider.of<CoachRecommendationsBloc>(context).getStream(_currentAuthUser.id, widget.coachAssignment.coachId);
    BlocProvider.of<CoachMentoredVideosBloc>(context).getStream(_currentAuthUser.id, widget.coachAssignment.coachId);
    BlocProvider.of<CoachTimelineItemsBloc>(context).getStream(_currentAuthUser.id);
    BlocProvider.of<CourseEnrollmentListBloc>(context).getCourseEnrollmentsByUserId(_currentAuthUser.id);
    BlocProvider.of<UserStatisticsBloc>(context).getUserStatistics(_currentAuthUser.id);
    BlocProvider.of<CoachSentVideosBloc>(context).getSentVideosByUserId(_currentAuthUser.id);
  }

  Widget coachViewPageContent(BuildContext context) {
    return BlocBuilder<CourseEnrollmentListBloc, CourseEnrollmentListState>(
      builder: (context, state) {
        if (state is CourseEnrollmentsByUserSuccess) {
          _courseEnrollmentList = state.courseEnrollments.where((courseEnroll) => courseEnroll.isUnenrolled != true).toList();
          _segmentsFromCourseEnrollmentClasses = TransformListOfItemsToWidget.segments(_courseEnrollmentList);
          _allSegmentsForUser = TransformListOfItemsToWidget.createSegmentContentInforamtion(_segmentsFromCourseEnrollmentClasses);
        }
        return BlocConsumer<CoachRequestBloc, CoachRequestState>(
          listenWhen: (CoachRequestState previous, CoachRequestState current) => current is GetCoachRequestUpdate,
          listener: (context, state) {
            if (state is GetCoachRequestDefault) {
              _coachRequestUpdateList = state.coachRequestDefaultValue;
            }
            if (state is GetCoachRequestUpdate) {
              _coachRequestUpdateList = state.values;
              checkCoachRequestUpdate(_coachRequestUpdateList);
              getCoachRequiredSegments(_allSegmentsForUser);
            }
          },
          builder: (context, state) {
            if (state is CoachRequestSuccess) {
              _coachRequestList = state.values;
              getCoachRequiredSegments(_allSegmentsForUser);
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
                          onVideoFinished: () =>
                              BlocProvider.of<CoachAssignmentBloc>(context).updateIntroductionVideoState(widget.coachAssignment),
                        )
                      else if (!widget.coachAssignment.introductionCompleted)
                        CoachCarouselSliderSection(
                          contentForCarousel: carouselNotificationWidgetList,
                          introductionCompleted: widget.coachAssignment.introductionCompleted,
                          introductionVideo: _assessment.video,
                          onVideoFinished: () =>
                              BlocProvider.of<CoachAssignmentBloc>(context).updateIntroductionVideoState(widget.coachAssignment),
                        )
                      else
                        const SizedBox.shrink(),
                      if (widget.coachAssignment.introductionCompleted)
                        carouselNotificationWidgetList.isNotEmpty && widget.coachAssignment.introductionCompleted
                            ? userProgressSection(false)
                            : userProgressSection(carouselNotificationWidgetList.isEmpty && widget.coachAssignment.introductionCompleted)
                      else
                        const SizedBox.shrink(),
                      CoachHorizontalCarousel(contentToDisplay: listOfContentForUser(), isForVideoContent: true),
                      carouselToDoSection(context),
                      if (hideAssessmentsTab) const SizedBox.shrink() else assessmentSection(context),
                      SizedBox(
                        height: hideAssessmentsTab ? 220 : 200,
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
    const separatorBox = SizedBox(
      width: 10,
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

  SizedBox carouselToDoSection(BuildContext context) => SizedBox(child: toDoSection(context));

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
        : const SizedBox.shrink();
  }

  List<Widget> toDoContent() => TransformListOfItemsToWidget.coachChallengesAndSegments(
      segments: _requiredSegmentList.where((segment) => segment.isChallenge).toList());

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
      notificationsWidget(contentForNotificationPanel, carouselContent);
    }

    if (_annotationVideosContent.isNotEmpty) {
      contentForNotificationPanel =
          CoachTimelineFunctions.mentoredVideoForInteraction(annotationContent: _annotationVideosContent, context: context);
      notificationsWidget(contentForNotificationPanel, carouselContent);
    }

    if (_requiredSegmentList.isNotEmpty) {
      contentForNotificationPanel =
          CoachTimelineFunctions.requiredSegmentsForInteraction(requiredSegments: _requiredSegmentList, context: context);
      notificationsWidget(contentForNotificationPanel, carouselContent);
    }
    return carouselContent;
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

  void addCoachAssignmentVideo() {
    if (_annotationVideosContent != null && _introductionVideo != null) {
      if (_annotationVideosContent.where((annotation) => annotation.id == _defaultIntroductionVideoId).toList().isEmpty) {
        _annotationVideosContent.insert(0, _introductionVideo);
      }
    }
  }

  void timelineContentBuilding(BuildContext context) {
    buildSentVideosForTimeline();
    buildAnnotationsForTimeline();

    _coachRecommendations.forEach((recommendation) =>
        _coachRecommendationTimelineContent.add(CoachTimelineFunctions.createAnCoachTimelineItem(recommendationItem: recommendation)));
    _coachRecommendationTimelineContent.forEach((recomendationTimelineItem) {
      if (_allContent.where((contentElement) => contentElement.contentThumbnail == recomendationTimelineItem.contentThumbnail).isEmpty) {
        _allContent.add(recomendationTimelineItem);
      }
    });

    _timelinePanelContent = CoachTimelineFunctions.buildContentForTimelinePanel(_timelineItemsContent);
    _timelinePanelContent.forEach((timelinePanelElement) {
      timelinePanelElement.timelineElements.forEach((timelineContentItem) {
        if (_allContent.where((allContentItem) => allContentItem.contentName == timelineContentItem.contentName).isEmpty) {
          _allContent.add(timelineContentItem);
        }
      });
    });
    _mentoredVideoTimelineContent.forEach((mentoredVideo) {
      if (_allContent.where((allContentItem) => allContentItem.contentThumbnail == mentoredVideo.contentThumbnail).isEmpty) {
        _allContent.add(mentoredVideo);
      }
    });

    CoachTimelineGroup allTabContent = CoachTimelineGroup(
        courseId: _defaultIdForAllContentTimeline, courseName: OlukoLocalizations.get(context, 'all'), timelineElements: _allContent);

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

  void addContentToTimeline({CoachTimelineGroup timelineGroup, CoachTimelineItem newContent}) {
    if (timelineGroup.timelineElements.where((timelineElement) => timelineElement.contentName == newContent.contentName).isEmpty) {
      timelineGroup.timelineElements.add(newContent);
      timelineGroup.timelineElements.sort((a, b) => b.createdAt.toDate().compareTo(a.createdAt.toDate()));
    }
  }

  void notificationsWidget(List<CoachNotificationContent> contentForNotificationPanel, List<Widget> carouselContent) {
    contentForNotificationPanel.forEach((notificationContent) {
      carouselContent.add(CoachNotificationPanelContentCard(
        content: notificationContent,
        coachId: widget.coachId,
        userId: widget.coachAssignment.userId,
      ));
    });
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

  Widget sentVideos() {
    return _sentVideosContent != null && _sentVideosContent.isNotEmpty
        ? CoachContentPreviewContent(
            contentFor: CoachContentSection.sentVideos,
            titleForSection: OlukoLocalizations.get(context, 'sentVideos'),
            segmentSubmissionContent: _sentVideosContent,
            onNavigation: () => !widget.coachAssignment.introductionCompleted
                ? BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation()
                : () {},
          )
        : CoachContentSectionCard(
            title: OlukoLocalizations.get(context, 'sentVideos'),
          );
  }

  Widget mentoredVideos({bool isForCarousel}) {
    return _annotationVideosContent != null && _annotationVideosContent.isNotEmpty
        ? CoachContentPreviewContent(
            contentFor: CoachContentSection.mentoredVideos,
            titleForSection: OlukoLocalizations.get(context, 'mentoredVideos'),
            coachAnnotationContent: _annotationVideosContent,
            onNavigation: () => !widget.coachAssignment.introductionCompleted
                ? BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation()
                : () {})
        : CoachContentSectionCard(title: OlukoLocalizations.get(context, 'mentoredVideos'));
  }

  void checkAnnotationUpdate(List<Annotation> annotationUpdateListofContent) {
    annotationUpdateListofContent.forEach((updatedOrNewAnnotation) {
      List<Annotation> repeatedAnnotation = _annotationVideosContent.where((element) => element.id == updatedOrNewAnnotation.id).toList();
      if (repeatedAnnotation.isEmpty) {
        _annotationVideosContent.add(updatedOrNewAnnotation);
      } else {
        if (repeatedAnnotation.first != updatedOrNewAnnotation) {
          _annotationVideosContent[_annotationVideosContent.indexWhere((element) => element.id == updatedOrNewAnnotation.id)] =
              updatedOrNewAnnotation;
        }
      }
    });
  }

  void checkCoachRequestUpdate(List<CoachRequest> coachRequestContent) {
    coachRequestContent.forEach((coachRequestUpdatedItem) {
      List<CoachRequest> repeatedCoachRequest = _coachRequestList.where((element) => element.id == coachRequestUpdatedItem.id).toList();
      if (repeatedCoachRequest.isEmpty) {
        _coachRequestList.add(coachRequestUpdatedItem);
      } else {
        if (repeatedCoachRequest.first != coachRequestUpdatedItem) {
          _coachRequestList[_coachRequestList.indexWhere((element) => element.id == coachRequestUpdatedItem.id)] = coachRequestUpdatedItem;
        }
      }
    });
  }

  void checkRecommendationUpdate(List<CoachRecommendationDefault> coachRecommendationContent) {
    if (coachRecommendationContent.isNotEmpty) {
      coachRecommendationContent.forEach((updatedOrNewRecommedation) {
        List<CoachRecommendationDefault> repeatedRecommendation = _coachRecommendations
            .where((element) => element.coachRecommendation.id == updatedOrNewRecommedation.coachRecommendation.id)
            .toList();
        if (repeatedRecommendation.isEmpty) {
          _coachRecommendations.add(updatedOrNewRecommedation);
        } else {
          if (repeatedRecommendation.first != updatedOrNewRecommedation) {
            _coachRecommendations[_coachRecommendations
                    .indexWhere((element) => element.coachRecommendation.id == updatedOrNewRecommedation.coachRecommendation.id)] =
                updatedOrNewRecommedation;
          }
        }
      });
    }
  }

  void checkTimelineItemsUpdate(List<CoachTimelineItem> timelineItemsContent) {
    timelineItemsContent.forEach((updatedTimelineItem) {
      List<CoachTimelineItem> repeatedTimelineItem =
          _timelineItemsContent.where((element) => element.contentName == updatedTimelineItem.contentName).toList();
      if (repeatedTimelineItem.isEmpty) {
        _timelineItemsContent.add(updatedTimelineItem);
      }
    });
  }
}
