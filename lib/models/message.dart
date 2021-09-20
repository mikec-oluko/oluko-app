import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

class Message extends Base {
  Message(
      {this.message,
      this.seenAt,
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

  String hifiveMessageCode = '#HiFive';
  String message;
  String seenAt;

  factory Message.fromJson(Map<String, dynamic> json) {
    Message chatJson = Message(
        message: json['message'] != null ? json['message'] as String : null,
        seenAt: json['seen_at'] != null ? json['seen_at'] as String : null);
    chatJson.setBase(json);
    return chatJson;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> chatJson = {
      'last_connected': seenAt,
      'message': message
    };
    chatJson.addEntries(super.toJson().entries);
    return chatJson;
  }
}
