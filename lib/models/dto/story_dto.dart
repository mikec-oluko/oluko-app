import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';

class Story extends Base {
  String content_type;
  String url;
  String result;
  String segmentTitle;
  String description;
  bool seen;
  int duration;
  int hoursFromCreation;

  Story(
      {this.content_type,
      this.url,
      this.result,
      this.segmentTitle,
      this.description,
      this.seen,
      this.duration,
      this.hoursFromCreation,
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

  factory Story.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    Story story = Story(
        content_type: json['content_type'].toString(),
        url: json['url'].toString(),
        result: json['result'].toString(),
        segmentTitle: json['segmentTitle'].toString(),
        description: json['description'].toString(),
        seen: json['seen'] != null ? json['seen'] as bool : false,
        duration: (json['duration'] is int) ? (json['duration'] as int) : 5);
    story.setBase(json);

    if (story.createdAt != null) {
      final now = DateTime.now();
      final createdAt = story.createdAt.toDate();
      final differenceInHours = now.difference(createdAt).inHours;
      story.hoursFromCreation = differenceInHours;
    } else {
      story.hoursFromCreation = 25;
    }

    return story;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> storyJson = {
      'id': id,
      'content_type': content_type,
      'url': url,
      'result': result,
      'segmentTitle': segmentTitle,
      'description': description,
      'seen': seen,
      'duration': duration
    };
    storyJson.addEntries(super.toJson().entries);
    return storyJson;
  }
}
