import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';

class SegmentSubmodel {
  String id;
  DocumentReference reference;
  String name;
  List<ObjectSubmodel> movements;

  SegmentSubmodel({this.id, this.reference, this.name, this.movements});

  factory SegmentSubmodel.fromJson(Map<String, dynamic> json) {
    return SegmentSubmodel(
        id: json['id'],
        reference: json['reference'],
        name: json['name'],
        movements: json['movements'] == null
            ? null
            : List<ObjectSubmodel>.from(json['movements']
                .map((movement) => ObjectSubmodel.fromJson(movement))));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'name': name,
        'movements': movements == null
            ? null
            : List<dynamic>.from(
                movements.map((movement) => movement.toJson())),
      };
}
