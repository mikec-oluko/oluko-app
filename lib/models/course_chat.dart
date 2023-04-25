import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'package:oluko_app/models/submodels/user_message_submodel.dart';
import 'base.dart';

class CourseChat extends Base {
  CourseChat(
      {this.course,
      this.lastMessageSeenUsers,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(id: id, createdBy: createdBy, createdAt: createdAt, updatedAt: updatedAt, updatedBy: updatedBy, isDeleted: isDeleted, isHidden: isHidden);

  ObjectSubmodel course;
  List<UserMessageSubmodel> lastMessageSeenUsers;

  factory CourseChat.fromJson(Map<String, dynamic> json) {
    CourseChat chatJson = CourseChat(
      course: json['course'] != null ? ObjectSubmodel.fromJson(json['course'] as Map<String, dynamic>) : null,
      lastMessageSeenUsers: json['users_last_seen_message'] != null
          ? List<UserMessageSubmodel>.from(
              (json['users_last_seen_message'] as Iterable).map((item) => UserMessageSubmodel.fromJson(item as Map<String, dynamic>)))
          : null,
    );
    chatJson.setBase(json);
    return chatJson;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> chatJson = {
      'course': course.toJson(),
      'users_last_seen_message': lastMessageSeenUsers == null ? null : List<UserMessageSubmodel>.from(lastMessageSeenUsers.map((message) => message.toJson())),
    };
    chatJson.addEntries(super.toJson().entries);
    return chatJson;
  }
}
