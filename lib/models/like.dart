import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'package:oluko_app/models/base.dart';

class Like extends Base {
  String userId;
  DocumentReference userReference;
  String entityId;
  EntityTypeEnum entityType;
  DocumentReference entityReference;
  bool isActive;

  Like(
      {this.userId,
      this.userReference,
      this.entityId,
      this.entityReference,
      this.entityType,
      this.isActive,
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

  factory Like.fromJson(Map<String, dynamic> json) {
    Like like = Like(
        userId: json['user_id'] != null ? json['user_id'].toString() : null,
        userReference: json['user_reference'] as DocumentReference,
        entityId: json['entity_id'] != null ? json['entity_id'].toString() : null,
        entityReference: json['entity_reference'] as DocumentReference,
        entityType: json['entity_type'] is int ? EntityTypeEnum.values[json['entity_type'] as int] : null,
        isActive: json['is_active'] == null ? false : json['is_active'] as bool);
    like.setBase(json);
    return like;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> LikeJson = {
      'user_id': userId,
      'user_reference': userReference,
      'entity_id': entityId,
      'entity_reference': entityReference,
      'entity_type': entityType.index,
      'is_active': isActive
    };
    LikeJson.addEntries(super.toJson().entries);
    return LikeJson;
  }
}
