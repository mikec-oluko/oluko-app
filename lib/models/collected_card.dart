import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/base.dart';

class CollectedCard extends Base {
  DocumentReference cardReference;
  int multiplicity;

  CollectedCard(
      {this.cardReference,
      this.multiplicity,
      String id,
      Timestamp createdAt,
      String createdBy,
      Timestamp updatedAt,
      String updatedBy,
      bool isHidden,
      bool isDeleted})
      : super(id: id, createdBy: createdBy, createdAt: createdAt, updatedAt: updatedAt, updatedBy: updatedBy, isDeleted: isDeleted, isHidden: isHidden);

  factory CollectedCard.fromJson(Map<String, dynamic> json) {
    CollectedCard collectedCard = CollectedCard(
      cardReference: json['card_reference'] as DocumentReference,
      multiplicity: json['multiplicity'] as int,
    );
    collectedCard.setBase(json);
    return collectedCard;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> collectedCardJson = {'card_reference': cardReference, 'multiplicity': multiplicity};
    collectedCardJson.addEntries(super.toJson().entries);
    return collectedCardJson;
  }
}
