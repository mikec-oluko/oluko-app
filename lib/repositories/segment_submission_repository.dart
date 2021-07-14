import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/course.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/movement_submission.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/repositories/movement_submission_repository.dart';

class SegmentSubmissionRepository {
  FirebaseFirestore firestoreInstance;

  SegmentSubmissionRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  SegmentSubmissionRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Future<SegmentSubmission> create(
      User user, CourseEnrollment courseEnrollment) async {
    DocumentReference projectReference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"));

    DocumentReference courseEnrollmentReference = projectReference
        .collection('courseEnrollments')
        .doc(courseEnrollment.id);

    DocumentReference userReference =
        projectReference.collection('users').doc(user.uid);

    CollectionReference segmentSubmissionReference =
        projectReference.collection("segmentSubmissions");

    final DocumentReference docRef = segmentSubmissionReference.doc();

    SegmentSubmission segmentSubmission = SegmentSubmission(
        userId: user.uid,
        userReference: userReference,
        courseEnrollmentId: courseEnrollment.id,
        courseEnrollmentReference: courseEnrollmentReference,
        movementSubmissions: []);

    segmentSubmission.id = docRef.id;
    docRef.set(segmentSubmission.toJson());
    return segmentSubmission;
  }

  static Future<SegmentSubmission> updateSegmentSubmission(
      SegmentSubmission segmentSubmission,
      MovementSubmission movementSubmission) async {

    DocumentReference projectReference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"));

    DocumentReference movementReference =
        projectReference.collection('movementsSubmissions').doc(movementSubmission.id);

    ObjectSubmodel movementSubmodel =
        ObjectSubmodel(id: movementSubmission.id, reference: movementReference);

    DocumentReference segmentReference = projectReference
        .collection('segmentSubmissions')
        .doc(segmentSubmission.id);

    if (segmentSubmission.movementSubmissions == null) {
      segmentSubmission.movementSubmissions = [];
    }
    segmentSubmission.movementSubmissions.add(movementSubmodel);
    segmentReference.update({
      'movementSubmissions': List<dynamic>.from(
          segmentSubmission.movementSubmissions.map((m) => m.toJson()))
    });
  }
}
