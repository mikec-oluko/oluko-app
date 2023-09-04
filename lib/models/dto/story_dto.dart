import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/constants/theme.dart';
import 'package:oluko_app/models/base.dart';

class Story extends Base {
  String contentType;
  String url;
  String result;
  String segmentTitle;
  String description;
  bool seen;
  bool isDurationRecord;
  int duration;
  String timeFromCreation;

  Story(
      {this.contentType,
      this.url,
      this.result,
      this.segmentTitle,
      this.description,
      this.seen,
      this.isDurationRecord,
      this.duration,
      this.timeFromCreation,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(id: id, createdBy: createdBy, createdAt: createdAt, updatedAt: updatedAt, updatedBy: updatedBy, isDeleted: isDeleted, isHidden: isHidden);

  factory Story.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    Story story = Story(
        contentType: json['content_type']?.toString(),
        url: json['url']?.toString(),
        result: json['result']?.toString(),
        segmentTitle: json['segmentTitle']?.toString(),
        description: json['description']?.toString(),
        seen: json['seen'] != null ? json['seen'] as bool : false,
        isDurationRecord: json['is_duration_record'] != null ? json['is_duration_record'] as bool : false,
        duration: (json['duration'] is int) ? (json['duration'] as int) : 5);
    story.setBase(json);

    if (story.createdAt != null) {
      final now = DateTime.now();
      final createdAt = story.createdAt.toDate();
      final differenceInHours = now.difference(createdAt).inHours;
      if (differenceInHours != 0) {
        story.timeFromCreation = '${differenceInHours.toString()}h${OlukoNeumorphism.isNeumorphismDesign ? 'r' : ''}';
      } else {
        story.timeFromCreation = '${now.difference(createdAt).inMinutes}min';
      }
    } else {
      story.timeFromCreation = '25';
    }

    return story;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> storyJson = {
      'id': id,
      'content_type': contentType,
      'url': url,
      'result': result,
      'segmentTitle': segmentTitle,
      'description': description,
      'seen': seen,
      'is_duration_record': isDurationRecord,
      'duration': duration
    };
    storyJson.addEntries(super.toJson().entries);
    return storyJson;
  }
}
