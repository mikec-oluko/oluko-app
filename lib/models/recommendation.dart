enum RecommendationEntityType { course, content }

class Recommendation {
  Recommendation(
      {this.id,
      this.originUserId,
      this.destinationUserId,
      this.entityId,
      this.typeId});

  String id;
  String originUserId;
  String destinationUserId;
  String entityId;
  RecommendationEntityType typeId;

  Recommendation.fromJson(Map json)
      : id = json['id'],
        originUserId = json['origin_user_id'],
        destinationUserId = json['destination_user_id'],
        entityId = json['entity_id'],
        typeId = json['type_id'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'origin_user_id': originUserId,
        'destination_user_id': destinationUserId,
        'entity_id': entityId,
        'type_id': typeId,
      };
}
