import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oluko_app/models/submodels/enrollment_movement.dart';
import 'package:oluko_app/models/submodels/enrollment_section.dart';

class EnrollmentSegment {
  String id;
  DocumentReference reference;
  String name;
  Timestamp completedAt;
  List<EnrollmentSection> sections;

  EnrollmentSegment({this.id, this.reference, this.name, this.completedAt, this.sections});

  factory EnrollmentSegment.fromJson(Map<String, dynamic> json) {
    return EnrollmentSegment(
        id: json['id']?.toString(),
        reference: json['reference'] as DocumentReference,
        name: json['name']?.toString(),
        completedAt: json['compleated_at'] as Timestamp,
        sections: json['sections'] == null
            ? null
            : List<EnrollmentSection>.from(
                (json['sections'] as Iterable).map((section) => EnrollmentSection.fromJson(section as Map<String, dynamic>))));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'name': name,
        'compleated_at': completedAt,
        'sections': sections == null ? null : List<dynamic>.from(sections.map((section) => section.toJson()))
      };
}
