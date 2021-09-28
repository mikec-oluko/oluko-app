import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/annotations.dart';
import 'package:oluko_app/models/coach_assignment.dart';
import 'package:oluko_app/models/segment_submission.dart';
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

  Future<List<Annotation>> setAnnotationAsFavorite(
      Annotation coachAnnotation, List<Annotation> actualMentoredVideosContent) async {
    try {
      coachAnnotation.favorite = !coachAnnotation.favorite;
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue('projectId'))
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

  Future<List<Annotation>> getCoachAnnotationsByUserId(String userId) async {
    try {
      QuerySnapshot docRef = await FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getValue('projectId'))
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
}
