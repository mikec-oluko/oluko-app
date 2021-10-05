import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

class Chat extends Base {
  Chat(
      {this.lastConnected,
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

  String lastConnected;

  factory Chat.fromJson(Map<String, dynamic> json) {
    Chat chatJson = Chat(
      lastConnected: json['last_connected']?.toString(),
    );
    chatJson.setBase(json);
    return chatJson;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> chatJson = {
      'last_connected': lastConnected,
    };
    chatJson.addEntries(super.toJson().entries);
    return chatJson;
  }
}
