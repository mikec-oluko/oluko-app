import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/message.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';

class UserMessageSubmodel {
  UserMessageSubmodel(
    { this.user,
      this.messageReference,
      this.messageId,});

  ObjectSubmodel user;
  DocumentReference messageReference;
  String messageId;

    factory UserMessageSubmodel.fromJson(Map<String, dynamic> json) {
    return UserMessageSubmodel(
        user: json['user'] != null ? ObjectSubmodel.fromJson(json['user'] as Map<String, dynamic>) : null,
        messageReference: json['message_reference'] as DocumentReference,
        messageId: json['message_id']?.toString(),
        );
  }

  Map<String, dynamic> toJson() => {
        'message_reference': messageReference,
        'message_id': messageId,
        'user': user.toJson()
      };
}
