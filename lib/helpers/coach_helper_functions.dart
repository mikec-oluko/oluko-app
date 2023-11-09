import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_assignment_bloc.dart';
import 'package:oluko_app/blocs/coach/coach_introduction_video_bloc.dart';
import 'package:oluko_app/helpers/coach_content_for_timeline_panel.dart';
import 'package:oluko_app/helpers/coach_notification_content.dart';
import 'package:oluko_app/helpers/coach_personalized_video.dart';
import 'package:oluko_app/helpers/coach_timeline_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/helpers/video_player_helper.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/assessment.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/coach_media_message.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/coach_timeline_item.dart';
import 'package:oluko_app/models/recommendation_media.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/models/user_response.dart';
import 'package:oluko_app/routes.dart';
import 'package:oluko_app/ui/components/coach_content_preview_content.dart';
import 'package:oluko_app/ui/components/coach_content_section_card.dart';
import 'package:oluko_app/ui/components/coach_notification_panel_content_card.dart';
import 'package:oluko_app/ui/components/coach_notification_video_card.dart';
import 'package:oluko_app/ui/components/coach_personalized_video.dart';
import 'package:oluko_app/ui/components/coach_recommended_content_preview_stack.dart';
import 'package:oluko_app/ui/newDesignComponents/coach_carousel_content.dart';
import 'package:oluko_app/ui/newDesignComponents/coach_horizontal_carousel.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'package:oluko_app/utils/screen_utils.dart';
import 'coach_recommendation_default.dart';

class CoachHelperFunctions {
  static const double heightForVideoContent = 160;
  static const double heightForCardContent = 240;
  static Annotation createWelcomeVideoFromCoachAssignment({CoachAssignment coachAssignment, String userId, String defaultIntroVideoId}) {
    if (coachAssignment.videoHLS != null ? true : (coachAssignment.video?.url != null ? true : coachAssignment.introductionVideo != null)) {
      return coachAssignment.userId == userId
          ? Annotation(
              coachId: coachAssignment.coachId,
              userId: coachAssignment.userId,
              id: defaultIntroVideoId,
              favorite: coachAssignment.isFavorite,
              createdAt: coachAssignment.welcomeVideoUploadedAt ?? coachAssignment.createdAt ?? Timestamp.now(),
              video: Video(
                url: coachAssignment.videoHLS ?? coachAssignment.video?.url,
                aspectRatio: coachAssignment.video != null ? coachAssignment.video.aspectRatio ?? 0.60 : 0.60,
                thumbUrl: coachAssignment.video != null ? coachAssignment.video.thumbUrl ?? null : null,
              ),
              videoHLS: coachAssignment.videoHLS ?? (coachAssignment.video != null ? coachAssignment.video.url : coachAssignment.introductionVideo),
              notificationViewed: coachAssignment.introductionCompleted)
          : null;
    }
    return null;
  }

  static List<Annotation> checkAnnotationUpdate(List<Annotation> annotationUpdateListofContent, List<Annotation> annotationVideosContent) {
    annotationUpdateListofContent.forEach((updatedOrNewAnnotation) {
      List<Annotation> repeatedAnnotation = annotationVideosContent.where((element) => element.id == updatedOrNewAnnotation.id).toList();
      if (repeatedAnnotation.isEmpty) {
        annotationVideosContent.add(updatedOrNewAnnotation);
      } else {
        if (repeatedAnnotation.first != updatedOrNewAnnotation) {
          annotationVideosContent[annotationVideosContent.indexWhere((element) => element.id == updatedOrNewAnnotation.id)] = updatedOrNewAnnotation;
        }
      }
    });

    return annotationVideosContent;
  }

  static List<SegmentSubmission> checkPendingReviewsForSentVideos(
      {SegmentSubmission sentVideo, List<Annotation> annotationVideosContent, List<SegmentSubmission> segmentsWithReview}) {
    annotationVideosContent.forEach((annotation) {
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
    return segmentsWithReview;
  }

  static List<CoachRequest> checkCoachRequestUpdate(List<CoachRequest> coachRequestContent, List<CoachRequest> coachRequestList) {
    coachRequestContent.forEach((coachRequestUpdatedItem) {
      List<CoachRequest> repeatedCoachRequest = coachRequestList.where((element) => element.id == coachRequestUpdatedItem.id).toList();
      if (repeatedCoachRequest.isEmpty) {
        coachRequestList.add(coachRequestUpdatedItem);
      } else {
        if (repeatedCoachRequest.first != coachRequestUpdatedItem) {
          coachRequestList[coachRequestList.indexWhere((element) => element.id == coachRequestUpdatedItem.id)] = coachRequestUpdatedItem;
        }
      }
    });
    return coachRequestList;
  }

  static List<CoachRecommendationDefault> checkRecommendationUpdate(
      List<CoachRecommendationDefault> coachRecommendationContent, List<CoachRecommendationDefault> coachRecommendationList) {
    if (coachRecommendationContent.isNotEmpty) {
      coachRecommendationContent.forEach((updatedOrNewRecommedation) {
        List<CoachRecommendationDefault> repeatedRecommendation =
            coachRecommendationList.where((element) => element.coachRecommendation.id == updatedOrNewRecommedation.coachRecommendation.id).toList();
        if (repeatedRecommendation.isEmpty) {
          coachRecommendationList.add(updatedOrNewRecommedation);
        } else {
          if (repeatedRecommendation.first != updatedOrNewRecommedation) {
            coachRecommendationList[coachRecommendationList
                .indexWhere((element) => element.coachRecommendation.id == updatedOrNewRecommedation.coachRecommendation.id)] = updatedOrNewRecommedation;
          }
        }
      });
    }
    return coachRecommendationList;
  }

  static List<CoachTimelineItem> checkTimelineItemsUpdate(List<CoachTimelineItem> updatedTimelineItems, List<CoachTimelineItem> actualTimelineContent) {
    updatedTimelineItems.forEach((updatedTimelineItem) {
      List<CoachTimelineItem> repeatedTimelineItem = actualTimelineContent.where((element) => element.contentName == updatedTimelineItem.contentName).toList();
      if (repeatedTimelineItem.isEmpty) {
        actualTimelineContent.add(updatedTimelineItem);
      }
    });
    return actualTimelineContent;
  }

  static List<CoachRecommendationDefault> getRecommendedContentByType(
      List<CoachRecommendationDefault> coachRecommendations, TimelineInteractionType contentTypeRequired, List<CoachRecommendationDefault> listToFill,
      {bool onlyContent = false}) {
    List<CoachRecommendationDefault> recommendedContent = [];

    for (CoachRecommendationDefault recommendation in coachRecommendations) {
      if (recommendation.contentType == contentTypeRequired) {
        onlyContent ? recommendedContent.add(recommendation) : listToFill.add(recommendation);
      }
    }
    return onlyContent ? recommendedContent : listToFill;
  }

  static List<Widget> notificationsWidget(
      List<CoachNotificationContent> contentForNotificationPanel, List<Widget> carouselContent, String coachId, String userId) {
    contentForNotificationPanel.forEach((notificationContent) {
      if (notificationContent.contentType != TimelineInteractionType.segment) {
        carouselContent.add(CoachNotificationPanelContentCard(
          content: notificationContent,
          coachId: coachId,
          userId: userId,
        ));
      }
    });
    return carouselContent;
  }

  static Widget sentVideosSection({BuildContext context, List<SegmentSubmission> sentVideosContent, bool introductionCompleted, Function onNavigation}) {
    return sentVideosContent != null && sentVideosContent.isNotEmpty
        ? CoachContentPreviewComponent(
            contentFor: CoachContentSection.sentVideos,
            titleForSection: OlukoLocalizations.get(context, 'sentVideos'),
            segmentSubmissionContent: sentVideosContent,
            onNavigation: () => !introductionCompleted ? onNavigation() : () {},
          )
        : CoachContentSectionCard(
            title: OlukoLocalizations.get(context, 'sentVideos'),
          );
  }

  static Widget mentoredVideosSection(
      {BuildContext context,
      List<Annotation> annotation,
      @required List<CoachMediaMessage> coachMediaMessages,
      bool introFinished,
      Function onNavigation,
      bool isForCarousel}) {
    return annotation != null && annotation.isNotEmpty
        ? CoachContentPreviewComponent(
            contentFor: CoachContentSection.mentoredVideos,
            titleForSection: OlukoLocalizations.get(context, 'personalizedVideos'),
            coachAnnotationContent: annotation,
            coachMediaMessages: coachMediaMessages,
            onNavigation: () => !introFinished ? onNavigation() : () {})
        : CoachContentSectionCard(title: OlukoLocalizations.get(context, 'personalizedVideos'));
  }

  static List<CoachPersonalizedVideo> createPersonalizedVideoFromContent(
      {@required List<Annotation> mentoredVideos, @required List<CoachMediaMessage> videoMessages}) {
    List<CoachPersonalizedVideo> personalizedContent = [];
    try {
      _mentoredVideosToPersonalizedVideos(mentoredVideos, personalizedContent);
      _videoMessageToPersonalizedVideo(videoMessages, personalizedContent);
    } catch (e) {}

    return personalizedContent;
  }

  static void _videoMessageToPersonalizedVideo(List<CoachMediaMessage> videoMessages, List<CoachPersonalizedVideo> personalizedContent) {
    if (videoMessages != null && videoMessages.isNotEmpty) {
      videoMessages.forEach((coachMessage) {
        CoachPersonalizedVideo newPersonalizedVideo = CoachPersonalizedVideo(
            createdAt: coachMessage.createdAt, videoContent: coachMessage.video, videoHls: coachMessage.videoHls, videoMessageContent: coachMessage);
        if (personalizedContent.isNotEmpty) {
          if (personalizedContent
              .where((content) => content.videoMessageContent != null ? content.videoMessageContent.id == newPersonalizedVideo.videoMessageContent.id : false)
              .toList()
              .isEmpty) {
            personalizedContent.add(newPersonalizedVideo);
          }
        } else {
          personalizedContent.add(newPersonalizedVideo);
        }
      });
    }
  }

  static void _mentoredVideosToPersonalizedVideos(List<Annotation> mentoredVideos, List<CoachPersonalizedVideo> personalizedContent) {
    if (mentoredVideos != null && mentoredVideos.isNotEmpty) {
      mentoredVideos.forEach((annotation) {
        CoachPersonalizedVideo newPersonalizedVideo = CoachPersonalizedVideo(
            createdAt: annotation.createdAt, videoContent: annotation.video, videoHls: annotation.videoHLS, annotationContent: annotation);
        if (personalizedContent.isNotEmpty) {
          if (personalizedContent
              .where((content) => content.annotationContent != null ? content.annotationContent.id == newPersonalizedVideo.annotationContent.id : false)
              .toList()
              .isEmpty) {
            personalizedContent.add(newPersonalizedVideo);
          }
        } else {
          personalizedContent.add(newPersonalizedVideo);
        }
      });
    }
  }

  static List<Widget> notificationPanel(
      {@required BuildContext context,
      @required CoachAssignment coachAssignment,
      @required Assessment assessment,
      @required List<CoachRecommendationDefault> coachRecommendations,
      @required List<Annotation> annotationVideos,
      @required List<CoachMediaMessage> coachVideoMessages,
      @required String welcomeVideoUrl}) {
    List<Widget> carouselContent = [];
    List<CoachNotificationContent> contentForNotificationPanel = [];

    if (!coachAssignment.welcomeVideoSeen) {
      carouselContent.add(CoachNotificationVideoCard(
        cardImage: assessment.videoThumbnail,
        fileType: CoachFileTypeEnum.welcomeVideo,
        onCloseCard: () => BlocProvider.of<CoachAssignmentBloc>(context).welcomeVideoAsSeen(coachAssignment),
        onOpenCard: () {
          Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo],
              arguments: {'videoUrl': welcomeVideoUrl, 'titleForContent': OlukoLocalizations.of(context).find('welcomeVideo')});
          BlocProvider.of<CoachAssignmentBloc>(context).welcomeVideoAsSeen(coachAssignment);
        },
      ));
    }

    if (coachRecommendations.isNotEmpty) {
      contentForNotificationPanel = CoachTimelineFunctions.coachRecommendationsForInteraction(coachRecommendations: coachRecommendations, context: context);
      carouselContent = CoachHelperFunctions.notificationsWidget(contentForNotificationPanel, carouselContent, coachAssignment.coachId, coachAssignment.userId);
    }

    if (annotationVideos.isNotEmpty) {
      contentForNotificationPanel = CoachTimelineFunctions.mentoredVideoForInteraction(annotationContent: annotationVideos, context: context);
      carouselContent = CoachHelperFunctions.notificationsWidget(contentForNotificationPanel, carouselContent, coachAssignment.coachId, coachAssignment.userId);
    }

    if (coachVideoMessages.isNotEmpty) {
      contentForNotificationPanel = CoachTimelineFunctions.messageVideoForInteraction(messageVideoContent: coachVideoMessages, context: context);
      carouselContent = CoachHelperFunctions.notificationsWidget(contentForNotificationPanel, carouselContent, coachAssignment.coachId, coachAssignment.userId);
    }
    return carouselContent;
  }

  static List<Annotation> addIntroVideoOnAnnotations(List<Annotation> annotationVideosContent, Annotation introductionVideo) {
    const String _defaultIntroductionVideoId = 'introVideo';
    if (annotationVideosContent != null && introductionVideo != null) {
      if (annotationVideosContent.where((annotation) => annotation.id == _defaultIntroductionVideoId).toList().isEmpty) {
        annotationVideosContent.insert(0, introductionVideo);
      }
    }
    return annotationVideosContent;
  }

  static List<RecommendationMedia> getRecommendedVideosContent(List<CoachRecommendationDefault> coachRecommendations) {
    List<RecommendationMedia> recommendationVideos = [];
    for (CoachRecommendationDefault recommendation in coachRecommendations) {
      if (recommendation.contentType == TimelineInteractionType.recommendedVideo) {
        RecommendationMedia _mediaUpdatedDateOfCreation = recommendation.recommendationMedia;
        _mediaUpdatedDateOfCreation.createdAt = recommendation.createdAt;
        recommendationVideos.add(_mediaUpdatedDateOfCreation);
      }
    }
    return recommendationVideos;
  }

  static Widget recommendedContentImageStack(
      {BuildContext context,
      List<CoachRecommendationDefault> coachRecommendations,
      Function(List<CoachRecommendationDefault> recommendationList) onTap,
      TimelineInteractionType contentType,
      bool isForCarousel}) {
    Widget widgetToReturn = const SizedBox.shrink();
    List<CoachRecommendationDefault> movementsRecommended = [];
    List<CoachRecommendationDefault> coursesRecommended = [];
    if (coachRecommendations != null && coachRecommendations.isNotEmpty) {
      if (contentType == TimelineInteractionType.movement) {
        widgetToReturn = CoachContentSectionCard(title: OlukoLocalizations.of(context).find('recommendedMovements'));
        movementsRecommended = CoachHelperFunctions.getRecommendedContentByType(coachRecommendations, TimelineInteractionType.movement, movementsRecommended);
        if (movementsRecommended.isNotEmpty) {
          widgetToReturn = GestureDetector(
              onTap: () => onTap(movementsRecommended),
              child: CoachRecommendedContentPreviewStack(
                recommendationsList: movementsRecommended,
                titleForSection: OlukoLocalizations.of(context).find('recommendedMovements'),
              ));
        }
      }
      if (contentType == TimelineInteractionType.course) {
        widgetToReturn = CoachContentSectionCard(title: OlukoLocalizations.of(context).find('recommendedCourses'));
        coursesRecommended = CoachHelperFunctions.getRecommendedContentByType(coachRecommendations, TimelineInteractionType.course, coursesRecommended);
        if (coursesRecommended.isNotEmpty) {
          widgetToReturn = GestureDetector(
              onTap: () => onTap(coursesRecommended),
              child: CoachRecommendedContentPreviewStack(
                recommendationsList: coursesRecommended,
                titleForSection: OlukoLocalizations.of(context).find('recommendedCourses'),
              ));
        }
      }
    }
    return widgetToReturn;
  }

  static Widget getRecommendedMovements(BuildContext context, List<CoachRecommendationDefault> coachRecommendations) {
    final List<CoachRecommendationDefault> recommendedMovements =
        getRecommendedContentByType(coachRecommendations, TimelineInteractionType.movement, [], onlyContent: true);
    return recommendedMovements.isNotEmpty
        ? coachTabCarouselComponent(context, viewAllTapAction: () {
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

  static Widget getRecommendedCourses(BuildContext context, List<CoachRecommendationDefault> coachRecommendations) {
    final List<CoachRecommendationDefault> recommededCourses =
        CoachHelperFunctions.getRecommendedContentByType(coachRecommendations, TimelineInteractionType.course, [], onlyContent: true);
    return recommededCourses.isNotEmpty
        ? coachTabCarouselComponent(context, viewAllTapAction: () {
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

  static Widget getMentoredVideos(BuildContext context, List<Annotation> annotationVideosList, UserResponse currentAuthUser) {
    String _defaultIntroductionVideoId = '';
    return annotationVideosList.isNotEmpty
        ? coachTabCarouselComponent(context,
            viewAllTapAction: () => Navigator.pushNamed(context, routeLabels[RouteEnum.mentoredVideos], arguments: {'coachAnnotation': annotationVideosList}),
            contentForCarousel: annotationVideosList
                .map((annotation) => CoachCarouselContent(
                      contentImage: annotation.video.thumbUrl,
                      titleForContent: annotation.id == _defaultIntroductionVideoId
                          ? OlukoLocalizations.get(context, 'introductionVideo')
                          : annotation.segmentName ?? OlukoLocalizations.get(context, 'voiceAnnotation'),
                      onTapContent: () => Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
                        'videoUrl': VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: annotation.videoHLS, videoUrl: annotation.video.url),
                        'aspectRatio': annotation.video.aspectRatio,
                        'titleForContent': OlukoLocalizations.get(context, 'annotatedVideos'),
                        'segmentSubmissionId': annotation.segmentSubmissionId,
                        'currentUser': currentAuthUser
                      }),
                    ))
                .toList(),
            titleForCarousel: OlukoLocalizations.get(context, 'annotatedVideos'),
            heightForCarousel: heightForVideoContent)
        : const SizedBox.shrink();
  }

  static Widget getSentVideos(BuildContext context, List<SegmentSubmission> sentVideosList) {
    return sentVideosList.isNotEmpty
        ? coachTabCarouselComponent(context,
            viewAllTapAction: () => Navigator.pushNamed(context, routeLabels[RouteEnum.sentVideos], arguments: {'sentVideosContent': sentVideosList}),
            contentForCarousel: sentVideosList
                .map((sentVideo) => CoachCarouselContent(
                      contentImage: sentVideo.video.thumbUrl,
                      titleForContent: sentVideo.segmentName ?? sentVideo.segmentId,
                      onTapContent: () => Navigator.pushNamed(context, routeLabels[RouteEnum.coachShowVideo], arguments: {
                        'videoUrl': VideoPlayerHelper.getVideoFromSourceActive(videoHlsUrl: sentVideo.videoHls, videoUrl: sentVideo.video.url),
                        'aspectRatio': sentVideo.video.aspectRatio,
                        'titleForContent': OlukoLocalizations.get(context, 'sentVideos')
                      }),
                    ))
                .toList(),
            titleForCarousel: OlukoLocalizations.get(context, 'sentVideos'),
            heightForCarousel: heightForVideoContent)
        : const SizedBox.shrink();
  }

  static Widget getMessageVideos(BuildContext context, List<CoachMediaMessage> coachVideoMessageList) {
    return coachVideoMessageList.isNotEmpty
        ? coachTabCarouselComponent(context,
            viewAllTapAction: () =>
                Navigator.pushNamed(context, routeLabels[RouteEnum.mentoredVideos], arguments: {'coachVideoMessages': coachVideoMessageList}),
            contentForCarousel: coachVideoMessageList
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

  static Widget getRecommendedVideos(BuildContext context, List<CoachRecommendationDefault> coachRecommendationList) {
    List<RecommendationMedia> recommendedVideos = getRecommendedVideosContent(coachRecommendationList);
    return recommendedVideos.isNotEmpty
        ? coachTabCarouselComponent(context,
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

  static Widget coachTabCarouselComponent(BuildContext context,
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
}
