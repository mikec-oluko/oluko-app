import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';

class FriendRequestModel extends Base {
  FriendRequestModel(
      {String id,
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

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    FriendRequestModel favorite = FriendRequestModel();
    favorite.setBase(json);
    return favorite;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> favoriteJson = {};
    favoriteJson.addEntries(super.toJson().entries);
    return favoriteJson;
  }
}
