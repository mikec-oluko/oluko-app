import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/coach_timeline_item.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/submodels/video.dart';

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
                url: coachAssignment.videoHLS ??
                    (coachAssignment.video != null ? coachAssignment.video.url : coachAssignment.introductionVideo),
                aspectRatio: coachAssignment.video != null ? coachAssignment.video.aspectRatio ?? 0.60 : 0.60,
                thumbUrl: coachAssignment.video != null ? coachAssignment.video.thumbUrl ?? null : null,
              ),
              videoHLS: coachAssignment.videoHLS ??
                  (coachAssignment.video != null ? coachAssignment.video.url : coachAssignment.introductionVideo),
            )
          : null;
    }
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
}
