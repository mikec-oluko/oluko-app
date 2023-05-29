import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:oluko_app/blocs/assessment_bloc.dart';
import 'package:oluko_app/blocs/auth_bloc.dart';
import 'package:oluko_app/blocs/challenge/challenge_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_assignment_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_audio_messages_bloc.dart';
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
import 'package:oluko_app/ui/newDesignComponents/coach_carousel_content.dart';
import 'package:oluko_app/ui/newDesignComponents/coach_horizontal_carousel.dart';
import 'package:oluko_app/ui/newDesignComponents/coach_upcoming_challenges.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_blurred_button.dart';
import 'package:oluko_app/ui/newDesignComponents/oluko_loading_full_screen.dart';
import 'package:oluko_app/utils/app_messages.dart';
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
Assessment _assessment;
Annotation _introductionVideo;
num numberOfReviewPendingItems = 0;
CoachAssignment coachAssignment;
List<CourseEnrollment> _courseEnrollmentList = [];
List<Annotation> _annotationVideosList = [];
List<SegmentSubmission> _sentVideosList = [];
List<CoachRecommendationDefault> _coachRecommendationList = [];
List<CoachTimelineItem> _timelineItemsContent = [];
List<CoachTimelineItem> _coachRecommendationTimelineContent = [];
List<CoachTimelineItem> _mentoredVideoTimelineContent = [];
List<CoachTimelineItem> _allContent = [];
List<CoachTimelineGroup> _timelinePanelContent = [];
List<SegmentSubmission> segmentsWithReview = [];
List<CoachMediaMessage> _coachVideoMessageList = [];
String _welcomeVideoUrl = '';
const Widget _separatorBox = SizedBox(
  width: 10,
);
const paddingTopForElements = EdgeInsets.only(top: OlukoNeumorphism.isNeumorphismDesign ? 20 : 0);
const double heightForVideoContent = 160;
const double heightForCardContent = 240;

class _CoachPageState extends State<CoachPage> {
  @override
  void initState() {
    BlocProvider.of<CoachUserBloc>(context).get(widget.coachAssignment.coachId);
    _requestCurrentUserData(context, userId: widget.userId, coachId: widget.coachId ?? widget.coachAssignment.coachId);
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
                                            return BlocBuilder<IntroductionMediaBloc, IntroductionMediaState>(
                                              builder: (context, state) {
                                                if (state is Success) {
                                                  _welcomeVideoUrl = state.mediaURL;
                                                }
                                                return BlocListener<CoachAudioMessageBloc, CoachAudioMessagesState>(
                                                  listener: (context, state) {
                                                    if (state is CoachAudioMessagesSent) {
                                                      AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'audioMessageSent'));
                                                    } else if (state is CoachAudioMessagesFailure) {
                                                      AppMessages.clearAndShowSnackbar(context, OlukoLocalizations.get(context, 'audioMessageFailed'));
                                                    }
                                                  },
                                                  child: _panelAndViewCreation(context),
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
        onNavigationAction: () =>
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
        isIntroductionVideoComplete: coachAssignment.introductionCompleted,
        currentUser: _currentAuthUser,
        onCurrentUserSelected: () => BlocProvider.of<CoachTimelineBloc>(context).emitTimelineTabsUpdate(contentForTimelinePanel: _timelinePanelContent),
      );
    }
  }

  void _requestCurrentUserData(BuildContext context, {String userId, String coachId}) {
    BlocProvider.of<CoachMentoredVideosBloc>(context).getStream(userId, coachId);
    BlocProvider.of<CoachVideoMessageBloc>(context).getStream(userId: userId, coachId: coachId);
    BlocProvider.of<AssessmentBloc>(context).getById(assessmentId);
    BlocProvider.of<TaskSubmissionBloc>(context).getTaskSubmissionByUserId(userId);
    BlocProvider.of<CoachRecommendationsBloc>(context).getStream(userId, coachId);
    BlocProvider.of<CoachTimelineItemsBloc>(context).getStream(userId);
    BlocProvider.of<CoachSentVideosBloc>(context).getSentVideosByUserId(userId);
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
              child: ListView.builder(
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      _reviewsPendingSection(),
                      _notificationPanelSection(carouselNotificationWidgetList, coachCarouselSliderSection),
                      _getMentoredVideos(context),
                      _getSendVideos(context),
                      _getMessageVideos(context),
                      _getRecommendedVideos(context),
                      _getRecommendedMovements(context),
                      _getRecommendedCourses(context),
                      _defaultBottomSafeSpace()
                    ],
                  );
                },
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _getRecommendedCourses(BuildContext context) {
    final List<CoachRecommendationDefault> recommededCourses =
        CoachHelperFunctions.getRecommendedContentByType(_coachRecommendationList, TimelineInteractionType.course, [], onlyContent: true);
    return recommededCourses.isNotEmpty
        ? coachTabCarouselComponent(
            viewAllTapAction: () {
              BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation();
              Navigator.pushNamed(context, routeLabels[RouteEnum.coachRecommendedContentGallery],
                  arguments: {'recommendedContent': recommededCourses, 'titleForAppBar': OlukoLocalizations.of(context).find('recommendedCourses')});
            },
            contentForCarousel: recommededCourses
                .map((recommendedCourse) => CoachCarouselContent(
                      contentImage: recommendedCourse.contentImage,
                      isForPosterContent: true,
                      onTapContent: () => Navigator.pushNamed(context, routeLabels[RouteEnum.courseMarketing],
                          arguments: {'course': recommendedCourse.courseContent, 'fromCoach': true, 'isCoachRecommendation': true}),
                    ))
                .toList(),
            titleForCarousel: OlukoLocalizations.of(context).find('recommendedCourses'),
            heightForCarousel: heightForCardContent)
        : const SizedBox.shrink();
  }

  Widget _getRecommendedMovements(BuildContext context) {
    final List<CoachRecommendationDefault> recommendedMovements =
        CoachHelperFunctions.getRecommendedContentByType(_coachRecommendationList, TimelineInteractionType.movement, [], onlyContent: true);
    return recommendedMovements.isNotEmpty
        ? coachTabCarouselComponent(
            viewAllTapAction: () {
              BlocProvider.of<CoachIntroductionVideoBloc>(context).pauseVideoForNavigation();
              Navigator.pushNamed(context, routeLabels[RouteEnum.coachRecommendedContentGallery],
                  arguments: {'recommendedContent': recommendedMovements, 'titleForAppBar': OlukoLocalizations.of(context).find('recommendedMovements')});
            },
            contentForCarousel: recommendedMovements
                .map((recommendedMovement) => CoachCarouselContent(
                    contentImage: recommendedMovement.contentImage,
                    titleForContent: recommendedMovement.contentTitle,
                    onTapContent: () =>
                        Navigator.pushNamed(context, routeLabels[RouteEnum.movementIntro], arguments: {'movement': recommendedMovement.movementContent})))
                .toList(),
            titleForCarousel: OlukoLocalizations.of(context).find('recommendedMovements'),
            heightForCarousel: heightForVideoContent)
        : const SizedBox.shrink();
  }

  Widget _getRecommendedVideos(BuildContext context) {
    List<RecommendationMedia> recommendedVideos = CoachHelperFunctions.getRecommendedVideosContent(_coachRecommendationList);
    return recommendedVideos.isNotEmpty
        ? coachTabCarouselComponent(
            viewAllTapAction: () => Navigator.pushNamed(context, routeLabels[RouteEnum.coachRecommendedContentGallery],
                arguments: {'recommendedVideoContent': recommendedVideos, 'titleForAppBar': OlukoLocalizations.get(context, 'recommendedVideos')}),
            contentForCarousel: recommendedVideos
                .map((recommendedVideo) => CoachCarouselContent(
                      contentImage: recommendedVideo.video.thumbUrl,
                      titleForContent: recommendedVideo.title,
                      onTapContent: () => Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
                        'videoUrl': VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: recommendedVideo.videoHls, videoUrl: recommendedVideo.video.url),
                        'aspectRatio': recommendedVideo.video.aspectRatio,
                        'titleForContent': OlukoLocalizations.get(context, 'recommendedVideos')
                      }),
                    ))
                .toList(),
            titleForCarousel: OlukoLocalizations.of(context).find('recommendedVideos'),
            heightForCarousel: heightForVideoContent)
        : const SizedBox.shrink();
  }

  Widget _getMessageVideos(BuildContext context) {
    return _coachVideoMessageList.isNotEmpty
        ? coachTabCarouselComponent(
            viewAllTapAction: () =>
                Navigator.pushNamed(context, routeLabels[RouteEnum.mentoredVideos], arguments: {'coachVideoMessages': _coachVideoMessageList}),
            contentForCarousel: _coachVideoMessageList
                .map((coachVideoMessage) => CoachCarouselContent(
                      contentImage: coachVideoMessage.video.thumbUrl,
                      titleForContent: coachVideoMessage.video.name,
                      onTapContent: () => Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
                        'videoUrl': VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: coachVideoMessage.videoHls, videoUrl: coachVideoMessage.video.url),
                        'aspectRatio': coachVideoMessage.video.aspectRatio,
                        'titleForContent': OlukoLocalizations.get(context, 'coachMessageVideo')
                      }),
                    ))
                .toList(),
            titleForCarousel: OlukoLocalizations.get(context, 'coachMessageVideo'),
            heightForCarousel: heightForVideoContent)
        : const SizedBox.shrink();
  }

  Widget _getSendVideos(BuildContext context) {
    return _sentVideosList.isNotEmpty
        ? coachTabCarouselComponent(
            viewAllTapAction: () => Navigator.pushNamed(context, routeLabels[RouteEnum.sentVideos], arguments: {'sentVideosContent': _sentVideosList}),
            contentForCarousel: _sentVideosList
                .map((sentVideo) => CoachCarouselContent(
                      contentImage: sentVideo.video.thumbUrl,
                      titleForContent: sentVideo.segmentName ?? sentVideo.segmentId,
                      onTapContent: () => Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
                        'videoUrl': sentVideo.video.url,
                        'aspectRatio': sentVideo.video.aspectRatio,
                        'titleForContent': OlukoLocalizations.get(context, 'sentVideos')
                      }),
                    ))
                .toList(),
            titleForCarousel: OlukoLocalizations.get(context, 'sentVideos'),
            heightForCarousel: heightForVideoContent)
        : const SizedBox.shrink();
  }

  Widget _getMentoredVideos(BuildContext context) {
    return _annotationVideosList.isNotEmpty
        ? coachTabCarouselComponent(
            viewAllTapAction: () => Navigator.pushNamed(context, routeLabels[RouteEnum.mentoredVideos], arguments: {'coachAnnotation': _annotationVideosList}),
            contentForCarousel: _annotationVideosList
                .map((annotation) => CoachCarouselContent(
                      contentImage: annotation.video.thumbUrl,
                      titleForContent: annotation.id == _defaultIntroductionVideoId
                          ? OlukoLocalizations.get(context, 'introductionVideo')
                          : annotation.segmentName ?? annotation.segmentSubmissionId,
                      onTapContent: () => Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
                        'videoUrl': VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: annotation.videoHLS, videoUrl: annotation.video.url),
                        'aspectRatio': annotation.video.aspectRatio,
                        'titleForContent': OlukoLocalizations.get(context, 'annotatedVideos')
                      }),
                    ))
                .toList(),
            titleForCarousel: OlukoLocalizations.get(context, 'annotatedVideos'),
            heightForCarousel: heightForVideoContent)
        : const SizedBox.shrink();
  }

  void _pendingReviewProccess() => _sentVideosList.forEach((sentVideo) {
        segmentsWithReview = CoachHelperFunctions.checkPendingReviewsForSentVideos(
            sentVideo: sentVideo, annotationVideosContent: _annotationVideosList, segmentsWithReview: segmentsWithReview);
      });

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

  Widget coachTabCarouselComponent(
      {@required List<Widget> contentForCarousel, @required String titleForCarousel, @required double heightForCarousel, Function() viewAllTapAction}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: CoachTabHorizontalCarousel(
        width: ScreenUtils.width(context),
        height: heightForCarousel,
        optionLabel: OlukoLocalizations.get(context, 'seeAll'),
        title: titleForCarousel,
        onOptionTap: viewAllTapAction,
        children: contentForCarousel,
      ),
    );
  }

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
    if (state is CourseEnrollmentsByUserStreamSuccess) {
      _courseEnrollmentList = state.courseEnrollments;
    }
  }

  void _coachAssignmentBuilderActions({@required CoachAssignmentState state}) {
    if (state is CoachAssignmentResponse) {
      coachAssignment = state.coachAssignmentResponse;
      _welcomeVideoProccess(state);
    }
  }
}
