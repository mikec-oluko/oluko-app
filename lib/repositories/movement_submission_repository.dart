import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:oluko_app/models/enums/submission_state_enum.dart';
import 'package:oluko_app/models/movement_submission.dart';
import 'package:oluko_app/models/segment_submission.dart';
import 'package:oluko_app/models/submodels/movement_submodel.dart';
import 'package:oluko_app/models/submodels/video_state.dart';
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
      SegmentSubmission segmentSubmission, MovementSubmodel movement, String videoPath) async {
    DocumentReference projectReference =
        FirebaseFirestore.instance.collection('projects').doc(GlobalConfiguration().getValue("projectId"));
    DocumentReference segmentSubmissionReference =
        projectReference.collection('segmentSubmissions').doc(segmentSubmission.id);
    MovementSubmission movementSubmission = MovementSubmission(
        userId: segmentSubmission.userId,
        userReference: segmentSubmission.userReference,
        movementId: movement.id,
        movementReference: movement.reference,
        segmentSubmissionId: segmentSubmission.id,
        segmentSubmissionReference: segmentSubmissionReference,
        videoState: VideoState(state: SubmissionStateEnum.recorded, stateInfo: videoPath));
    CollectionReference reference = projectReference.collection('movementSubmissions');
    final DocumentReference docRef = reference.doc();
    movementSubmission.id = docRef.id;
    docRef.set(movementSubmission.toJson());
    SegmentSubmissionRepository.updateSegmentSubmission(segmentSubmission, movementSubmission);
    return movementSubmission;
  }

  static Future<void> updateVideo(MovementSubmission movementSubmission) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('movementSubmissions')
        .doc(movementSubmission.id);
    reference.update({
      'video': movementSubmission.video.toJson(),
      'video_state.state': EnumToString.convertToString(SubmissionStateEnum.uploaded),
      'video_state.state_info': "",
      'video_state.state_extra_info': ""
    });
  }

  static Future<void> updateStateToEncoded(MovementSubmission movementSubmission) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('movementSubmissions')
        .doc(movementSubmission.id);
    reference.update({
      'video_state.state': EnumToString.convertToString(movementSubmission.videoState.state),
      'video_state.state_info': movementSubmission.videoState.stateInfo,
      'video_state.state_extra_info': movementSubmission.videoState.stateExtraInfo,
      'video': movementSubmission.video.toJson(),
    });
  }

  static Future<void> updateStateToError(MovementSubmission movementSubmission) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('movementSubmissions')
        .doc(movementSubmission.id);
    reference.update({'video_state.error': movementSubmission.videoState.error});
  }

  //TODO: Use this!!!!
  static Future<List<MovementSubmission>> get(SegmentSubmission segmentSubmission) async {
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('projects')
        .doc(GlobalConfiguration().getValue("projectId"))
        .collection('movementSubmissions')
        .where("segment_submission_id", isEqualTo: segmentSubmission.id)
        .get();
    return mapQueryToMovementSubmission(qs);
  }

  static List<MovementSubmission> mapQueryToMovementSubmission(QuerySnapshot qs) {
    return qs.docs.map((DocumentSnapshot ds) {
      Map<String, dynamic> movementSubmissionData = ds.data() as Map<String, dynamic>;
      return MovementSubmission.fromJson(movementSubmissionData);
    }).toList();
  }
}
