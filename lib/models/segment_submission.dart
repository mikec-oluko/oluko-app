import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/enums/segment_submission_status_enum.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/models/submodels/video_state.dart';
import 'package:oluko_app/models/weight_record.dart';

class SegmentSubmission extends Base {
  String segmentId;
  DocumentReference segmentReference;
  String segmentName;
  String userId;
  DocumentReference userReference;
  String courseEnrollmentId;
  DocumentReference courseEnrollmentReference;
  String coachId;
  DocumentReference coachReference;
  Timestamp seenAt;
  Video video;
  VideoState videoState;
  SegmentSubmissionStatusEnum status;
  bool favorite;
  List<WeightRecord> submissionWeight;

  SegmentSubmission(
      {this.segmentId,
      this.segmentReference,
      this.segmentName,
      this.userId,
      this.userReference,
      this.coachId,
      this.coachReference,
      this.courseEnrollmentId,
      this.courseEnrollmentReference,
      this.video,
      this.videoState,
      this.seenAt,
      this.status,
      this.favorite,
      this.submissionWeight,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(id: id, createdBy: createdBy, createdAt: createdAt, updatedAt: updatedAt, updatedBy: updatedBy, isDeleted: isDeleted, isHidden: isHidden);

  factory SegmentSubmission.fromJson(Map<String, dynamic> json) {
    SegmentSubmission segmentSubmission = SegmentSubmission(
      userId: json['user_id']?.toString(),
      userReference: json['user_reference'] as DocumentReference,
      segmentId: json['segment_id']?.toString(),
      segmentName: json['segment_name']?.toString(),
      segmentReference: json['segment_reference'] as DocumentReference,
      coachId: json['coach_id']?.toString(),
      coachReference: json['coach_reference'] as DocumentReference,
      courseEnrollmentId: json['course_enrollment_id']?.toString(),
      status: json['status'] is int ? SegmentSubmissionStatusEnum.values[json['status'] as int] : null,
      courseEnrollmentReference: json['course_enrollment_reference'] as DocumentReference,
      seenAt: json['seen_at'] as Timestamp,
      favorite: json['favorite'] == null ? false : json['favorite'] as bool,
      video: json['video'] == null ? null : Video.fromJson(json['video'] as Map<String, dynamic>),
      videoState: json['video_state'] == null ? null : VideoState.fromJson(json['video_state'] as Map<String, dynamic>),
      submissionWeight: json['submission_weight'] != null
          ? List<WeightRecord>.from((json['submission_weight'] as Iterable).map((item) => WeightRecord.fromJson(item as Map<String, dynamic>)))
          : null,
    );

    segmentSubmission.setBase(json);
    return segmentSubmission;
  }

  Map<String, dynamic> toJson() {
    try {
      Map<String, dynamic> segmentSubmissionJson = {
        'user_id': userId,
        'user_reference': userReference,
        'segment_id': segmentId,
        'segment_reference': segmentReference,
        'segment_name': segmentName,
        'coach_id': coachId,
        'coach_reference': coachReference,
        'course_enrollment_id': courseEnrollmentId,
        'course_enrollment_reference': courseEnrollmentReference,
        'seen_at': seenAt,
        'status': status.index,
        'favorite': favorite ?? false,
        'video': video == null ? null : video.toJson(),
        'video_state': videoState == null ? null : videoState.toJson(),
        'submission_weight': submissionWeight == null ? [] : List<dynamic>.from(submissionWeight.map((weight) => weight.toJson())),
      };
      segmentSubmissionJson.addEntries(super.toJson().entries);
      return segmentSubmissionJson;
    } catch (e) {
      return null;
    }
  }
}
