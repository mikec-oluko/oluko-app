import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/coach_request.dart';
import 'package:oluko_app/models/course_enrollment.dart';
import 'package:oluko_app/models/enums/segment_submission_status_enum.dart';
import 'package:oluko_app/models/enums/submission_state_enum.dart';
import 'package:oluko_app/models/segment.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/submodels/video_state.dart';

class SegmentSubmissionRepository {
  FirebaseFirestore firestoreInstance;

  SegmentSubmissionRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  SegmentSubmissionRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Future<SegmentSubmission> create(User user, CourseEnrollment courseEnrollment, Segment segment, String videoPath,
      CoachRequest coachRequest) async {
    DocumentReference projectReference = FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue("projectId"));

    DocumentReference courseEnrollmentReference = projectReference.collection('courseEnrollments').doc(courseEnrollment.id);

    DocumentReference userReference = projectReference.collection('users').doc(user.uid);

    CollectionReference segmentSubmissionReference = projectReference.collection("segmentSubmissions");

    DocumentReference segmentReference = projectReference.collection("segments").doc(segment.id);

    final DocumentReference docRef = segmentSubmissionReference.doc();

    SegmentSubmission segmentSubmission = SegmentSubmission(
        userId: user.uid,
        userReference: userReference,
        segmentId: segment.id,
        segmentReference: segmentReference,
        courseEnrollmentId: courseEnrollment.id,
        courseEnrollmentReference: courseEnrollmentReference,
        status: SegmentSubmissionStatusEnum.created,
        createdBy: user.uid,
        coachId: coachRequest.coachId,
        coachReference: coachRequest.coachReference,
        videoState: VideoState(state: SubmissionStateEnum.recorded, stateInfo: videoPath));

    segmentSubmission.id = docRef.id;
    docRef.set(segmentSubmission.toJson());
    return segmentSubmission;
  }

  static Future<void> updateVideo(SegmentSubmission segmentSubmission) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('segmentSubmissions')
        .doc(segmentSubmission.id);
    reference.update({
      'video': segmentSubmission.video.toJson(),
      'video_state.state': SubmissionStateEnum.uploaded.index,
      'video_state.state_info': "",
      'video_state.state_extra_info': ""
    });
  }

  static Future<void> updateStateToEncoded(SegmentSubmission segmentSubmission) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('segmentSubmissions')
        .doc(segmentSubmission.id);
    reference.update({
      'video_state.state': segmentSubmission.videoState.state.index,
      'video_state.state_info': segmentSubmission.videoState.stateInfo,
      'video_state.state_extra_info': segmentSubmission.videoState.stateExtraInfo,
      'video': segmentSubmission.video.toJson(),
    });
  }

  static Future<void> updateStateToError(SegmentSubmission segmentSubmission) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('segmentSubmissions')
        .doc(segmentSubmission.id);
    reference.update({'video_state.error': segmentSubmission.videoState.error});
  }
}
