import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/video.dart';
import 'package:oluko_app/models/submodels/video_state.dart';

class CoachMedia extends Base {
  String imageUrl;
  Video video;
  VideoState videoState;
  CoachMedia(
      {this.imageUrl,
      this.video,
      this.videoState,
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

  factory CoachMedia.fromJson(Map<String, dynamic> json) {
    CoachMedia coachMedia = CoachMedia(
      imageUrl: json['image_url']?.toString(),
      video: json['video'] == null ? null : Video.fromJson(json['video'] as Map<String, dynamic>),
      videoState: json['video_state'] == null ? null : VideoState.fromJson(json['video_state'] as Map<String, dynamic>),
    );

    coachMedia.setBase(json);
    return coachMedia;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> coachMedia = {
      'image_url': imageUrl,
      'video': video ?? video.toJson(),
      'video_state': videoState ?? videoState.toJson(),
    };
    coachMedia.addEntries(super.toJson().entries);
    return coachMedia;
  }
}
