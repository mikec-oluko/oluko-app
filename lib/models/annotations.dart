import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/models/submodels/video_state.dart';
import 'enums/annotation_status.dart';

class Annotation extends Base {
  String segmentSubmissionId;
  DocumentReference segmentSubmissionReference;
  String userId;
  DocumentReference userReference;
  String coachId;
  DocumentReference coachReference;
  Video video;
  VideoState videoState;
  AnnotationStatusEnum status;
  bool favorite;

  Annotation(
      {this.segmentSubmissionId,
      this.segmentSubmissionReference,
      this.userId,
      this.userReference,
      this.coachId,
      this.coachReference,
      this.video,
      this.videoState,
      this.status,
      this.favorite,
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

  factory Annotation.fromJson(Map<String, dynamic> json) {
    Annotation annotation = Annotation(
        userId: json['user_id'].toString(),
        userReference: json['user_reference'] as DocumentReference,
        coachId: json['coach_id'].toString(),
        coachReference: json['coach_reference'] as DocumentReference,
        status: AnnotationStatusEnum.values[json['status'] as int],
        favorite: json['favorite'] == null ? false : json['favorite'] as bool,
        video: json['video'] == null ? null : Video.fromJson(json['video'] as Map<String, dynamic>),
        videoState:
            json['video_state'] == null ? null : VideoState.fromJson(json['video_state'] as Map<String, dynamic>));

    annotation.setBase(json);
    return annotation;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> annotation = {
      'user_id': userId,
      'user_reference': userReference,
      'coach_id': coachId,
      'coach_reference': coachReference,
      'status': status.index,
      'favorite': favorite ?? false,
      'video': video == null ? null : video.toJson(),
      'video_state': videoState == null ? null : videoState.toJson()
    };
    annotation.addEntries(super.toJson().entries);
    return annotation;
  }
}