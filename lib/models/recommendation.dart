enum RecommendationEntityType { course, content }

class Recommendation {
  Recommendation({this.id, this.originUserId, this.destinationUserId, this.entityId, this.typeId});

  String id;
  String originUserId;
  String destinationUserId;
  String entityId;
  num typeId;

  Recommendation.fromJson(Map json)
      : id = json['id']?.toString(),
        originUserId = json['origin_user_id']?.toString(),
        destinationUserId = json['destination_user_id']?.toString(),
        entityId = json['entity_id']?.toString(),
        typeId = json['type_id'] as num;

  Map<String, dynamic> toJson() => {
        'id': id,
        'origin_user_id': originUserId,
        'destination_user_id': destinationUserId,
        'entity_id': entityId,
        'type_id': typeId,
      };
}
