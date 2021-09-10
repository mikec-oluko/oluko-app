import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/submodels/enrollment_movement.dart';

class EnrollmentSegment {
  String id;
  DocumentReference reference;
  String name;
  Timestamp compleatedAt;
  List<EnrollmentMovement> movements;

  EnrollmentSegment({this.id, this.reference, this.name, this.compleatedAt, this.movements});

  factory EnrollmentSegment.fromJson(Map<String, dynamic> json) {
    return EnrollmentSegment(
        id: json['id'].toString(),
        reference: json['reference'] as DocumentReference,
        name: json['name'].toString(),
        compleatedAt: json['compleated_at'] as Timestamp,
        movements: json['movements'] == null
            ? null
            : List<EnrollmentMovement>.from((json['movements'] as Iterable)
                .map((movement) => EnrollmentMovement.fromJson(movement as Map<String, dynamic>))));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'name': name,
        'compleated_at': compleatedAt,
        'movements': movements == null ? null : List<dynamic>.from(movements.map((movement) => movement.toJson()))
      };
}
