import 'package:cloud_firestore/cloud_firestore.dart';
import 'base.dart';

enum RecommendationEntityType { course, movement }

class Recommendation extends Base {
  Recommendation(
      {this.originUserId,
      this.originUserReference,
      this.destinationUserId,
      this.destinationUserReference,
      this.entityId,
      this.entityReference,
      this.entityType,
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

  // String id;
  String originUserId;
  DocumentReference originUserReference;
  String destinationUserId;
  DocumentReference destinationUserReference;
  String entityId;
  DocumentReference entityReference;
  num entityType;

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    Recommendation recommendation = Recommendation(
      originUserId: json['origin_user_id']?.toString(),
      originUserReference: json['origin_user_reference'] as DocumentReference,
      destinationUserId: json['destination_user_id']?.toString(),
      destinationUserReference: json['destination_user_reference'] as DocumentReference,
      entityId: json['entity_id']?.toString(),
      entityReference: json['entity_reference'] as DocumentReference,
      entityType: json['entity_type'] as num,
    );
    recommendation.setBase(json);
    return recommendation;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> recommendationJson = {
      'id': id,
      'origin_user_id': originUserId,
      'origin_user_reference': originUserReference,
      'destination_user_id': destinationUserId,
      'destination_user_reference': destinationUserReference,
      'entity_id': entityId,
      'entity_reference': entityReference,
      'entity_type': entityType,
    };
    recommendationJson.addEntries(super.toJson().entries);
    return recommendationJson;
  }
}
