import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/friend_model.dart';
import 'package:oluko_app/models/friend_request_model.dart';

class Friend extends Base {
  List<FriendModel> friends;
  List<FriendRequestModel> friendRequestSent;
  List<FriendRequestModel> friendRequestReceived;
  List<FriendModel> blocked;

  Friend(
      {this.friends,
      this.friendRequestSent,
      this.friendRequestReceived,
      this.blocked,
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

  factory Friend.fromJson(Map<String, dynamic> json) {
    Friend favorite = Friend(
        friends: json['friends'],
        friendRequestSent: json['friend_request_sent'],
        friendRequestReceived: json['friend_request_received'],
        blocked: json['blocked']);
    favorite.setBase(json);
    return favorite;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> friendJson = {
      'friends': friends,
      'friend_request_sent': friendRequestSent,
      'friend_request_received': friendRequestReceived,
      'blocked': blocked
    };
    friendJson.addEntries(super.toJson().entries);
    return friendJson;
  }
}
