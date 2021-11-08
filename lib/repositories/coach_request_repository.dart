import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/blocs/coach/coach_request_bloc.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/enums/status_enum.dart';

class CoachRequestRepository {
  FirebaseFirestore firestoreInstance;

  CoachRequestRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  CoachRequestRepository.test({this.firestoreInstance});

  Future<List<CoachRequest>> get(String userId) async {
    final docRef = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
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

  Future<CoachRequest> getBySegmentAndCoachId(
      String userId, String segmentId, String courseEnrollmentId, String coachId) async {
    QuerySnapshot docRef = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue('projectId'))
        .collection('coachAssignments')
        .doc(userId)
        .collection('coachRequests')
        .where('segment_id', isEqualTo: segmentId)
        .where('course_enrollment_id', isEqualTo: courseEnrollmentId)
        .where('created_by', isEqualTo: coachId)
        .get();

    if (docRef.docs.length > 0) {
      return CoachRequest.fromJson(docRef.docs[0].data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  Future<void> resolve(CoachRequest coachRequest, String userId) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('coachAssignments')
        .doc(userId)
        .collection('coachRequests')
        .doc(coachRequest.id);
    reference.update({'status': StatusEnum.resolved.index});
  }

  Future<void> updateNotificationStatus(String coachRequestId, String userId, bool notificationValue) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('coachAssignments')
        .doc(userId)
        .collection('coachRequests')
        .doc(coachRequestId);
    reference.update({'notification_viewed': notificationValue});
  }
}
