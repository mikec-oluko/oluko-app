import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/submodels/audio_message_submodel.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'base.dart';

class Message extends Base {
  Message(
      {this.message,
      this.seenAt,
      this.user,
      this.audioMessage,
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

  final String hifiveMessageCode = '✋';
  String message;
  String seenAt;
  ObjectSubmodel user;
  AudioMessageSubmodel audioMessage;

  factory Message.fromJson(Map<String, dynamic> json) {
    Message chatJson = Message(
        message: json['message'] != null ? json['message'] as String : null,
        seenAt: json['seen_at'] != null ? json['seen_at'] as String : null,
        user: json['user'] != null ? ObjectSubmodel.fromJson(json['user'] as Map<String, dynamic>) : null,
        audioMessage: json['audio_message'] != null ? AudioMessageSubmodel.fromJson(json['audio_message'] as Map<String, dynamic>) : null);
    chatJson.setBase(json);
    return chatJson;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> chatJson = {
      'last_connected': seenAt,
      'message': message,
      'user': user != null ? user.toJson() : null,
      'audio_message': audioMessage != null ? audioMessage.toJson() : null
    };
    chatJson.addEntries(super.toJson().entries);
    return chatJson;
  }
}
