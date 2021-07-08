import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvt_fitness/models/base.dart';
import 'package:mvt_fitness/models/submodels/object_submodel.dart';

class Segment extends Base {
  String name;
  List<ObjectSubmodel> movements;

  Segment(
      {this.name,
      this.movements,
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

  factory Segment.fromJson(Map<String, dynamic> json) {
    Segment segment = Segment(
        name: json['name'],
        movements: json['movements'] == null
            ? null
            : List<ObjectSubmodel>.from(json['movements']
                .map((movement) => ObjectSubmodel.fromJson(movement))));
    segment.setBase(json);
    return segment;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> movementJson = {
      'name': name,
      'movements': movements == null
          ? null
          : List<dynamic>.from(movements.map((movement) => movement.toJson()))
    };
    movementJson.addEntries(super.toJson().entries);
    return movementJson;
  }
}
