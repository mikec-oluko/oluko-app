import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';

class Story extends Base {
  String content_type;
  String url;
  String description;
  bool seen;
  int duration;

  Story(
      {this.content_type, this.url, this.description, this.seen, this.duration, String id, Timestamp createdAt, String createdBy, Timestamp updatedAt, String updatedBy, bool isHidden, bool isDeleted})
      : super(id: id, createdBy: createdBy, createdAt: createdAt, updatedAt: updatedAt, updatedBy: updatedBy, isDeleted: isDeleted, isHidden: isHidden);

  factory Story.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    Story story = Story(
        content_type: json['content_type'].toString(),
        url: json['url'].toString(),
        description: json['description'].toString(),
        seen: json['seen'] != null ? json['seen'] as bool : false,
        duration: (json['duration'] is int) ? (json['duration'] as int) : 5);
    story.setBase(json);
    return story;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> storyJson = {'id': id, 'content_type': content_type, 'url': url, 'description': description, 'seen': seen, 'duration': duration};
    storyJson.addEntries(super.toJson().entries);
    return storyJson;
  }
}
