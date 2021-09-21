import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
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
        .collection('coachAssignment')
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
          .collection('coachAssignment')
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
}
