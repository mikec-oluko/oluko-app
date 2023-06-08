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
import 'package:oluko_app/models/weight_record.dart';
import 'package:oluko_app/repositories/coach_request_repository.dart';
import 'package:oluko_app/repositories/movement_repository.dart';

class SegmentSubmissionRepository {
  FirebaseFirestore firestoreInstance;

  SegmentSubmissionRepository() {
    firestoreInstance = FirebaseFirestore.instance;
  }

  SegmentSubmissionRepository.test({FirebaseFirestore firestoreInstance}) {
    this.firestoreInstance = firestoreInstance;
  }

  static Future<SegmentSubmission> create(
      User user, CourseEnrollment courseEnrollment, Segment segment, String videoPath, String coachId, String classId, CoachRequest coachRequest) async {
    DocumentReference projectReference = FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString("projectId"));

    DocumentReference courseEnrollmentReference = projectReference.collection('courseEnrollments').doc(courseEnrollment.id);

    DocumentReference userReference = projectReference.collection('users').doc(user.uid);

    CollectionReference segmentSubmissionReference = projectReference.collection("segmentSubmissions");

    DocumentReference segmentReference = projectReference.collection("segments").doc(segment.id);

    DocumentReference coachReference;

    List<WeightRecord> submissionWeights = await MovementRepository().getFriendsRecords(user.uid);

    if (coachId != null) {
      coachReference = projectReference.collection("users").doc(coachId);
    }

    final DocumentReference docRef = segmentSubmissionReference.doc();

    SegmentSubmission segmentSubmission = SegmentSubmission(
      userId: user.uid,
      userReference: userReference,
      segmentId: segment.id,
      segmentReference: segmentReference,
      segmentName: segment.name,
      courseEnrollmentId: courseEnrollment.id,
      courseEnrollmentReference: courseEnrollmentReference,
      status: SegmentSubmissionStatusEnum.created,
      createdBy: user.uid,
      coachId: coachId,
      coachReference: coachReference,
      videoState: VideoState(state: SubmissionStateEnum.recorded, stateInfo: videoPath),
      submissionWeight: submissionWeights,
    );

    segmentSubmission.id = docRef.id;
    return segmentSubmission;
  }

  static Future<void> updateVideo(SegmentSubmission segmentSubmission) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString("projectId"))
        .collection('segmentSubmissions')
        .doc(segmentSubmission.id);
    reference.update({
      'video': segmentSubmission.video.toJson(),
      'video_state.state': SubmissionStateEnum.uploaded.index,
      'video_state.state_info': "",
      'video_state.state_extra_info': ""
    });
  }

  static Future<void> saveSegmentSubmissionWithVideo(SegmentSubmission segmentSubmission, CoachRequest coachRequest) async {
    try {
      DocumentReference reference = FirebaseFirestore.instance
          .collection('projects')
          .doc(GlobalConfiguration().getString("projectId"))
          .collection('segmentSubmissions')
          .doc(segmentSubmission.id);
      segmentSubmission.videoState.state = SubmissionStateEnum.uploaded;
      DocumentSnapshot<Object> segmentSubmmited = await reference.get();
      if (segmentSubmmited.exists) {
        Map<String, dynamic> data = segmentSubmmited.data() as Map<String, dynamic>;
        SegmentSubmission existingSegmentSubmmited = SegmentSubmission.fromJson(data);
        if (existingSegmentSubmmited.video != segmentSubmission.video) {
          reference.update({'video': segmentSubmission.video.toJson()});
        }
      } else {
        reference.set(segmentSubmission.toJson());
      }
      if (coachRequest != null) {
        await CoachRequestRepository().updateSegmentSubmission(segmentSubmission.userId, coachRequest, segmentSubmission.id, reference);
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> setIsDeleted(SegmentSubmission segmentSubmission, bool deleted) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString("projectId"))
        .collection('segmentSubmissions')
        .doc(segmentSubmission.id);
    reference.update({
      'isDeleted': deleted,
    });
  }

  static Future<void> updateStateToEncoded(SegmentSubmission segmentSubmission) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getString("projectId"))
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
        .doc(GlobalConfiguration().getString("projectId"))
        .collection('segmentSubmissions')
        .doc(segmentSubmission.id);
    reference.update({'video_state.error': segmentSubmission.videoState.error});
  }

  Future<SegmentSubmission> getById(String id) async {
    DocumentReference reference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getString('projectId')).collection('segmentSubmissions').doc(id);
    DocumentSnapshot ds = await reference.get();
    return SegmentSubmission.fromJson(ds.data() as Map<String, dynamic>);
  }
}
