import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/friend_model.dart';
import 'package:oluko_app/models/submodels/friend_request_model.dart';

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
        friends: List.from(json['friends'] as Iterable).length > 0
            ? List.from(json['friends'] as Iterable).map((friend) => FriendModel.fromJson(friend as Map<String, dynamic>)).toList()
            : [],
        friendRequestSent: List.from(json['friend_request_sent'] as Iterable).length > 0
            ? List.from(json['friend_request_sent'] as Iterable)
                .map((friend) => FriendRequestModel.fromJson(friend as Map<String, dynamic>))
                .toList()
            : [],
        friendRequestReceived: List.from(json['friend_request_received'] as Iterable).length > 0
            ? List.from(json['friend_request_received'] as Iterable)
                .map((friend) => FriendRequestModel.fromJson(friend as Map<String, dynamic>))
                .toList()
            : [],
        blocked: List.from(json['blocked'] as Iterable).length > 0
            ? List.from(json['blocked'] as Iterable).map((friend) => FriendModel.fromJson(friend as Map<String, dynamic>)).toList()
            : []);
    favorite.setBase(json);
    return favorite;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> friendJson = {
      'friends': friends.map((e) => e.toJson()).toList(),
      'friend_request_sent': friendRequestSent.map((e) => e.toJson()).toList(),
      'friend_request_received': friendRequestReceived.map((e) => e.toJson()).toList(),
      'blocked': blocked.map((e) => e.toJson()).toList()
    };
    friendJson.addEntries(super.toJson().entries);
    return friendJson;
  }
}
