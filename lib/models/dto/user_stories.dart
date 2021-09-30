import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/dto/story_dto.dart';

class UserStories extends Base {
  String name;
  String avatar;
  String avatar_thumbnail;
  List<Story> stories;

  UserStories({this.name, this.avatar, this.avatar_thumbnail, this.stories, String id, Timestamp createdAt, String createdBy, Timestamp updatedAt, String updatedBy, bool isHidden, bool isDeleted})
      : super(id: id, createdBy: createdBy, createdAt: createdAt, updatedAt: updatedAt, updatedBy: updatedBy, isDeleted: isDeleted, isHidden: isHidden);

  factory UserStories.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    UserStories userStories = UserStories(name: json['name'].toString(), avatar: json['avatar'].toString(), avatar_thumbnail: json['avatar_thumbnail'].toString());
    stories:
    json['stories'] != null ? (json['stories'] as Iterable).map<Story>((item) => Story.fromJson(item as Map<String, dynamic>)).toList() : [];
    userStories.setBase(json);
    return userStories;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> storyJson = {'id': id, 'name': name, 'avatar': avatar, 'avatar_thumbnail': avatar_thumbnail, 'stories': stories};
    storyJson.addEntries(super.toJson().entries);
    return storyJson;
  }
}
