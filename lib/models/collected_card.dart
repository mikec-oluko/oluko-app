import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/points_card.dart';

class CollectedCard extends Base {
  PointsCard card;
  int multiplicity;

  CollectedCard(
      {this.card, this.multiplicity, String id, Timestamp createdAt, String createdBy, Timestamp updatedAt, String updatedBy, bool isHidden, bool isDeleted})
      : super(id: id, createdBy: createdBy, createdAt: createdAt, updatedAt: updatedAt, updatedBy: updatedBy, isDeleted: isDeleted, isHidden: isHidden);

  factory CollectedCard.fromJson(Map<String, dynamic> json) {
    CollectedCard collectedCard = CollectedCard(
      card: json['card'] != null ? PointsCard.fromJson(json['card'] as Map<String, dynamic>) : null,
      multiplicity: json['multiplicity'] as int,
    );
    collectedCard.setBase(json);
    return collectedCard;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> collectedCardJson = {'card': card.toJson(), 'multiplicity': multiplicity};
    collectedCardJson.addEntries(super.toJson().entries);
    return collectedCardJson;
  }
}
