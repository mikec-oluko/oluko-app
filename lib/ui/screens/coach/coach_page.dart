import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
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
import 'package:oluko_app/blocs/introduction_media_bloc.dart';
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
import 'package:oluko_app/helpers/video_player_helper.dart';
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
import 'package:oluko_app/ui/components/carousel_section.dart';
import 'package:oluko_app/ui/components/coach_app_bar.dart';
import 'package:oluko_app/ui/components/coach_carousel_section.dart';
import 'package:oluko_app/ui/components/coach_content_preview_content.dart';
import 'package:oluko_app/ui/components/coach_content_section_card.dart';
import 'package:oluko_app/ui/components/coach_horizontal_carousel_component.dart';
import 'package:oluko_app/ui/components/coach_recommended_content_preview_stack.dart';
import 'package:oluko_app/ui/components/coach_sliding_up_panel.dart';
import 'package:oluko_app/ui/components/coach_user_progress_card.dart';
import 'package:oluko_app/ui/components/oluko_circular_progress_indicator.dart';
import 'package:oluko_app/ui/newDesignComponents/coach_horizontal_carousel.dart';
import 'package:oluko_app/ui/newDesignComponents/coach_upcoming_challenges.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
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

const String assessmentId = 'emnsmBgZ13UBRqTS26Qd';
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
List<Annotation> _annotationVideosList = [];
List<SegmentSubmission> _sentVideosList = [];
List<InfoForSegments> _segmentsFromCourseEnrollmentClasses = [];
List<CoachRecommendationDefault> _coachRecommendationList = [];
List<CoachTimelineItem> _timelineItemsContent = [];
List<CoachTimelineItem> _coachRecommendationTimelineContent = [];
List<CoachTimelineItem> _mentoredVideoTimelineContent = [];
List<CoachTimelineItem> _allContent = [];
List<CoachTimelineGroup> _timelinePanelContent = [];
List<CoachSegmentContent> _allSegmentsForUser = [];
List<Challenge> _activeChallenges = [];
List<SegmentSubmission> segmentsWithReview = [];
List<CoachMediaMessage> _coachVideoMessageList = [];
String _welcomeVideoUrl = '';
const Widget _separatorBox = SizedBox(
  width: 10,
);
const paddingTopForElements = EdgeInsets.only(top: OlukoNeumorphism.isNeumorphismDesign ? 20 : 0);

class _CoachPageState extends State<CoachPage> {
  @override
  void initState() {
    _requestCurrentUserData(context, userId: widget.userId, coachId: widget.coachId ?? widget.coachAssignment.coachId);
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
                                // TODO: POPULATE LIST _coachVideoMessageList
                                _coachVideoMessagesBuilderActions(state: coachVideoMessageState);
                                return BlocBuilder<CoachMentoredVideosBloc, CoachMentoredVideosState>(
                                  builder: (context, coachAnnotationsState) {
                                    // TODO: POPULATE LIST _annotationVideosList
                                    _coachAnnotationsBuilderActions(state: coachAnnotationsState);
                                    return BlocConsumer<CoachSentVideosBloc, CoachSentVideosState>(
                                      listener: (context, sentVideosListenerState) {
                                        _sentVideosListenerActions(state: sentVideosListenerState);
                                      },
                                      builder: (context, sentVideosState) {
                                        // TODO: POPULATE LIST _sentVideosContent
                                        _sentVideosBuilderActions(state: sentVideosState, context: context);
                                        return BlocBuilder<CoachTimelineItemsBloc, CoachTimelineItemsState>(
                                          builder: (context, timelineItemsState) {
                                            _timelineItemsBuilderActions(state: timelineItemsState);
                                            return BlocConsumer<CoachRecommendationsBloc, CoachRecommendationsState>(
                                              listener: (context, coachRecommendationsListenerState) {
                                                _coachRecommendationsListenerActions(state: coachRecommendationsListenerState);
                                              },
                                              builder: (context, coachRecommendationsState) {
                                                // TODO: POPULATE LIST _coachRecommendationList
                                                _coachRecommendationsBuilderActions(state: coachRecommendationsState);
                                                return BlocBuilder<IntroductionMediaBloc, IntroductionMediaState>(
                                                  builder: (context, state) {
                                                    if (state is Success) {
                                                      _welcomeVideoUrl = state.mediaURL;
                                                    }
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
        onNavigation: () => !coachAssignment.introductionCompleted ? BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation() : () {},
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
        isIntroductionVideoComplete: coachAssignment.introductionCompleted,
        currentUser: _currentAuthUser,
        onCurrentUserSelected: () => BlocProvider.of<CoachTimelineBloc>(context).emitTimelineTabsUpdate(contentForTimelinePanel: _timelinePanelContent),
      );
    }
  }

  void _requestCurrentUserData(BuildContext context, {String userId, String coachId}) {
    BlocProvider.of<AssessmentBloc>(context).getById(assessmentId);
    BlocProvider.of<TaskSubmissionBloc>(context).getTaskSubmissionByUserId(userId);
    BlocProvider.of<CoachRequestStreamBloc>(context).getStream(userId, coachId);
    BlocProvider.of<CoachRecommendationsBloc>(context).getStream(userId, coachId);
    BlocProvider.of<CoachMentoredVideosBloc>(context).getStream(userId, coachId);
    BlocProvider.of<CoachTimelineItemsBloc>(context).getStream(userId);
    BlocProvider.of<UserStatisticsBloc>(context).getUserStatistics(userId);
    BlocProvider.of<CoachSentVideosBloc>(context).getSentVideosByUserId(userId);
    BlocProvider.of<ChallengeStreamBloc>(context).getStream(userId);
    BlocProvider.of<CoachVideoMessageBloc>(context).getStream(userId: userId, coachId: coachId);
    BlocProvider.of<FriendBloc>(context).getFriendsByUserId(userId);
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
            child: Theme(
              data: Theme.of(context).copyWith(colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.transparent)),
              child: ListView(
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                children: [
                  _reviewsPendingSection(),
                  _notificationPanelSection(carouselNotificationWidgetList, coachCarouselSliderSection),
                  _userStatisticsSection(carouselNotificationWidgetList),
                  _contentForUserSection(),
                  _challengesToDoSection(context),
                  _defaultBottomSafeSpace()
                ],
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  void _pendingReviewProccess() => _sentVideosList.forEach((sentVideo) {
        segmentsWithReview = CoachHelperFunctions.checkPendingReviewsForSentVideos(
            sentVideo: sentVideo, annotationVideosContent: _annotationVideosList, segmentsWithReview: segmentsWithReview);
      });

  void _getActiveChallenges() {
    _segmentsFromCourseEnrollmentClasses = TransformListOfItemsToWidget.segments(_courseEnrollmentList);
    _allSegmentsForUser = TransformListOfItemsToWidget.createSegmentContentInforamtion(_segmentsFromCourseEnrollmentClasses, _activeChallenges);
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

  void _updateReviewPendingOnCoachAppBar(BuildContext context) => BlocProvider.of<CoachReviewPendingBloc>(context).updateReviewPendingMessage(
        _sentVideosList != null && segmentsWithReview != null ? _sentVideosList.length - segmentsWithReview.length : 0,
      );

  Padding _challengesToDoSection(BuildContext context) => Padding(
        padding: paddingTopForElements,
        child: _carouselToDoSection(context),
      );

  Padding _contentForUserSection() => Padding(
        padding: paddingTopForElements,
        child: Column(
          children: _listOfContentForUser(),
        ),
      );

  Widget getUserContentNewDesign({@required List<Widget> contentForCarousel, @required String titleForCarousel, @required double heightForCarousel}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: CoachTabHorizontalCarousel(
        width: ScreenUtils.width(context),
        height: heightForCarousel,
        optionLabel: OlukoLocalizations.get(context, 'seeAll'),
        title: titleForCarousel,
        children: contentForCarousel,
      ),
    );
  }

  Padding getVideoPreviewCard(String videoThumbnail) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
      child: Container(
        height: 100,
        width: 160,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)), image: DecorationImage(image: CachedNetworkImageProvider(videoThumbnail), fit: BoxFit.fill)),
        child: Center(
          child: Container(
            width: 50,
            height: 50,
            child: OlukoBlurredButton(
              childContent: Image.asset(
                'assets/self_recording/white_play_arrow.png',
                color: Colors.white,
                height: 50,
                width: 50,
              ),
            ),
          ),
        ),
      ),
    );
  }

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
        return numberOfReviewPendingItems != 0
            ? Container(
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
              )
            : const SizedBox.shrink();
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
        getUserContentNewDesign(
            contentForCarousel: _annotationVideosList.map((annotation) => getVideoPreviewCard(annotation.video.thumbUrl)).toList(),
            titleForCarousel: OlukoLocalizations.get(context, 'mentoredVideos'),
            heightForCarousel: 150),
        getUserContentNewDesign(
            contentForCarousel: _sentVideosList.map((sentVideo) => getVideoPreviewCard(sentVideo.video.thumbUrl)).toList(),
            titleForCarousel: 'Sent Videos',
            heightForCarousel: 150),
        getUserContentNewDesign(
            contentForCarousel: _coachVideoMessageList.map((coachVideoMessage) => getVideoPreviewCard(coachVideoMessage.video.thumbUrl)).toList(),
            titleForCarousel: 'Video Message',
            heightForCarousel: 150),
        getUserContentNewDesign(
            contentForCarousel: CoachHelperFunctions.getRecommendedVideosContent(_coachRecommendationList)
                .map((recommendedVideo) => getVideoPreviewCard(recommendedVideo.video.thumbUrl))
                .toList(),
            titleForCarousel: 'Recommended Videos',
            heightForCarousel: 150),
        getUserContentNewDesign(
            // contentForCarousel: CoachHelperFunctions.getRecommendedVideosContent(_coachRecommendationList)
            contentForCarousel:
                CoachHelperFunctions.getRecommendedContentByType(_coachRecommendationList, TimelineInteractionType.movement, [], onlyContent: true)
                    .map((recommendedMovement) => getVideoPreviewCard(recommendedMovement.contentImage))
                    .toList(),
            titleForCarousel: 'Recommended Movements',
            heightForCarousel: 150),
        getUserContentNewDesign(
            // contentForCarousel: CoachHelperFunctions.getRecommendedVideosContent(_coachRecommendationList)
            contentForCarousel:
                CoachHelperFunctions.getRecommendedContentByType(_coachRecommendationList, TimelineInteractionType.course, [], onlyContent: true)
                    .map((recommendedMovement) => getVideoPreviewCard(recommendedMovement.contentImage))
                    .toList(),
            titleForCarousel: 'Recommended Courses',
            heightForCarousel: 150),
        // _recommendedCoursesSection(),
        // _separatorBox,
        // _recommendedMovementsSection(),
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
      annotationVideos: _annotationVideosList,
      coachRecommendations: _coachRecommendationList,
      coachVideoMessages: _coachVideoMessageList,
      onCloseCard: () => BlocProvider.of<CoachAssignmentBloc>(context).welcomeVideoAsSeen(coachAssignment),
      onOpenCard: () {
        Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo],
            arguments: {'videoUrl': _welcomeVideoUrl, 'titleForContent': OlukoLocalizations.of(context).find('welcomeVideo')});
        BlocProvider.of<CoachAssignmentBloc>(context).welcomeVideoAsSeen(coachAssignment);
      },
    );
  }

  void _addCoachAssignmentVideo() => _annotationVideosList = CoachHelperFunctions.addIntroVideoOnAnnotations(_annotationVideosList, _introductionVideo);

  void _timelineContentBuilding(BuildContext context) {
    _timelinePanelContent = CoachTimelineFunctions.getTimelineContentForPanel(
      context,
      timelineContentTabs: _timelinePanelContent,
      timelineItemsFromState: _timelineItemsContent,
      allContent: _allContent,
      listOfCoursesId: _courseEnrollmentList.map((enrolledCourse) => enrolledCourse.course.id).toList(),
    );
  }

  void _coachRecommendationsTimelineItems() {
    _coachRecommendationList.isNotEmpty
        ? _coachRecommendationList.forEach((recommendation) {
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
    return ((_coachRecommendationList != null && _coachRecommendationList.isNotEmpty) &&
            _coachRecommendationList.where((coachRecommendation) => coachRecommendation.contentType == TimelineInteractionType.recommendedVideo).isNotEmpty)
        ? CoachContentPreviewComponent(
            contentFor: CoachContentSection.recomendedVideos,
            titleForSection: OlukoLocalizations.get(context, 'recommendedVideos'),
            recommendedVideoContent: CoachHelperFunctions.getRecommendedVideosContent(_coachRecommendationList),
            onNavigation: () => !coachAssignment.introductionCompleted ? BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation() : () {})
        : CoachContentSectionCard(title: OlukoLocalizations.get(context, 'recommendedVideos'));
  }

  Widget _recommendedCoursesSection({bool isForCarousel}) => CoachHelperFunctions.recommendedContentImageStack(
        context: context,
        coachRecommendations: _coachRecommendationList,
        contentType: TimelineInteractionType.course,
        onTap: (courseRecommended) {
          BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation();
          Navigator.pushNamed(context, routeLabels[RouteEnum.coachRecommendedContentGallery],
              arguments: {'recommendedContent': courseRecommended, 'titleForAppBar': OlukoLocalizations.of(context).find('recommendedCourses')});
        },
      );

  Widget _recommendedMovementsSection({bool isForCarousel}) => CoachHelperFunctions.recommendedContentImageStack(
        context: context,
        coachRecommendations: _coachRecommendationList,
        contentType: TimelineInteractionType.movement,
        onTap: (movementsRecommended) {
          BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation();
          Navigator.pushNamed(context, routeLabels[RouteEnum.coachRecommendedContentGallery],
              arguments: {'recommendedContent': movementsRecommended, 'titleForAppBar': OlukoLocalizations.of(context).find('recommendedMovements')});
        },
      );

  void _disposeView(CoachTimelineItemsDispose timelineItemsUpdateListener) {
    _timelineItemsContent = timelineItemsUpdateListener.timelineItemsDisposeValue;
    _allContent.clear();
    _coachRecommendationTimelineContent.clear();
    _mentoredVideoTimelineContent.clear();
    _coachRecommendationTimelineContent.clear();
    _timelinePanelContent.clear();
    _introductionVideo ??= CoachHelperFunctions.createWelcomeVideoFromCoachAssignment(coachAssignment: coachAssignment, userId: widget.userId);
  }

  void _coachRecommendationsBuilderActions({@required CoachRecommendationsState state}) {
    if (state is CoachRecommendationsSuccess) {
      _coachRecommendationList = state.coachRecommendationList;
      _coachRecommendationsTimelineItems();
    }
  }

  void _coachRecommendationsListenerActions({@required CoachRecommendationsState state}) {
    if (state is CoachRecommendationsDispose) {
      _coachRecommendationList = state.coachRecommendationListDisposeValue;
    }
    if (state is CoachRecommendationsUpdate) {
      _coachRecommendationList = CoachHelperFunctions.checkRecommendationUpdate(state.coachRecommendationContent, _coachRecommendationList);
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
      _sentVideosList = state.sentVideos.where((sentVideo) => sentVideo.video != null && sentVideo.coachId == _coachUser.id).toList();
      _pendingReviewProccess();
      _updateReviewPendingOnCoachAppBar(context);
    }
  }

  void _sentVideosListenerActions({@required CoachSentVideosState state}) {
    if (state is CoachSentVideosDispose) {
      _sentVideosList = state.sentVideosDisposeValue;
    }
  }

  void _coachAnnotationsBuilderActions({@required CoachMentoredVideosState state}) {
    if (state is CoachMentoredVideosSuccess) {
      _annotationVideosList = state.mentoredVideos.where((mentoredVideo) => mentoredVideo.video != null).toList();
      _addCoachAssignmentVideo();
    }
    if (state is CoachMentoredVideosUpdate) {
      _annotationVideosList = CoachHelperFunctions.checkAnnotationUpdate(state.mentoredVideos, _annotationVideosList);
    }
    if (state is CoachMentoredVideosDispose) {
      _annotationVideosList = state.mentoredVideosDisposeValue;
      segmentsWithReview.clear();
    }
  }

  void _coachVideoMessagesBuilderActions({@required CoachVideoMessageState state}) {
    if (state is CoachVideoMessageSuccess) {
      _coachVideoMessageList = state.coachVideoMessages;
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
