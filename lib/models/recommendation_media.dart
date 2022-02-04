import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/video.dart';

class RecommendationMedia extends Base {
  String title;
  String description;
  Video video;
  RecommendationMedia(
      {this.title,
      this.description,
      this.video,
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

  factory RecommendationMedia.fromJson(Map<String, dynamic> json) {
    RecommendationMedia recommendationVideo = RecommendationMedia(
      title: json['title'].toString(),
      description: json['description'].toString(),
      video: json['video'] == null ? null : Video.fromJson(json['video'] as Map<String, dynamic>),
    );

    recommendationVideo.setBase(json);
    return recommendationVideo;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> recommendationVideo = {
      'title': title,
      'description': description,
      'video': video == null ? null : video.toJson(),
    };
    recommendationVideo.addEntries(super.toJson().entries);
    return recommendationVideo;
  }
}
