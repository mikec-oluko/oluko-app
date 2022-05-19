import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/dto/story_dto.dart';

class UserStories extends Base {
  String name;
  String avatar;
  String avatar_thumbnail;
  List<Story> stories;

  UserStories(
      {this.name,
      this.avatar,
      this.avatar_thumbnail,
      this.stories,
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

  factory UserStories.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    final UserStories userStories = UserStories(
        name: json['name']?.toString(), avatar: json['avatar']?.toString(), avatar_thumbnail: json['avatar_thumbnail']?.toString());
    List<Story> stories = [];
    if (json['stories'] != null) {
      final Map<String, dynamic> storiesJson = Map<String, dynamic>.from(json['stories'] as Map);
      storiesJson.forEach((key, story) {
        stories.add(Story.fromJson(Map<String, dynamic>.from(story as Map)));
      });
      stories.sort((a, b) {
        if (a.seen && !b.seen) return -1;
        if (!a.seen && b.seen) return 1;
        if (a.createdAt != null && b.createdAt != null) return a.createdAt?.compareTo(b.createdAt);
        return 0;
      });
    } else {
      stories = [];
    }
    userStories.stories = stories;
    userStories.setBase(json);
    return userStories;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> storyJson = {
      'id': id,
      'name': name,
      'avatar': avatar,
      'avatar_thumbnail': avatar_thumbnail,
      'stories': stories
    };
    storyJson.addEntries(super.toJson().entries);
    return storyJson;
  }
}
