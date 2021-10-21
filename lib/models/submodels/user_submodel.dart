import 'package:oluko_app/models/dto/user_stories.dart';

class UserSubmodel {
  String id;
  String firstName;
  String lastName;
  String username;
  String avatar;
  String avatarThumbnail;
  UserStories stories;

  UserSubmodel({this.avatar, this.avatarThumbnail, this.firstName, this.username, this.id, this.lastName, this.stories});

  factory UserSubmodel.fromJson(Map<String, dynamic> json) {
    if (json != null) {
      return UserSubmodel(
          id: json['id'].toString(),
          firstName: json['first_name'].toString(),
          lastName: json['last_name'].toString(),
          username: json['username'].toString(),
          avatar: json['avatar'].toString(),
          avatarThumbnail: json['avatar_thumbnail'].toString());
    }
    return null;
  }

  Map<String, dynamic> toJson() => {'id': id, 'first_name': firstName, 'last_name': lastName, 'username': username, 'avatar': avatar, 'avatar_thumbnail': avatarThumbnail};
}
