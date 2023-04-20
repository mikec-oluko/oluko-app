import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';

class UserMessageSubmodel {
  UserMessageSubmodel(
    { this.user,
      this.message,});

  ObjectSubmodel user;
  ObjectSubmodel message;

    factory UserMessageSubmodel.fromJson(Map<String, dynamic> json) {
    return UserMessageSubmodel(
        user: json['user'] != null ? ObjectSubmodel.fromJson(json['user'] as Map<String, dynamic>) : null,
        message: json['message'] != null ? ObjectSubmodel.fromJson(json['message'] as Map<String, dynamic>) : null,
        );
  }

  Map<String, dynamic> toJson() => {
        'message': message.toJson(),
        'user': user.toJson()
      };
}
