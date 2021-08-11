import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:oluko_app/models/base.dart';

class FriendModel extends Base {
  DocumentReference reference;
  bool isMuted;
  DateTime isMutedUntil;
  DateTime latestSeenContent;

  FriendModel(
      {this.reference,
      this.isMuted,
      this.isMutedUntil,
      this.latestSeenContent,
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

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    FriendModel favorite = FriendModel(
        reference: json['reference'],
        isMuted: json['is_muted'],
        isMutedUntil: json['is_muted_until'],
        latestSeenContent: json['latest_seen_content']);
    favorite.setBase(json);
    return favorite;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> favoriteJson = {
      'reference': reference,
      'is_muted': isMuted,
      'is_muted_until': isMutedUntil,
      'latest_seen_content': latestSeenContent
    };
    favoriteJson.addEntries(super.toJson().entries);
    return favoriteJson;
  }
}
