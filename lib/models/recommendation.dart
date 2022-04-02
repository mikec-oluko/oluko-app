import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:oluko_app/helpers/enum_collection.dart';
import 'base.dart';

enum RecommendationEntityType { course, movement }

class Recommendation extends Base with EquatableMixin {
  Recommendation(
      {this.originUserId,
      this.originUserReference,
      this.destinationUserId,
      this.destinationUserReference,
      this.entityId,
      this.entityReference,
      this.entityType,
      this.notificationViewed,
      this.isTaken,
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
  TimelineInteractionType entityType;
  bool notificationViewed;
  bool isTaken;

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    Recommendation recommendation = Recommendation(
        originUserId: json['origin_user_id']?.toString(),
        originUserReference: json['origin_user_reference'] as DocumentReference,
        destinationUserId: json['destination_user_id']?.toString(),
        destinationUserReference: json['destination_user_reference'] as DocumentReference,
        entityId: json['entity_id']?.toString(),
        entityReference: json['entity_reference'] as DocumentReference,
        //entityType: json['entity_type'] as num,
        entityType: json['entity_type'] is int ? TimelineInteractionType.values[json['entity_type'] as int] : null,
        notificationViewed: json['notification_viewed'] == null ? false : json['notification_viewed'] as bool,
        isTaken: json['is_taken'] == null ? false : json['is_taken'] as bool);
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
      //'entity_type': entityType,
      'entity_type': entityType.index,
      'notification_viewed': notificationViewed,
      'is_taken': isTaken
    };
    recommendationJson.addEntries(super.toJson().entries);
    return recommendationJson;
  }

  @override
  // TODO: implement props
  List<Object> get props => [
        originUserId,
        originUserReference,
        destinationUserId,
        destinationUserReference,
        entityId,
        entityReference,
        entityType,
        notificationViewed,
        isTaken,
        id,
        createdBy,
        createdAt,
        updatedAt,
        updatedBy,
        isDeleted,
        isHidden
      ];
}
