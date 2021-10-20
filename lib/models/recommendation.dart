import 'package:cloud_firestore/cloud_firestore.dart';

enum RecommendationEntityType { course, movement }

class Recommendation {
  Recommendation(
      {this.id,
      this.originUserId,
      this.originUserReference,
      this.destinationUserId,
      this.destinationUserReference,
      this.entityId,
      this.entityReference,
      this.entityType});

  String id;
  String originUserId;
  DocumentReference originUserReference;
  String destinationUserId;
  DocumentReference destinationUserReference;
  String entityId;
  DocumentReference entityReference;
  num entityType;

  Recommendation.fromJson(Map json)
      : id = json['id']?.toString(),
        originUserId = json['origin_user_id']?.toString(),
        originUserReference = json['origin_user_reference'] as DocumentReference,
        destinationUserId = json['destination_user_id']?.toString(),
        destinationUserReference = json['destination_user_reference'] as DocumentReference,
        entityId = json['entity_id']?.toString(),
        entityReference = json['entity_reference'] as DocumentReference,
        entityType = json['entity_type'] as num;

  Map<String, dynamic> toJson() => {
        'id': id,
        'origin_user_id': originUserId,
        'origin_user_reference': originUserReference,
        'destination_user_id': destinationUserId,
        'destination_user_reference': destinationUserReference,
        'entity_id': entityId,
        'entity_reference': entityReference,
        'entity_type': entityType,
      };
}
