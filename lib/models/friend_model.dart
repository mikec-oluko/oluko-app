import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:oluko_app/models/base.dart';

class FriendModel {
  DocumentReference reference;
  bool isMuted;
  DateTime isMutedUntil;
  DateTime latestSeenContent;
  String id;
  bool isFavorite;

  FriendModel(
      {this.reference,
      this.isMuted,
      this.isMutedUntil,
      this.latestSeenContent,
      this.id,
      this.isFavorite});

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    FriendModel favorite = FriendModel(
        reference: json['reference'],
        isMuted: json['is_muted'],
        isMutedUntil: json['is_muted_until'],
        latestSeenContent: json['latest_seen_content'],
        id: json['id'],
        isFavorite: json['is_favorite']);
    return favorite;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> favoriteJson = {
      'reference': reference,
      'is_muted': isMuted,
      'is_muted_until': isMutedUntil,
      'latest_seen_content': latestSeenContent,
      'id': id,
      'is_favorite': isFavorite
    };
    return favoriteJson;
  }
}
