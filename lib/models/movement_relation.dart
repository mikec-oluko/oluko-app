import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:oluko_app/models/base.dart';
import 'package:oluko_app/models/submodels/object_submodel.dart';

class MovementRelation extends Base {
  DocumentReference reference;
  List<ObjectSubmodel> relatedCourses;
  List<ObjectSubmodel> relatedMovements;

  MovementRelation(
      {this.reference,
      this.relatedCourses,
      this.relatedMovements,
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

  factory MovementRelation.fromJson(Map<String, dynamic> json) {
    MovementRelation movement = MovementRelation(
      reference: json['reference'] as DocumentReference,
      relatedCourses: json['related_courses'] == null
          ? null
          : (json['related_courses'] as Iterable)
              .map<ObjectSubmodel>((course) => ObjectSubmodel.fromJson(course as Map<String, dynamic>))
              .toList(),
      relatedMovements: json['related_courses'] == null
          ? null
          : (json['related_movements'] as Iterable)
              .map<ObjectSubmodel>((course) => ObjectSubmodel.fromJson(course as Map<String, dynamic>))
              .toList(),
    );
    movement.setBase(json);
    return movement;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> movementJson = {
      'reference': reference,
      'related_movements': relatedMovements == null ? null : List<dynamic>.from(relatedMovements),
      'related_courses': relatedCourses == null ? null : List<dynamic>.from(relatedCourses),
    };
    movementJson.addEntries(super.toJson().entries);
    return movementJson;
  }
}
