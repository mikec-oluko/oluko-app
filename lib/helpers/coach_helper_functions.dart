import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oluko_app/helpers/coach_notification_content.dart';
import 'package:oluko_app/helpers/coach_personalized_video.dart';
import 'package:oluko_app/helpers/coach_timeline_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/coach_media_message.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/coach_timeline_item.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/ui/components/coach_content_preview_content.dart';
import 'package:oluko_app/ui/components/coach_content_section_card.dart';
import 'package:oluko_app/ui/components/coach_notification_panel_content_card.dart';
import 'package:oluko_app/ui/components/coach_personalized_video.dart';
import 'package:oluko_app/utils/oluko_localizations.dart';
import 'coach_recommendation_default.dart';

class CoachHelperFunctions {
  static Annotation createWelcomeVideoFromCoachAssignment({CoachAssignment coachAssignment, String userId, String defaultIntroVideoId}) {
    if (coachAssignment.videoHLS != null ? true : (coachAssignment.video?.url != null ? true : coachAssignment.introductionVideo != null)) {
      return coachAssignment.userId == userId
          ? Annotation(
              coachId: coachAssignment.coachId,
              userId: coachAssignment.userId,
              id: defaultIntroVideoId,
              favorite: coachAssignment.isFavorite,
              createdAt: coachAssignment.createdAt ?? Timestamp.now(),
              video: Video(
                url: coachAssignment.videoHLS ?? (coachAssignment.video != null ? coachAssignment.video.url : null),
                aspectRatio: coachAssignment.video != null ? coachAssignment.video.aspectRatio ?? 0.60 : 0.60,
                thumbUrl: coachAssignment.video != null ? coachAssignment.video.thumbUrl ?? null : null,
              ),
              videoHLS: coachAssignment.videoHLS ??
                  (coachAssignment.video != null ? coachAssignment.video.url : coachAssignment.introductionVideo),
            )
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
          annotationVideosContent[annotationVideosContent.indexWhere((element) => element.id == updatedOrNewAnnotation.id)] =
              updatedOrNewAnnotation;
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
        List<CoachRecommendationDefault> repeatedRecommendation = coachRecommendationList
            .where((element) => element.coachRecommendation.id == updatedOrNewRecommedation.coachRecommendation.id)
            .toList();
        if (repeatedRecommendation.isEmpty) {
          coachRecommendationList.add(updatedOrNewRecommedation);
        } else {
          if (repeatedRecommendation.first != updatedOrNewRecommedation) {
            coachRecommendationList[coachRecommendationList
                    .indexWhere((element) => element.coachRecommendation.id == updatedOrNewRecommedation.coachRecommendation.id)] =
                updatedOrNewRecommedation;
          }
        }
      });
    }
    return coachRecommendationList;
  }

  static List<CoachTimelineItem> checkTimelineItemsUpdate(
      List<CoachTimelineItem> updatedTimelineItems, List<CoachTimelineItem> actualTimelineContent) {
    updatedTimelineItems.forEach((updatedTimelineItem) {
      List<CoachTimelineItem> repeatedTimelineItem =
          actualTimelineContent.where((element) => element.contentName == updatedTimelineItem.contentName).toList();
      if (repeatedTimelineItem.isEmpty) {
        actualTimelineContent.add(updatedTimelineItem);
      }
    });
    return actualTimelineContent;
  }

  static List<CoachRecommendationDefault> getRecommendedContentByType(List<CoachRecommendationDefault> coachRecommendations,
      TimelineInteractionType contentTypeRequired, List<CoachRecommendationDefault> listToFill) {
    for (CoachRecommendationDefault recommendation in coachRecommendations) {
      if (recommendation.contentType == contentTypeRequired) {
        listToFill.add(recommendation);
      }
    }
    return listToFill;
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

  static Widget sentVideosSection(
      {BuildContext context, List<SegmentSubmission> sentVideosContent, bool introductionCompleted, Function onNavigation}) {
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
            createdAt: coachMessage.createdAt,
            videoContent: coachMessage.video,
            videoHls: coachMessage.videoHls,
            videoMessageContent: coachMessage);
        if (personalizedContent.isNotEmpty) {
          if (personalizedContent
              .where((content) => content.videoMessageContent != null
                  ? content.videoMessageContent.id == newPersonalizedVideo.videoMessageContent.id
                  : false)
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
              .where((content) =>
                  content.annotationContent != null ? content.annotationContent.id == newPersonalizedVideo.annotationContent.id : false)
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
}
