import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/models/submodels/video_state.dart';
import 'enums/annotation_status.dart';
import 'package:equatable/equatable.dart';

class Annotation extends Base with EquatableMixin {
  String segmentSubmissionId;
  DocumentReference segmentSubmissionReference;
  String segmentName;
  String userId;
  DocumentReference userReference;
  String coachId;
  DocumentReference coachReference;
  Video video;
  String videoHLS;
  VideoState videoState;
  AnnotationStatusEnum status;
  bool favorite;
  bool notificationViewed;

  Annotation(
      {this.segmentSubmissionId,
      this.segmentSubmissionReference,
      this.segmentName,
      this.userId,
      this.userReference,
      this.coachId,
      this.coachReference,
      this.video,
      this.videoHLS,
      this.videoState,
      this.status,
      this.favorite,
      this.notificationViewed,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(id: id, createdBy: createdBy, createdAt: createdAt, updatedAt: updatedAt, updatedBy: updatedBy, isDeleted: isDeleted, isHidden: isHidden);

  factory Annotation.fromJson(Map<String, dynamic> json) {
    Annotation annotation = Annotation(
        userId: json['user_id'].toString(),
        segmentSubmissionId: json['segment_submission_id'].toString(),
        userReference: json['user_reference'] as DocumentReference,
        segmentSubmissionReference: json['segment_submission_reference'] as DocumentReference,
        segmentName: json['segment_name'].toString(),
        coachId: json['coach_id'].toString(),
        coachReference: json['coach_reference'] as DocumentReference,
        // status: AnnotationStatusEnum.values[json['status'] as int],
        favorite: json['favorite'] == null ? false : json['favorite'] as bool,
        video: json['video'] == null ? null : Video.fromJson(json['video'] as Map<String, dynamic>),
        videoHLS: json['video_hls'] == null ? null : json['video_hls'].toString(),
        videoState: json['video_state'] == null ? null : VideoState.fromJson(json['video_state'] as Map<String, dynamic>),
        notificationViewed: json['notification_viewed'] == null ? false : json['notification_viewed'] as bool);

    annotation.setBase(json);
    return annotation;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> annotation = {
      'user_id': userId,
      'segment_submission_id': segmentSubmissionId,
      'segment_name': segmentName,
      'user_reference': userReference,
      'coach_id': coachId,
      'coach_reference': coachReference,
      'segment_submission_reference': segmentSubmissionReference,
      // 'status': status,
      'favorite': favorite ?? false,
      'video': video == null ? null : video.toJson(),
      'video_hls': videoHLS,
      'video_state': videoState == null ? null : videoState.toJson(),
      'notification_viewed': notificationViewed
    };
    annotation.addEntries(super.toJson().entries);
    return annotation;
  }

  @override
  List<Object> get props => [
        userId,
        segmentSubmissionId,
        segmentName,
        userReference,
        coachId,
        coachReference,
        segmentSubmissionReference,
        status,
        favorite,
        video,
        videoHLS,
        videoState,
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
