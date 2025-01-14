import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:oluko_app/models/base.dart';
import 'enums/request_status_enum.dart';

class CoachRequest extends Base with EquatableMixin {
  RequestStatusEnum status;
  String segmentId;
  DocumentReference segmentReference;
  String coachId;
  DocumentReference coachReference;
  String segmentSubmissionId;
  DocumentReference segmentSubmissionReference;
  String courseEnrollmentId;
  DocumentReference courseEnrollmentReference;
  bool notificationViewed;
  String classId;
  DocumentReference classReference;

  CoachRequest(
      {this.status,
      this.segmentId,
      this.segmentReference,
      this.classId,
      this.classReference,
      this.coachId,
      this.coachReference,
      this.segmentSubmissionId,
      this.segmentSubmissionReference,
      this.courseEnrollmentId,
      this.courseEnrollmentReference,
      this.notificationViewed,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(
            id: id,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            updatedBy: updatedBy,
            isDeleted: isDeleted,
            isHidden: isHidden);

  factory CoachRequest.fromJson(Map<String, dynamic> json) {
    final CoachRequest coachRequest = CoachRequest(
        status: RequestStatusEnum.values[json['status'] as int],
        segmentId: json['segment_id']?.toString(),
        segmentReference: json['segment_reference'] != null ? json['class_reference'] as DocumentReference : null,
        classId: json['class_id']?.toString(),
        classReference: json['class_reference'] != null ? json['class_reference'] as DocumentReference : null,
        coachId: json['coach_id']?.toString(),
        coachReference: json['coach_reference'] != null ? json['coach_reference'] as DocumentReference : null,
        segmentSubmissionId: json['segment_submission_id']?.toString(),
        segmentSubmissionReference:
            json['segment_submission_reference'] != null ? json['segment_submission_reference'] as DocumentReference : null,
        courseEnrollmentId: json['course_enrollment_id']?.toString(),
        courseEnrollmentReference:
            json['course_enrollment_reference'] != null ? json['course_enrolled_reference'] as DocumentReference : null,
        notificationViewed: json['notification_viewed'] == null ? false : json['notification_viewed'] as bool);
    coachRequest.setBase(json);
    return coachRequest;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> coachRequestJson = {
      'status': status,
      'segment_id': segmentId,
      'segment_reference': segmentReference,
      'class_id': classId,
      'class_reference': classReference,
      'coach_id': coachId,
      'coach_reference': coachReference,
      'segment_submission_id': segmentSubmissionId,
      'segment_submission_reference': segmentSubmissionReference,
      'course_enrollment_id': courseEnrollmentId,
      'course_enrollment_reference': courseEnrollmentReference,
      'notification_viewed': notificationViewed
    };
    coachRequestJson.addEntries(super.toJson().entries);
    return coachRequestJson;
  }

  @override
  List<Object> get props => [
        status,
        segmentId,
        segmentReference,
        coachId,
        coachReference,
        segmentSubmissionId,
        segmentSubmissionReference,
        courseEnrollmentId,
        courseEnrollmentReference,
        notificationViewed,
        id,
        createdBy,
        createdAt,
        updatedAt,
        updatedBy,
        isDeleted,
        isHidden
      ];
}
