import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';

class FriendRequestModel {
  String id;
  bool view;

  FriendRequestModel({
    this.id,
    this.view = false,
  }) : super();

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    FriendRequestModel favorite = FriendRequestModel(id: json['id']?.toString(), view: json['view'] != null ? json['view'] as bool : false);
    return favorite;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> favoriteJson = {'id': id, 'view': view};
    return favoriteJson;
  }
}
