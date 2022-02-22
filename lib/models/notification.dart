import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/user_submodel.dart';

class Notification extends Base {
  Timestamp seenAt;
  UserSubmodel user;
  String message;

  Notification(
      {this.seenAt,
      this.user,
      this.message,
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
          isHidden: isHidden,
        );

  factory Notification.fromJson(Map<String, dynamic> json) {
    Notification notification = Notification(
      seenAt: json['seen_at'] != null ? json['seen_at'] as Timestamp : null,
      user: json['user'] != null ? UserSubmodel.fromJson(json['user'] as Map<String, dynamic>) : null,
      message: json['message'] != null ? json['message'].toString() : null,
    );
    notification.setBase(json);
    return notification;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> notificationJson = {
      'seen_at': seenAt,
      'user': user,
      'message': message
    };
    notificationJson.addEntries(super.toJson().entries);
    return notificationJson;
  }
}
