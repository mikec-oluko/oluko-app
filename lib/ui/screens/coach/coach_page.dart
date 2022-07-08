import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_assignment_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_interaction_timeline_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_introduction_video_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_mentored_videos_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_recommendations_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_request_stream_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_review_pending_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_sent_videos_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_timeline_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_user_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_video_message_bloc.dart';
import 'package:oluko_app/blocs/course_enrollment/course_enrollment_list_stream_bloc.dart';
import 'package:oluko_app/blocs/friends/friend_bloc.dart';
import 'package:oluko_app/blocs/task_bloc.dart';
import 'package:oluko_app/blocs/task_submission/task_submission_bloc.dart';
import 'package:oluko_app/blocs/user_statistics_bloc.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/helpers/challenge_navigation.dart';
import 'package:oluko_app/helpers/coach_content_for_timeline_panel.dart';
import 'package:oluko_app/helpers/coach_helper_functions.dart';
import 'package:oluko_app/helpers/coach_recommendation_default.dart';
import 'package:oluko_app/helpers/coach_segment_content.dart';
import 'package:oluko_app/helpers/coach_segment_info.dart';
import 'package:oluko_app/helpers/coach_timeline_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/list_of_items_to_widget.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/challenge.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/coach_media_message.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/coach_timeline_item.dart';
import 'package:oluko_app/models/coach_user.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/recommendation_media.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/models/user_statistics.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/services/global_service.dart';
import 'package:oluko_app/ui/components/coach_app_bar.dart';
import 'package:oluko_app/ui/components/coach_carousel_section.dart';
import 'package:oluko_app/ui/components/coach_content_preview_content.dart';
import 'package:oluko_app/ui/components/coach_content_section_card.dart';
import 'package:oluko_app/ui/components/coach_horizontal_carousel_component.dart';
import 'package:oluko_app/ui/components/coach_recommended_content_preview_stack.dart';
import 'package:oluko_app/ui/components/coach_sliding_up_panel.dart';
import 'package:oluko_app/ui/components/coach_user_progress_card.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/newDesignComponents/coach_upcoming_challenges.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_loading_full_screen.dart';
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

const String _defaultIdForAllContentTimeline = '0';
const String _defaultIntroductionVideoId = 'introVideo';
const bool hideAssessmentsTab = true;
final GlobalService _globalService = GlobalService();
UserResponse _currentAuthUser;
CoachUser _coachUser;
UserStatistics _userStatistics;
Assessment _assessment;
Annotation _introductionVideo;
num numberOfReviewPendingItems = 0;
CoachAssignment coachAssignment;
List<CourseEnrollment> _courseEnrollmentList = [];
List<Annotation> _annotationVideosContent = [];
List<SegmentSubmission> _sentVideosContent = [];
List<InfoForSegments> _segmentsFromCourseEnrollmentClasses = [];
List<CoachRecommendationDefault> _coachRecommendations = [];
List<CoachTimelineItem> _timelineItemsContent = [];
List<CoachTimelineItem> _coachRecommendationTimelineContent = [];
List<CoachTimelineItem> _mentoredVideoTimelineContent = [];
List<CoachTimelineItem> _allContent = [];
List<CoachTimelineGroup> _timelinePanelContent = [];
List<CoachSegmentContent> _allSegmentsForUser = [];
List<Challenge> _activeChallenges = [];
List<SegmentSubmission> segmentsWithReview = [];
List<CoachMediaMessage> _coachVideoMessages = [];
const Widget _separatorBox = SizedBox(
  width: 10,
);
const paddingTopForElements = EdgeInsets.only(top: OlukoNeumorphism.isNeumorphismDesign ? 20 : 0);

class _CoachPageState extends State<CoachPage> {
  @override
  void initState() {
    BlocProvider.of<CoachUserBloc>(context).get(widget.coachAssignment.coachId);
    setState(() {
      coachAssignment = widget.coachAssignment;
      super.initState();
    });
  }

  @override
  void dispose() {
    _introductionVideo = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthSuccess) {
          _currentAuthUser = authState.user;
          _requestCurrentUserData(context);
          return BlocBuilder<CoachUserBloc, CoachUserState>(
            builder: (context, coachUserState) {
              if (coachUserState is CoachUserSuccess) {
                _coachUser = coachUserState.coach;
              }
              return Scaffold(
                extendBody: true,
                appBar: _getCoachAppBar(context),
                body: BlocBuilder<CoachAssignmentBloc, CoachAssignmentState>(
                  builder: (context, coachAssignmentState) {
                    _coachAssignmentBuilderActions(state: coachAssignmentState);
                    return BlocBuilder<ChallengeStreamBloc, ChallengeStreamState>(
                      builder: (context, challengeState) {
                        _challengesBuilderActions(state: challengeState);
                        return BlocBuilder<CourseEnrollmentListStreamBloc, CourseEnrollmentListStreamState>(
                          builder: (context, courseEnrollmentState) {
                            _courseEnrollmentBuilderActions(state: courseEnrollmentState);
                            return BlocBuilder<CoachVideoMessageBloc, CoachVideoMessageState>(
                              builder: (context, coachVideoMessageState) {
                                _coachVideoMessagesBuilderActions(state: coachVideoMessageState);
                                return BlocBuilder<CoachMentoredVideosBloc, CoachMentoredVideosState>(
                                  builder: (context, coachAnnotationsState) {
                                    _coachAnnotationsBuilderActions(state: coachAnnotationsState);
                                    return BlocConsumer<CoachSentVideosBloc, CoachSentVideosState>(
                                      listener: (context, sentVideosListenerState) {
                                        _sentVideosListenerActions(state: sentVideosListenerState);
                                      },
                                      builder: (context, sentVideosState) {
                                        _sentVideosBuilderActions(state: sentVideosState, context: context);
                                        return BlocBuilder<CoachTimelineItemsBloc, CoachTimelineItemsState>(
                                          builder: (context, timelineItemsState) {
                                            _timelineItemsBuilderActions(state: timelineItemsState);
                                            return BlocConsumer<CoachRecommendationsBloc, CoachRecommendationsState>(
                                              listener: (context, coachRecommendationsListenerState) {
                                                _coachRecommendationsListenerActions(state: coachRecommendationsListenerState);
                                              },
                                              builder: (context, coachRecommendationsState) {
                                                _coachRecommendationsBuilderActions(state: coachRecommendationsState);
                                                return _panelAndViewCreation(context);
                                              },
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
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        } else {
          return const LoadinScreen();
        }
      },
    );
  }

  CoachAppBar _getCoachAppBar(BuildContext context) => CoachAppBar(
        coachUser: _coachUser,
        currentUser: _currentAuthUser,
        onNavigation: () =>
            !coachAssignment.introductionCompleted ? BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation() : () {},
      );

  Widget _panelAndViewCreation(BuildContext context) {
    _insertWelcomeVideoOnTimeline(context);
    _timelineContentBuilding(context);
    if (_timelinePanelContent == null) {
      return Container(color: OlukoNeumorphismColors.appBackgroundColor, child: OlukoCircularProgressIndicator());
    } else {
      BlocProvider.of<CoachTimelineBloc>(context).emitTimelineTabsUpdate(contentForTimelinePanel: _timelinePanelContent);
      return CoachSlidingUpPanel(
          content: _coachViewPageContent(context),
          timelineItemsContent: _timelinePanelContent,
          isIntroductionVideoComplete: coachAssignment.introductionCompleted);
    }
  }

  void _requestCurrentUserData(BuildContext context) {
    BlocProvider.of<AssessmentBloc>(context).getById('emnsmBgZ13UBRqTS26Qd');
    BlocProvider.of<TaskSubmissionBloc>(context).getTaskSubmissionByUserId(_currentAuthUser.id);
    BlocProvider.of<CoachRequestStreamBloc>(context).getStream(_currentAuthUser.id, coachAssignment.coachId);
    BlocProvider.of<CoachRecommendationsBloc>(context).getStream(_currentAuthUser.id, coachAssignment.coachId);
    BlocProvider.of<CoachMentoredVideosBloc>(context).getStream(_currentAuthUser.id, coachAssignment.coachId);
    BlocProvider.of<CoachTimelineItemsBloc>(context).getStream(_currentAuthUser.id);
    BlocProvider.of<UserStatisticsBloc>(context).getUserStatistics(_currentAuthUser.id);
    BlocProvider.of<CoachSentVideosBloc>(context).getSentVideosByUserId(_currentAuthUser.id);
    BlocProvider.of<ChallengeStreamBloc>(context).getStream(_currentAuthUser.id);
    BlocProvider.of<CoachVideoMessageBloc>(context).getStream(userId: _currentAuthUser.id, coachId: coachAssignment.coachId);
    BlocProvider.of<FriendBloc>(context).getFriendsByUserId(_currentAuthUser.id);
  }

  Widget _coachViewPageContent(BuildContext context) {
    return BlocBuilder<AssessmentBloc, AssessmentState>(
      builder: (context, state) {
        if (state is AssessmentSuccess) {
          _assessment = state.assessment;
          BlocProvider.of<TaskBloc>(context).get(_assessment);
          final carouselNotificationWidgetList = _carouselNotificationWidget(context);
          final coachCarouselSliderSection = CoachCarouselSliderSection(
            contentForCarousel: carouselNotificationWidgetList,
            introductionCompleted: coachAssignment.introductionCompleted,
            introductionVideo: _assessment.video,
          );

          return Container(
            color: OlukoNeumorphismColors.appBackgroundColor,
            child: ListView(
              children: [
                _reviewsPendingSection(),
                _notificationPanelSection(carouselNotificationWidgetList, coachCarouselSliderSection),
                _userStatisticsSection(carouselNotificationWidgetList),
                _contentForUserSection(),
                _challengesToDoSection(context),
                _defaultBottomSafeSpace()
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  void _pendingReviewProccess() => _sentVideosContent.forEach((sentVideo) {
        segmentsWithReview = CoachHelperFunctions.checkPendingReviewsForSentVideos(
            sentVideo: sentVideo, annotationVideosContent: _annotationVideosContent, segmentsWithReview: segmentsWithReview);
      });

  void _getActiveChallenges() {
    _segmentsFromCourseEnrollmentClasses = TransformListOfItemsToWidget.segments(_courseEnrollmentList);
    _allSegmentsForUser =
        TransformListOfItemsToWidget.createSegmentContentInforamtion(_segmentsFromCourseEnrollmentClasses, _activeChallenges);
  }

  void _welcomeVideoProccess(CoachAssignmentResponse state) {
    if (state.coachAssignmentResponse.video?.url != null) {
      _introductionVideo = CoachHelperFunctions.createWelcomeVideoFromCoachAssignment(
        coachAssignment: coachAssignment,
        userId: widget.userId,
        defaultIntroVideoId: _defaultIntroductionVideoId,
      );
    }
  }

  void _insertWelcomeVideoOnTimeline(BuildContext context) => _introductionVideo != null && _introductionVideo.video.url != null
      ? _timelineItemsContent = CoachTimelineFunctions.addWelcomeVideoToTimeline(
          context: context,
          timelineItems: _timelineItemsContent,
          welcomeVideo: _introductionVideo,
        )
      : null;

  void _updateReviewPendingOnCoachAppBar(BuildContext context) =>
      BlocProvider.of<CoachReviewPendingBloc>(context).updateReviewPendingMessage(
        _sentVideosContent != null && segmentsWithReview != null ? _sentVideosContent.length - segmentsWithReview.length : 0,
      );

  Padding _challengesToDoSection(BuildContext context) => Padding(
        padding: paddingTopForElements,
        child: _carouselToDoSection(context),
      );

  Padding _contentForUserSection() => Padding(
        padding: paddingTopForElements,
        child: CoachHorizontalCarousel(contentToDisplay: _listOfContentForUser(), isForVideoContent: true),
      );

  Padding _userStatisticsSection(List<Widget> carouselNotificationWidgetList) => Padding(
        padding: paddingTopForElements,
        child: _userProgressSectionContent(carouselNotificationWidgetList.isEmpty),
      );

  Widget _notificationPanelSection(List<Widget> notifications, CoachCarouselSliderSection coachCarouselSliderSection) {
    if (notifications.isNotEmpty) {
      return Padding(
        padding: paddingTopForElements,
        child: coachCarouselSliderSection,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _reviewsPendingSection() {
    return BlocConsumer<CoachReviewPendingBloc, CoachReviewPendingState>(
      listener: (context, state) {
        if (state is CoachReviewPendingDispose) {
          numberOfReviewPendingItems = state.reviewsPendingDisposeValue;
        }
        if (state is CoachReviewPendingSuccess) {
          numberOfReviewPendingItems = state.reviewsPending;
        }
      },
      builder: (context, state) {
        return Container(
          width: ScreenUtils.width(context),
          height: 50,
          color: OlukoNeumorphismColors.olukoNeumorphicSearchBarSecondColor,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '$numberOfReviewPendingItems ${OlukoLocalizations.get(context, 'reviewsPending')}',
                  style: OlukoFonts.olukoMediumFont(customColor: OlukoColors.grayColor.withOpacity(0.5), customFontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  BlocBuilder<UserStatisticsBloc, UserStatisticsState> _userProgressSectionContent(bool startExpanded) {
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

  List<Widget> _listOfContentForUser() => [
        CoachHelperFunctions.mentoredVideosSection(
            context: context,
            annotation: _annotationVideosContent,
            introFinished: coachAssignment.introductionCompleted,
            onNavigation: () => BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation(),
            coachMediaMessages: _coachVideoMessages),
        _separatorBox,
        CoachHelperFunctions.sentVideosSection(
            context: context,
            sentVideosContent: _sentVideosContent,
            introductionCompleted: coachAssignment.introductionCompleted,
            onNavigation: () => BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation()),
        _separatorBox,
        _recommendedVideosSection(),
        _separatorBox,
        _recommendedCoursesSection(),
        _separatorBox,
        _recommendedMovementsSection(),
      ];

  SizedBox _carouselToDoSection(BuildContext context) => SizedBox(child: _toDoSection(context));

  Widget _toDoSection(BuildContext context) => _toDoContent().isNotEmpty
      ? CoachUpcomingChallenges(
          challengesContentList: _toDoContent(),
        )
      : const SizedBox.shrink();

  List<Widget> _toDoContent() => TransformListOfItemsToWidget.coachChallengesAndSegments(
      segments: _allSegmentsForUser.where((segment) => segment.isChallenge && segment.completedAt == null).toList());

  List<Widget> _carouselNotificationWidget(BuildContext context) {
    return CoachHelperFunctions.notificationPanel(
      context: context,
      assessment: _assessment,
      coachAssignment: coachAssignment,
      annotationVideos: _annotationVideosContent,
      coachRecommendations: _coachRecommendations,
      coachVideoMessages: _coachVideoMessages,
      onCloseCard: () => BlocProvider.of<CoachAssignmentBloc>(context).welcomeVideoAsSeen(coachAssignment),
      onOpenCard: () {
        Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo],
            arguments: {'videoUrl': _assessment.video, 'titleForContent': OlukoLocalizations.of(context).find('welcomeVideo')});
        BlocProvider.of<CoachAssignmentBloc>(context).welcomeVideoAsSeen(coachAssignment);
      },
    );
  }

  void _addCoachAssignmentVideo() =>
      _annotationVideosContent = CoachHelperFunctions.addIntroVideoOnAnnotations(_annotationVideosContent, _introductionVideo);

  void _timelineContentBuilding(BuildContext context) {
    _timelinePanelContent = CoachTimelineFunctions.buildContentForTimelinePanel(
        timelineItemsContent: _timelineItemsContent,
        enrolledCourseIdList: _courseEnrollmentList.map((enrolledCourse) => enrolledCourse.course.id).toList());

    _timelinePanelContent.forEach((timelinePanelElement) {
      timelinePanelElement.timelineElements.forEach((timelineContentItem) {
        if (_allContent.where((allContentItem) => allContentItem.contentName == timelineContentItem.contentName).isEmpty) {
          _allContent.add(timelineContentItem);
        }
      });
    });
    CoachTimelineGroup allTabContent = CoachTimelineGroup(
        courseId: _defaultIdForAllContentTimeline, courseName: OlukoLocalizations.get(context, 'all'), timelineElements: _allContent);

    _timelinePanelContent = CoachTimelineFunctions.timelinePanelUpdateTabsAndContent(allTabContent, _timelinePanelContent);
  }

  void _coachRecommendationsTimelineItems() {
    _coachRecommendations.isNotEmpty
        ? _coachRecommendations.forEach((recommendation) {
            final newTimelineItem = CoachTimelineFunctions.createAnCoachTimelineItem(recommendationItem: recommendation);
            if (!_coachRecommendationTimelineContent.contains(newTimelineItem)) {
              _coachRecommendationTimelineContent.add(newTimelineItem);
            }
          })
        : null;
    _coachRecommendationTimelineContent.isNotEmpty
        ? _coachRecommendationTimelineContent.forEach((recomendationTimelineItem) {
            if (_allContent.where((contentElement) => contentElement.contentName == recomendationTimelineItem.contentName).isEmpty) {
              _allContent.add(recomendationTimelineItem);
            }
          })
        : null;
  }

  SizedBox _defaultBottomSafeSpace() => const SizedBox(
        height: hideAssessmentsTab ? 220 : 200,
      );

  Widget _recommendedVideosSection({bool isForCarousel}) {
    return ((_coachRecommendations != null && _coachRecommendations.isNotEmpty) &&
            _coachRecommendations
                .where((coachRecommendation) => coachRecommendation.contentType == TimelineInteractionType.recommendedVideo)
                .isNotEmpty)
        ? CoachContentPreviewComponent(
            contentFor: CoachContentSection.recomendedVideos,
            titleForSection: OlukoLocalizations.get(context, 'recommendedVideos'),
            recommendedVideoContent: CoachHelperFunctions.getRecommendedVideosContent(_coachRecommendations),
            onNavigation: () => !coachAssignment.introductionCompleted
                ? BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation()
                : () {})
        : CoachContentSectionCard(title: OlukoLocalizations.get(context, 'recommendedVideos'));
  }

  Widget _recommendedCoursesSection({bool isForCarousel}) => CoachHelperFunctions.recommendedContentImageStack(
        context: context,
        coachRecommendations: _coachRecommendations,
        contentType: TimelineInteractionType.course,
        onTap: (courseRecommended) {
          BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation();
          Navigator.pushNamed(context, routeLabels[RouteEnum.coachRecommendedContentGallery], arguments: {
            'recommendedContent': courseRecommended,
            'titleForAppBar': OlukoLocalizations.of(context).find('recommendedCourses')
          });
        },
      );

  Widget _recommendedMovementsSection({bool isForCarousel}) => CoachHelperFunctions.recommendedContentImageStack(
        context: context,
        coachRecommendations: _coachRecommendations,
        contentType: TimelineInteractionType.movement,
        onTap: (movementsRecommended) {
          BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation();
          Navigator.pushNamed(context, routeLabels[RouteEnum.coachRecommendedContentGallery], arguments: {
            'recommendedContent': movementsRecommended,
            'titleForAppBar': OlukoLocalizations.of(context).find('recommendedMovements')
          });
        },
      );

  void _disposeView(CoachTimelineItemsDispose timelineItemsUpdateListener) {
    _timelineItemsContent = timelineItemsUpdateListener.timelineItemsDisposeValue;
    _allContent.clear();
    _coachRecommendationTimelineContent.clear();
    _mentoredVideoTimelineContent.clear();
    _coachRecommendationTimelineContent.clear();
    _timelinePanelContent.clear();
    _introductionVideo ??=
        CoachHelperFunctions.createWelcomeVideoFromCoachAssignment(coachAssignment: coachAssignment, userId: widget.userId);
  }

  void _coachRecommendationsBuilderActions({@required CoachRecommendationsState state}) {
    if (state is CoachRecommendationsSuccess) {
      _coachRecommendations = state.coachRecommendationList;
      _coachRecommendationsTimelineItems();
    }
  }

  void _coachRecommendationsListenerActions({@required CoachRecommendationsState state}) {
    if (state is CoachRecommendationsDispose) {
      _coachRecommendations = state.coachRecommendationListDisposeValue;
    }
    if (state is CoachRecommendationsUpdate) {
      _coachRecommendations = CoachHelperFunctions.checkRecommendationUpdate(state.coachRecommendationContent, _coachRecommendations);
      _coachRecommendationsTimelineItems();
    }
  }

  void _timelineItemsBuilderActions({@required CoachTimelineItemsState state}) {
    if (state is CoachTimelineItemsSuccess) {
      _timelineItemsContent = state.timelineItems;
    }
    if (state is CoachTimelineItemsUpdate) {
      _timelineItemsContent = CoachHelperFunctions.checkTimelineItemsUpdate(state.timelineItems, _timelineItemsContent);
    }
    if (state is CoachTimelineItemsDispose) {
      _disposeView(state);
    }
  }

  void _sentVideosBuilderActions({@required CoachSentVideosState state, @required BuildContext context}) {
    if (state is CoachSentVideosSuccess) {
      _sentVideosContent = state.sentVideos.where((sentVideo) => sentVideo.video != null && sentVideo.coachId == _coachUser.id).toList();
      _pendingReviewProccess();
      _updateReviewPendingOnCoachAppBar(context);
    }
  }

  void _sentVideosListenerActions({@required CoachSentVideosState state}) {
    if (state is CoachSentVideosDispose) {
      _sentVideosContent = state.sentVideosDisposeValue;
    }
  }

  void _coachAnnotationsBuilderActions({@required CoachMentoredVideosState state}) {
    if (state is CoachMentoredVideosSuccess) {
      _annotationVideosContent = state.mentoredVideos.where((mentoredVideo) => mentoredVideo.video != null).toList();
      _addCoachAssignmentVideo();
    }
    if (state is CoachMentoredVideosUpdate) {
      _annotationVideosContent = CoachHelperFunctions.checkAnnotationUpdate(state.mentoredVideos, _annotationVideosContent);
    }
    if (state is CoachMentoredVideosDispose) {
      _annotationVideosContent = state.mentoredVideosDisposeValue;
      segmentsWithReview.clear();
    }
  }

  void _coachVideoMessagesBuilderActions({@required CoachVideoMessageState state}) {
    if (state is CoachVideoMessageSuccess) {
      _coachVideoMessages = state.coachVideoMessages;
    }
  }

  void _courseEnrollmentBuilderActions({@required CourseEnrollmentListStreamState state}) {
    List<ChallengeNavigation> listOfChallenges;
    if (state is CourseEnrollmentsByUserStreamSuccess) {
      _courseEnrollmentList = state.courseEnrollments;
      _getActiveChallenges();
    }
  }

  void _challengesBuilderActions({@required ChallengeStreamState state}) {
    if (state is GetChallengeStreamSuccess) {
      _activeChallenges = state.challenges;
    }
  }

  void _coachAssignmentBuilderActions({@required CoachAssignmentState state}) {
    if (state is CoachAssignmentResponse) {
      coachAssignment = state.coachAssignmentResponse;
      _welcomeVideoProccess(state);
    }
  }
}
