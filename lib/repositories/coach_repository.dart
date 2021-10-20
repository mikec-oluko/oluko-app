import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/helpers/coach_timeline_content.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/annotations.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/coach_timeline_item.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/movement.dart';
import 'package:oluko_app/models/recommendation.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/submodels/course_timeline_submodel.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CoachRepository {
  FirebaseFirestore firestoreInstance;

  CoachRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  CoachRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  Future<CoachAssignment> getCoachAssignmentByUserId(String userId) async {
    final QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
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

  Future<CoachAssignment> updateIntroductionStatus(CoachAssignment coachAssignment) async {
    try {
      coachAssignment.introductionCompleted = true;
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue('projectId'))
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
          .doc(GlobalConfiguration().getValue('projectId'))
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
          .doc(GlobalConfiguration().getValue('projectId'))
          .collection('segmentSubmissions')
          .doc(segmentSubmittedToUpdate.id)
          .set(segmentSubmittedToUpdate.toJson());

      currentSentVideosContent.forEach(
          (sentVideo) => sentVideo.id == segmentSubmittedToUpdate.id ? sentVideo = segmentSubmittedToUpdate : null);

      return currentSentVideosContent;
    } on Exception catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

//TODO:
  Future<List<Annotation>> setAnnotationAsFavorite(
      Annotation coachAnnotation, List<Annotation> actualMentoredVideosContent) async {
    try {
      coachAnnotation.favorite = !coachAnnotation.favorite;
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue('projectId'))
          .collection('coachStatistics')
          .doc(coachAnnotation.coachId)
          .collection('annotations')
          .doc(coachAnnotation.id)
          .set(coachAnnotation.toJson());

      actualMentoredVideosContent.forEach((mentoredVideo) {
        if (mentoredVideo.id == coachAnnotation.id) {
          mentoredVideo = coachAnnotation;
        }
      });
      return actualMentoredVideosContent;
    } on Exception catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<List<Annotation>> getCoachAnnotationsByUserId(String userId, String coachId) async {
    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue('projectId'))
          .collection('coachStatistics')
          .doc(coachId)
          .collection('annotations')
          .where('user_id', isEqualTo: userId)
          .get();
      List<Annotation> coachAnnotations = [];
      docRef.docs.forEach((doc) {
        final Map<String, dynamic> content = doc.data() as Map<String, dynamic>;
        coachAnnotations.add(Annotation.fromJson(content));
      });
      return coachAnnotations;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<List<CoachTimelineItem>> getTimelineContent(String userId) async {
    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue('projectId'))
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

  Future<List<Recommendation>> getCoachRecommendationsForUser(String userId, String coachId) async {
    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue('projectId'))
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

  Future<List<CoachTimelineItem>> getRecommendationsInfo(List<Recommendation> coachRecommendationContent) async {
    List<CoachTimelineItem> recommendationsAsTimelineItems = [];
    // for (Recommendation recommendation in coachRecommendationContent) {
    coachRecommendationContent.forEach((recommendation) async {
      DocumentSnapshot ds = await recommendation.entityReference.get();
      switch (TimelineContentOption.getTimelineOption(recommendation.entityType as int)) {
        case TimelineInteractionType.course:
          Course courseRecommended = Course.fromJson(ds.data() as Map<String, dynamic>);
          CoachTimelineItem recommendedCourseItem = createAnCoachTimelineItem(
              recommendation: recommendation,
              contentDescription: courseRecommended.description,
              contentName: courseRecommended.name,
              contentThumbnail: courseRecommended.image,
              contentType: recommendation.entityType);
          recommendationsAsTimelineItems.add(recommendedCourseItem);
          break;
        case TimelineInteractionType.classes:
          break;
        case TimelineInteractionType.segment:
          break;
        case TimelineInteractionType.movement:
          Movement movementRecommended = Movement.fromJson(ds.data() as Map<String, dynamic>);
          CoachTimelineItem recommendedMovementItem = createAnCoachTimelineItem(
              recommendation: recommendation,
              contentDescription: movementRecommended.description,
              contentName: movementRecommended.name,
              contentThumbnail: movementRecommended.image,
              contentType: recommendation.entityType);
          recommendationsAsTimelineItems.add(recommendedMovementItem);

          break;
        case TimelineInteractionType.mentoredVideo:
          break;
        case TimelineInteractionType.sentVideo:
          break;
        //   break;
        default:
      }
    });

    // }
    return recommendationsAsTimelineItems;
  }

  CoachTimelineItem createAnCoachTimelineItem(
      {Recommendation recommendation,
      String contentDescription,
      String contentName,
      String contentThumbnail,
      num contentType}) {
    CoachTimelineItem newItem = CoachTimelineItem(
        coachId: recommendation.originUserId,
        coachReference: recommendation.originUserReference,
        contentDescription: contentDescription,
        contentName: contentName,
        contentThumbnail: contentThumbnail,
        contentType: contentType,
        course: CourseTimelineSubmodel(id: '0', name: 'all', reference: null),
        id: '0',
        createdAt: recommendation.createdAt);
    return newItem;
  }
  // for (SegmentSubmodel segment in classObj.segments) {
  //   DocumentSnapshot ds = await segment.reference.get();
  //   Segment retrievedSegment =
  //       Segment.fromJson(ds.data() as Map<String, dynamic>);
  //   segments.add(retrievedSegment);
  // }
  // return segments;
  // }
}
