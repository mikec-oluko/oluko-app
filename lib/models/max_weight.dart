import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/submodels/audio_message_submodel.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';
import 'base.dart';

class MaxWeight extends Base {
  int weight;
  String movementId;
  MaxWeight(
      {
      this.weight,
      this.movementId,
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


  factory MaxWeight.fromJson(Map<String, dynamic> json) {
    MaxWeight maxWeight = MaxWeight(
        weight: json['weight'] != null ? json['weight'] as int : null,
        movementId: json['movement_id'] != null ? json['movement_id'] as String : null
    );
    maxWeight.setBase(json);
    return maxWeight;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> maxWeight = {
      'weight': weight,
      'movement_id': movementId,
    };
    maxWeight.addEntries(super.toJson().entries);
    return maxWeight;
  }
}
