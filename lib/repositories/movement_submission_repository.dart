import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/movement_submission.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/repositories/segment_submission_repository.dart';

class MovementSubmissionRepository {
  FirebaseFirestore firestoreInstance;

  MovementSubmissionRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  MovementSubmissionRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Future<MovementSubmission> create(
      SegmentSubmission segmentSubmission) async {
    MovementSubmission movementSubmission = MovementSubmission(
        userId: segmentSubmission.userId,
        userReference: segmentSubmission.userReference);
    CollectionReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('movementSubmissions');
    final DocumentReference docRef = reference.doc();
    movementSubmission.id = docRef.id;
    docRef.set(movementSubmission.toJson());
    SegmentSubmissionRepository.updateSegmentSubmission(
        segmentSubmission, movementSubmission);
    return movementSubmission;
  }

  static Future<MovementSubmission> update(
      MovementSubmission movementSubmission) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('movementSubmissions')
        .doc(movementSubmission.id);
    reference.update({'video': movementSubmission.video.toJson()});
  }
}
