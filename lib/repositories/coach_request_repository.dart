import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/blocs/coach/coach_request_bloc.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/enums/request_status_enum.dart';
import 'package:oluko_app/models/segment_submission.dart';

class CoachRequestRepository {
  FirebaseFirestore firestoreInstance;

  CoachRequestRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  CoachRequestRepository.test({this.firestoreInstance});

  Stream<QuerySnapshot<Map<String, dynamic>>> getCoachRequestSubscription(String userId, String coachId) {
    Stream<QuerySnapshot<Map<String, dynamic>>> coachRequestStream = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('coachAssignments')
        .doc(userId)
        .collection('coachRequests')
        .where('coach_id', isEqualTo: coachId)
        .snapshots();
    return coachRequestStream;
  }

  Future<List<CoachRequest>> get(String userId) async {
    final docRef = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('coachAssignments')
        .doc(userId)
        .collection('coachRequests');
    final QuerySnapshot ds = await docRef.get();
    List<CoachRequest> response = [];
    ds.docs.forEach((doc) {
      final Map<String, dynamic> element = doc.data() as Map<String, dynamic>;
      response.add(CoachRequest.fromJson(element));
    });
    return response;
  }

  Future<CoachRequest> getBySegmentAndCoachId(String userId, String segmentId, String courseEnrollmentId, String coachId, String classId) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('coachAssignments')
        .doc(userId)
        .collection('coachRequests')
        .where('segment_id', isEqualTo: segmentId)
        .where('class_id', isEqualTo: classId)
        .where('course_enrollment_id', isEqualTo: courseEnrollmentId)
        .where('created_by', isEqualTo: coachId)
        .get();

    if (docRef.docs.length > 0) {
      return CoachRequest.fromJson(docRef.docs[0].data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  Future<void> resolve(CoachRequest coachRequest, String userId, RequestStatusEnum requestStatus) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString("projectId"))
        .collection('coachAssignments')
        .doc(userId)
        .collection('coachRequests')
        .doc(coachRequest.id);
    reference.update({'status': requestStatus.index});
  }

  Future<void> updateNotificationStatus(String coachRequestId, String userId, bool notificationValue) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString("projectId"))
        .collection('coachAssignments')
        .doc(userId)
        .collection('coachRequests')
        .doc(coachRequestId);
    reference.update({'notification_viewed': notificationValue});
  }

  Future<List<CoachRequest>> getByClassAndCoach(String userId, String classId, String courseEnrollmentId, String coachId) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString('projectId'))
        .collection('coachAssignments')
        .doc(userId)
        .collection('coachRequests')
        .where('class_id', isEqualTo: classId)
        .where('course_enrollment_id', isEqualTo: courseEnrollmentId)
        .where('created_by', isEqualTo: coachId)
        .get();

    return mapQueryToCoachRequest(docRef);
  }

  static List<CoachRequest> mapQueryToCoachRequest(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      return CoachRequest.fromJson(ds.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<void> updateSegmentSubmission(String userId, CoachRequest coachRequest, String segmentSubmissionId, DocumentReference segmentSubmissionRef) async {
    DocumentReference projectReference = FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString("projectId"));
    DocumentReference coachRequestDocRef = projectReference.collection('coachAssignments').doc(userId).collection('coachRequests').doc(coachRequest.id);
    await coachRequestDocRef.update({'segment_submission_id': segmentSubmissionId, 'segment_submission_reference': segmentSubmissionRef});
  }
}
