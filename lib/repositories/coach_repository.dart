import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/helpers/coach_recommendation_default.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/annotation.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/coach_media_message.dart';
import 'package:oluko_app/models/coach_timeline_item.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/recommendation.dart';
import 'package:oluko_app/models/task.dart';
import 'package:oluko_app/models/task_submission.dart';
import 'package:oluko_app/models/recommendation_media.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CoachRepository {
  FirebaseFirestore firestoreInstance;
  final String introductionVideoDefaultId = 'introVideo';
  CoachRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  CoachRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  Future<CoachAssignment> getCoachAssignmentByUserId(String userId) async {
    final QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('coachAssignments')
        .where('id', isEqualTo: userId)
        .get();
    if (docRef.docs == null || docRef.docs.isEmpty) {
      return null;
    }
    final response = docRef.docs[0].data() as Map<String, dynamic>;
    final coachAssignmentResponse = CoachAssignment.fromJson(response);
    return coachAssignmentResponse;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getCoachAssignmentByUserIdStream(String userId) {
    Stream<QuerySnapshot<Map<String, dynamic>>> coachAssignemntStream = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('coachAssignments')
        .where('id', isEqualTo: userId)
        .snapshots();
    return coachAssignemntStream;
  }

  Future<CoachAssignment> welcomeVideoMarkAsSeen(CoachAssignment coachAssignment) async {
    try {
      coachAssignment.welcomeVideoSeen = true;
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getString('projectId'))
          .collection('coachAssignments')
          .doc(coachAssignment.userId)
          .set(coachAssignment.toJson());
      return coachAssignment;
    } on Exception catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<CoachAssignment> introductionVideoMarkAsSeen(String userId) async {
    CoachAssignment coachAssignment = await getCoachAssignmentByUserId(userId);
    coachAssignment.introductionCompleted = true;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('coachAssignments')
        .doc(coachAssignment.id);
    reference.set(coachAssignment.toJson());
    return coachAssignment;
  }

  Future<CoachAssignment> updateIntroductionVideoFavoriteStatus(String userId) async {
    try {
      CoachAssignment coachAssignment = await getCoachAssignmentByUserId(userId);

      coachAssignment.isFavorite = !coachAssignment.isFavorite;

      await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getString('projectId'))
          .collection('coachAssignments')
          .doc(coachAssignment.userId)
          .set(coachAssignment.toJson());
      return coachAssignment;
    } on Exception catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<List<SegmentSubmission>> getSegmentsSubmitted(String userId) async {
    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getString('projectId'))
          .collection('segmentSubmissions')
          .where('user_id', isEqualTo: userId)
          .get();
      List<SegmentSubmission> contentUploaded = [];
      docRef.docs.forEach((doc) {
        final Map<String, dynamic> content = doc.data() as Map<String, dynamic>;
        contentUploaded.add(SegmentSubmission.fromJson(content));
      });
      return contentUploaded;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<List<SegmentSubmission>> setSegmentSubmissionAsFavorite(
      {SegmentSubmission segmentSubmittedToUpdate, List<SegmentSubmission> currentSentVideosContent}) async {
    try {
      segmentSubmittedToUpdate.favorite = !segmentSubmittedToUpdate.favorite;
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getString('projectId'))
          .collection('segmentSubmissions')
          .doc(segmentSubmittedToUpdate.id)
          .set(segmentSubmittedToUpdate.toJson());

      currentSentVideosContent.forEach((sentVideo) => sentVideo.id == segmentSubmittedToUpdate.id ? sentVideo = segmentSubmittedToUpdate : null);

      return currentSentVideosContent;
    } on Exception catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  setAnnotationAsFavorite(Annotation coachAnnotation) async {
    try {
      coachAnnotation.favorite = !coachAnnotation.favorite;

      if (coachAnnotation.id == introductionVideoDefaultId) {
        updateIntroductionVideoFavoriteStatus(coachAnnotation.userId);
      } else {
        await FirebaseFirestore.instance
            .collection('projects')
            .doc(GlobalConfiguration().getString('projectId'))
            .collection('coachStatistics')
            .doc(coachAnnotation.createdBy)
            .collection('annotations')
            .doc(coachAnnotation.id)
            .set(coachAnnotation.toJson());
      }
    } on Exception catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAnnotationSubscription(String userId, String coachId) {
    Stream<QuerySnapshot<Map<String, dynamic>>> annotationStream = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('coachStatistics')
        .doc(coachId)
        .collection('annotations')
        .where('user_id', isEqualTo: userId)
        .snapshots();
    return annotationStream;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRecommendationSubscription(String userId, String coachId) {
    Stream<QuerySnapshot<Map<String, dynamic>>> recommendationStream = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('recommendations')
        .where('destination_user_id', isEqualTo: userId)
        .where('origin_user_id', isEqualTo: coachId)
        .where('is_deleted', isEqualTo: false)
        .snapshots();
    return recommendationStream;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTimelineItemsSubscription(String userId) {
    Stream<QuerySnapshot<Map<String, dynamic>>> timelineItemsStream = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('users')
        .doc(userId)
        .collection('interactionTimelineItems')
        .snapshots();
    return timelineItemsStream;
  }

  Future<void> updateMentoredVideoNotificationStatus(String coachId, String annotationId, bool notificationValue) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('coachStatistics')
        .doc(coachId)
        .collection('annotations')
        .doc(annotationId);
    reference.update({'notification_viewed': notificationValue});
  }

  Future<List<CoachTimelineItem>> getTimelineContent(String userId) async {
    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getString('projectId'))
          .collection('users')
          .doc(userId)
          .collection('interactionTimelineItems')
          .get();

      List<CoachTimelineItem> coachTimelineContent = [];
      docRef.docs.forEach((doc) {
        final Map<String, dynamic> content = doc.data() as Map<String, dynamic>;
        coachTimelineContent.add(CoachTimelineItem.fromJson(content));
      });
      return coachTimelineContent;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<List<CoachTimelineItem>> getTimelineItemsReferenceContent(List<CoachTimelineItem> timelineItemList) async {
    for (CoachTimelineItem timelineItem in timelineItemList) {
      final DocumentSnapshot ds = await timelineItem.contentReference.get();

      switch (timelineItem.contentType) {
        case TimelineInteractionType.course:
          Course courseForItem = Course.fromJson(ds.data() as Map<String, dynamic>);
          timelineItem.contentName = courseForItem.name;
          timelineItem.courseForNavigation = courseForItem;
          timelineItem.contentThumbnail = courseForItem.images.length >= 2 ? courseForItem.images.elementAt(2) as String : timelineItem.contentThumbnail;

          break;
        case TimelineInteractionType.classes:
          break;
        case TimelineInteractionType.segment:
          SegmentSubmission taskSubmitted = SegmentSubmission.fromJson(ds.data() as Map<String, dynamic>);
          timelineItem.contentThumbnail = taskSubmitted.video?.thumbUrl;
          timelineItem.sentVideosForNavigation = [taskSubmitted];
          break;
        case TimelineInteractionType.movement:
          Movement movementForItem = Movement.fromJson(ds.data() as Map<String, dynamic>);
          timelineItem.movementForNavigation = movementForItem;
          timelineItem.contentName = movementForItem.name;
          timelineItem.contentThumbnail = movementForItem.images.length >= 2 ? movementForItem.images.elementAt(2) as String : timelineItem.contentThumbnail;
          break;
        case TimelineInteractionType.mentoredVideo:
          Annotation uploadedAnnotation = Annotation.fromJson(ds.data() as Map<String, dynamic>);
          final DocumentSnapshot segmentSubmitted = await uploadedAnnotation.segmentSubmissionReference.get();
          TaskSubmission taskSubmittedData = TaskSubmission.fromJson(segmentSubmitted.data() as Map<String, dynamic>);
          timelineItem.contentName = taskSubmittedData.video.name;
          timelineItem.mentoredVideosForNavigation = [uploadedAnnotation];
          break;
        case TimelineInteractionType.sentVideo:
          SegmentSubmission uploadedSegment = SegmentSubmission.fromJson(ds.data() as Map<String, dynamic>);
          timelineItem.sentVideosForNavigation = [uploadedSegment];
          break;
        case TimelineInteractionType.recommendedVideo:
          break;
        case TimelineInteractionType.messageVideo:
          CoachMediaMessage coachMediaMessage = CoachMediaMessage.fromJson(ds.data() as Map<String, dynamic>);
          timelineItem.coachMediaMessage = coachMediaMessage;
          timelineItem.contentName = coachMediaMessage.video.name;
          break;
        default:
      }
    }
    return timelineItemList;
  }

  Future<List<Recommendation>> getCoachRecommendationsForUser(String userId, String coachId) async {
    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getString('projectId'))
          .collection('recommendations')
          .where('destination_user_id', isEqualTo: userId)
          .where('origin_user_id', isEqualTo: coachId)
          .get();
      List<Recommendation> coachRecommendations = [];
      docRef.docs.forEach((doc) {
        final Map<String, dynamic> content = doc.data() as Map<String, dynamic>;
        coachRecommendations.add(Recommendation.fromJson(content));
      });
      return coachRecommendations;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> updateRecommendationNotificationStatus(String recommendationId, bool notificationValue) async {
    DocumentReference reference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('recommendations').doc(recommendationId);
    reference.update({'notification_viewed': notificationValue});
  }

  Future<List<CoachRecommendationDefault>> getRecommendationsInfo(List<Recommendation> coachRecommendationContent) async {
    List<CoachRecommendationDefault> coachRecommendations = [];
    for (Recommendation recommendation in coachRecommendationContent) {
      DocumentSnapshot ds = await recommendation.entityReference.get();

      switch (recommendation.entityType) {
        case TimelineInteractionType.course:
          Course courseRecommended = Course.fromJson(ds.data() as Map<String, dynamic>);

          CoachRecommendationDefault recommendationItem = CoachRecommendationDefault(
              coachRecommendation: recommendation,
              contentTitle: courseRecommended.name,
              contentSubtitle: courseRecommended.classes.length.toString(),
              contentDescription: courseRecommended.duration,
              contentImage: courseRecommended.images != null ? courseRecommended.images.elementAt(1) as String : courseRecommended.image,
              contentType: recommendation.entityType,
              createdAt: recommendation.createdAt,
              courseContent: courseRecommended);
          coachRecommendations.add(recommendationItem);
          break;
        case TimelineInteractionType.classes:
          break;
        case TimelineInteractionType.segment:
          break;
        case TimelineInteractionType.movement:
          Movement movementRecommended = Movement.fromJson(ds.data() as Map<String, dynamic>);
          CoachRecommendationDefault recommendationItem = CoachRecommendationDefault(
              coachRecommendation: recommendation,
              contentTitle: movementRecommended.name,
              contentSubtitle: '',
              contentDescription: movementRecommended.description,
              contentImage: movementRecommended.images != null ? movementRecommended.images.elementAt(1) as String : movementRecommended.image,
              contentType: recommendation.entityType,
              createdAt: recommendation.createdAt,
              movementContent: movementRecommended);
          coachRecommendations.add(recommendationItem);
          break;
        case TimelineInteractionType.mentoredVideo:
          break;
        case TimelineInteractionType.sentVideo:
          break;
        case TimelineInteractionType.recommendedVideo:
          RecommendationMedia mediaContentRecommended = RecommendationMedia.fromJson(ds.data() as Map<String, dynamic>);
          CoachRecommendationDefault recommendationItem = CoachRecommendationDefault(
              coachRecommendation: recommendation,
              contentTitle: mediaContentRecommended.title,
              contentSubtitle: '',
              contentDescription: mediaContentRecommended.description,
              contentImage: mediaContentRecommended.video.thumbUrl,
              contentType: recommendation.entityType,
              createdAt: recommendation.createdAt,
              recommendationMedia: mediaContentRecommended);
          coachRecommendations.add(recommendationItem);
          break;
        default:
      }
    }
    return coachRecommendations;
  }
}
