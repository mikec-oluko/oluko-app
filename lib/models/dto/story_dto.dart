import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';

class Story extends Base {
  String content_type;
  String url;
  String description;

  Story({this.content_type, this.url, this.description, String id, Timestamp createdAt, String createdBy, Timestamp updatedAt, String updatedBy, bool isHidden, bool isDeleted})
      : super(id: id, createdBy: createdBy, createdAt: createdAt, updatedAt: updatedAt, updatedBy: updatedBy, isDeleted: isDeleted, isHidden: isHidden);

  factory Story.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    Story story = Story(
      content_type: json['content_type'].toString(),
      url: json['url'].toString(),
      description: json['description'].toString(),
    );
    story.setBase(json);
    return story;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> storyJson = {
      'id': id,
      'content_type': content_type,
      'url': url,
      'description': description,
    };
    storyJson.addEntries(super.toJson().entries);
    return storyJson;
  }
}
