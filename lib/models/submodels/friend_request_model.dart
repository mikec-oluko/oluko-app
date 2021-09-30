import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';

class FriendRequestModel {
  String id;

  FriendRequestModel({
    this.id,
  }) : super();

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    FriendRequestModel favorite = FriendRequestModel(id: json['id']?.toString());
    return favorite;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> favoriteJson = {'id': id};
    return favoriteJson;
  }
}
