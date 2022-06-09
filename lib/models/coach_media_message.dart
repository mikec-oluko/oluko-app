import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/models/submodels/video_state.dart';

class CoachMediaMessage extends Base {
  String coachId, videoHls, image, audio;
  DocumentReference coachReference;
  int mediaType;
  Video video;
  VideoState videoState;
  bool viewed;
  CoachMediaMessage(
      {this.coachId,
      this.coachReference,
      this.video,
      this.videoHls,
      this.videoState,
      this.mediaType,
      this.image,
      this.audio,
      this.viewed,
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

  factory CoachMediaMessage.fromJson(Map<String, dynamic> json) {
    CoachMediaMessage coachMediaMessage = CoachMediaMessage(
      coachId: json['coach_id']?.toString(),
      coachReference: json['coach_reference'] as DocumentReference,
      video: json['video'] == null ? null : Video.fromJson(json['video'] as Map<String, dynamic>),
      videoHls: json['video_hls']?.toString(),
      videoState: json['video_state'] == null ? null : VideoState.fromJson(json['video_state'] as Map<String, dynamic>),
      mediaType: json['type'] as int,
      image: json['image']?.toString(),
      audio: json['audio']?.toString(),
      viewed: json['viewed'] == null ? false : json['viewed'] as bool,
    );
    coachMediaMessage.setBase(json);
    return coachMediaMessage;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> coachMediaMessage = {
      'coach_id': coachId,
      'coach_reference': coachReference,
      'video': video ?? video.toJson(),
      'video_hls': videoHls,
      'video_state': videoState ?? videoState.toJson(),
      'type': mediaType,
      'image': image,
      'audio': audio,
      'viewed': viewed
    };
    coachMediaMessage.addEntries(super.toJson().entries);
    return coachMediaMessage;
  }
}
