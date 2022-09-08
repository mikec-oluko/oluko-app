import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/models/submodels/video_state.dart';
import 'base.dart';

class CoachAssignment extends Base {
  CoachAssignment(
      {this.userId,
      this.coachId,
      this.coachReference,
      this.coachAssignmentStatus,
      this.introductionCompleted,
      this.introductionVideo,
      this.video,
      this.videoState,
      this.videoHLS,
      this.isFavorite,
      this.welcomeVideoSeen,
      this.welcomeVideoUploadedAt,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(id: id, createdBy: createdBy, createdAt: createdAt, updatedAt: updatedAt, updatedBy: updatedBy, isDeleted: isDeleted, isHidden: isHidden);

  String userId, coachId, introductionVideo;
  DocumentReference coachReference;
  num coachAssignmentStatus;
  bool introductionCompleted, isFavorite, welcomeVideoSeen;
  Video video;
  String videoHLS;
  VideoState videoState;
  Timestamp welcomeVideoUploadedAt;

  factory CoachAssignment.fromJson(Map<String, dynamic> json) {
    CoachAssignment coachAssignmentObject = CoachAssignment(
      userId: json['id'] as String,
      coachId: json['coach_id'] as String,
      coachReference: json['coach_reference'] as DocumentReference,
      coachAssignmentStatus: json['status'] as num,
      introductionVideo: json['introduction_video'] as String,
      introductionCompleted: json['introduction_completed'] == null ? false : json['introduction_completed'] as bool,
      isFavorite: json['is_favorite'] == null ? false : json['is_favorite'] as bool,
      welcomeVideoSeen: json['welcome_video_seen'] == null ? false : json['welcome_video_seen'] as bool,
      welcomeVideoUploadedAt: json['welcome_video_uploaded_at'] as Timestamp,
      video: json['video'] == null ? null : Video.fromJson(json['video'] as Map<String, dynamic>),
      videoState: json['video_state'] == null ? null : VideoState.fromJson(json['video_state'] as Map<String, dynamic>),
      videoHLS: json['video_hls'] as String,
    );
    coachAssignmentObject.setBase(json);
    return coachAssignmentObject;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> coachAssignmentJson = {
      'id': userId,
      'coach_id': coachId,
      'coach_reference': coachReference,
      'status': coachAssignmentStatus,
      'introduction_video': introductionVideo,
      'introduction_completed': introductionCompleted ?? false,
      'video': video == null ? null : video.toJson(),
      'video_state': videoState == null ? null : videoState.toJson(),
      'video_hls': videoHLS,
      'is_favorite': isFavorite,
      'welcome_video_seen': welcomeVideoSeen,
      'welcome_video_uploaded_at': welcomeVideoUploadedAt
    };
    coachAssignmentJson.addEntries(super.toJson().entries);
    return coachAssignmentJson;
  }
}
